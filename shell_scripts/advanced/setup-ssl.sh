#!/bin/bash

### === 脚本描述 === ###
# 名称： setup-ssl.sh
# 功能： SSL 与防火墙管理函数库 (V4 - 最终版)
# 作者： Gemini-AI
# 创建日期：2025-07-18
# 许可证：MIT

### === 内部依赖与安装函数 === ###
_install_dependencies() {
    echo -e "${LIGHT_CYAN}⚙️  正在检查并安装依赖 (curl, socat, cron)...${WHITE}"
    local packages_to_install=""
    command -v curl &>/dev/null || packages_to_install+="curl "
    command -v socat &>/dev/null || packages_to_install+="socat "
    if ! command -v crontab &>/dev/null; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
                packages_to_install+="cron "
            elif [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" ]]; then
                packages_to_install+="cronie "
            fi
        fi
    fi
    if [[ -n "$packages_to_install" ]]; then
        echo -e "${LIGHT_CYAN}⏳ 检测到需要安装的软件包: ${LIGHT_GREEN}$packages_to_install${WHITE}"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian) sudo apt-get update -y && sudo apt-get install -y $packages_to_install ;;
                centos|rhel|fedora) sudo yum install -y $packages_to_install && sudo systemctl enable --now crond ;;
                *) echo "❌ 不支持的操作系统: $ID. 请手动安装: $packages_to_install" && return 1 ;;
            esac
            echo -e "${LIGHT_GREEN}✅ 依赖安装完成。${WHITE}"
        else
            echo -e "${LIGHT_RED}❌ 无法识别操作系统，请手动安装依赖: ${LIGHT_GREEN}$packages_to_install${WHITE}"
            return 1
        fi
    else
        echo -e "${LIGHT_GREEN}✅ 核心依赖已满足。${WHITE}"
    fi
}

_install_acme_client() {
    if [ -f "$HOME/.acme.sh/acme.sh" ]; then
        echo -e "${LIGHT_GREEN}✅ acme.sh 客户端已安装，尝试更新...${WHITE}"
        "$HOME/.acme.sh/acme.sh" --upgrade
    else
        echo -e "${LIGHT_CYAN}⏳ 正在从官方渠道安装 acme.sh 客户端...${WHITE}"
        curl https://get.acme.sh | sh
    fi
    export PATH="$HOME/.acme.sh:$PATH"
    if ! command -v acme.sh &>/dev/null; then
        echo -e "${LIGHT_RED}❌ acme.sh 安装失败，请检查 ${LIGHT_GREEN}$HOME/.acme.sh${WHITE} 目录并查看日志。"
        return 1
    fi
    echo -e "${LIGHT_GREEN}✅ acme.sh 客户端准备就绪。${WHITE}"
}


### === 防火墙管理函数 (模块化) === ###

# 函数：仅放行 80 端口
allow_port_80() {
    echo -e "${LIGHT_YELLOW}🔥 正在防火墙中放行 80/tcp 端口用于 ACME 验证...${WHITE}"
    if command -v ufw &>/dev/null; then
        sudo ufw allow 80/tcp comment 'ACME Challenge'
        echo -e "${LIGHT_GREEN}✅ UFW 规则已添加。${WHITE}"
    elif command -v firewall-cmd &>/dev/null; then
        sudo firewall-cmd --add-port=80/tcp --permanent
        sudo firewall-cmd --reload
        echo -e "${LIGHT_GREEN}✅ firewalld 规则已永久添加。${WHITE}"
    else
        echo -e "${LIGHT_RED}⚠️ 未找到防火墙管理工具。请手动确保 80 端口可访问。${WHITE}"
        return 1
    fi
}

# 函数：放行指定端口
allow_specific_port() {
    local port_to_allow="$1"
    if ! [[ "$port_to_allow" =~ ^[0-9]+$ && "$port_to_allow" -ge 1 && "$port_to_allow" -le 65535 ]]; then
        echo -e "${LIGHT_RED}❌ 错误: ${LIGHT_GREEN}'$port_to_allow'${WHITE} 不是一个有效的端口号 (1-65535)。"
        return 1
    fi

    echo -e "${LIGHT_YELLOW}🔥 正在防火墙中放行端口 ${LIGHT_GREEN}$port_to_allow/tcp${WHITE} ...${WHITE}"
    if command -v ufw &>/dev/null; then
        sudo ufw allow "$port_to_allow"/tcp
        echo -e "${LIGHT_GREEN}✅ 操作完成。防火墙状态：${WHITE}"
        sudo ufw status | grep "$port_to_allow/tcp"
    elif command -v firewall-cmd &>/dev/null; then
        sudo firewall-cmd --add-port="$port_to_allow"/tcp --permanent
        sudo firewall-cmd --reload
        echo -e "${LIGHT_GREEN}✅ 规则已永久添加。请检查防火墙状态。${WHITE}"
    else
        echo -e "${LIGHT_RED}⚠️ 未找到防火墙管理工具 (ufw, firewalld)。请手动操作。${WHITE}"
        return 1
    fi
}

# 函数：禁用防火墙
disable_firewall() {
    echo -e "\n${BOLD_RED}==================== ‼️  警告 ‼️ ====================${WHITE}"
    echo -e "${LIGHT_RED}此操作将完全禁用服务器的防火墙，使所有服务暴露于公网。${WHITE}"
    echo -e "${LIGHT_RED}这是一个 ${BOLD_RED}非常危险${WHITE} 的操作，仅建议在受信任网络或临时调试时使用。${WHITE}"
    echo -e "${BOLD_RED}======================================================${WHITE}"
    read -rp "${LIGHT_YELLOW}您确定要禁用防火墙吗? 请输入 'yes' 确认: ${WHITE}" confirm_disable
    
    if [[ "$confirm_disable" != "yes" ]]; then
        echo "🚫 操作已取消。"
        return 1
    fi
    
    echo -e "${LIGHT_YELLOW}🛑 正在禁用防火墙...${WHITE}"
    if command -v ufw &>/dev/null && sudo ufw status | grep -q 'Status: active'; then
        sudo ufw disable
        echo -e "${LIGHT_GREEN}✅ UFW 已被禁用。${WHITE}"
    elif command -v systemctl &>/dev/null && systemctl is-active --quiet firewalld; then
        sudo systemctl stop firewalld
        sudo systemctl disable firewalld
        echo -e "${LIGHT_GREEN}✅ firewalld 已被停止并禁用。${WHITE}"
    else
        echo -e "${LIGHT_YELLOW}ℹ️  防火墙已经处于非活动状态，或未找到管理工具。${WHITE}"
    fi
}


### === SSL 证书管理函数 === ###

# 函数：申请 SSL 证书
# 参数: $1:domain, $2:email, $3:ca_server
apply_ssl_certificate() {
    local domain="$1"
    local email="$2"
    local ca_server="$3"
    local cert_path="/etc/ssl/custom/$domain"

    # --- 步骤 0: 环境检查 ---
    if [ "$(id -u)" -ne 0 ]; then
      echo -e "${LIGHT_RED}❌ 错误: 此操作需要以 root 用户权限运行。${WHITE}"
      return 1
    fi

    # --- 步骤 1: 安装依赖 ---
    _install_dependencies || return 1
    
    # --- 步骤 2: 安装/更新 acme.sh ---
    _install_acme_client || return 1

    # --- 步骤 3: 注册账户并申请证书 ---
    echo -e "${LIGHT_CYAN}📜 正在使用邮箱 ${LIGHT_GREEN}$email${WHITE} 向 ${LIGHT_GREEN}$ca_server${WHITE} 注册 ACME 账户...${WHITE}"
    "$HOME/.acme.sh/acme.sh" --register-account -m "$email" --server "$ca_server"

    echo -e "${LIGHT_CYAN}🔐 正在为域名 ${LIGHT_GREEN}$domain${WHITE} 申请证书 (standalone 模式)...${WHITE}"
    # 注意：此处不再处理防火墙，调用此函数前需确保端口已放行
    if ! "$HOME/.acme.sh/acme.sh" --issue --standalone -d "$domain" --server "$ca_server"; then
        echo -e "${LIGHT_RED}❌ 证书申请失败！${WHITE}"
        echo -e "${LIGHT_YELLOW}🔍 请检查：${WHITE}"
        echo -e "   1. 域名 ($domain) 是否正确解析到本机 IP。"
        echo -e "   2. 80 端口或您指定的验证端口是否已被防火墙放行。"
        echo -e "   3. 验证端口是否已被其他程序 (如 Nginx, Apache) 占用。"
        return 1
    fi

    # --- 步骤 4: 安装证书并设置自动续期 ---
    echo -e "${LIGHT_CYAN}📦 正在将证书安装到 ${LIGHT_GREEN}$cert_path${WHITE} ...${WHITE}"
    sudo mkdir -p "$cert_path"
    if "$HOME/.acme.sh/acme.sh" --install-cert -d "$domain" \
        --key-file       "$cert_path/private.key" \
        --fullchain-file "$cert_path/fullchain.crt" \
        --server "$ca_server" \
        --reloadcmd "echo '证书已为 $domain 自动续期。可在此处添加服务重启命令'"
    then
        echo -e "\n🎉 SSL 证书配置成功！"
        echo -e "   - 证书路径: ${LIGHT_GREEN}$cert_path/fullchain.crt${WHITE}"
        echo -e "   - 私钥路径: ${LIGHT_GREEN}$cert_path/private.key${WHITE}"
        echo -e "   - acme.sh 已自动为您创建定时续期任务。"
    else
        log_error "❌ 证书安装步骤失败。"
        return 1
    fi
}

# 函数：列出已申请的域名
list_issued_domains() {
    if [ ! -f "$HOME/.acme.sh/acme.sh" ]; then
        log_warning "acme.sh 客户端未安装，无法列出域名。"
        return 1
    fi

    echo "🔍 正在查询已由 acme.sh 管理的域名列表..."
    export PATH="$HOME/.acme.sh:$PATH"
    
    # 检查列表内容是否为空（跳过标题行）
    if ! acme.sh --list | tail -n +2 | grep -q '.'; then
         echo -e "${LIGHT_YELLOW}ℹ️  当前没有找到已申请的证书域名。${WHITE}"
         return 1 # 返回1表示列表为空或失败
    fi
    
    echo -e "\n${LIGHT_CYAN}--- 已申请的域名证书列表 ---${WHITE}"
    acme.sh --list
    print_echo_line_1 "front_line"
    return 0 # 返回0表示成功且列表非空
}

# 函数：重置/吊销 SSL 证书
reset_ssl_environment() {
    local domain_to_reset="$1"
    
    echo -e "${LIGHT_RED}⚠️  警告: 此操作将从 acme.sh 移除域名 ${LIGHT_GREEN}'$domain_to_reset'${WHITE} 的续期配置，并删除其证书文件。${WHITE}"
    read -rp "${LIGHT_YELLOW}您确定要继续吗？ ${LIGHT_RED}[y/N]: ${WHITE}" confirm
    if [[ ! "$confirm" =~ ^[yY](es)?$ ]]; then
        echo -e "${LIGHT_RED}🚫 操作已取消。${WHITE}"
        return 1
    fi
    
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${LIGHT_RED}❌ 错误: 此操作需要 root 权限。${WHITE}"
        return 1
    fi
    
    if [ -f "$HOME/.acme.sh/acme.sh" ]; then
        export PATH="$HOME/.acme.sh:$PATH"
        echo -e "${LIGHT_YELLOW}🗑️  正在从 acme.sh 移除 ${LIGHT_GREEN}'$domain_to_reset'${WHITE}...${WHITE}"
        # 注意: 吊销操作需要CA支持且可能有限制，--remove更常用
        acme.sh --remove -d "$domain_to_reset"
    else
        echo -e "${LIGHT_YELLOW}ℹ️  acme.sh 未安装，跳过移除步骤。${WHITE}"
    fi
    
    local cert_path="/etc/ssl/custom/$domain_to_reset"
    if [ -d "$cert_path" ]; then
        echo -e "${LIGHT_YELLOW}🗑️  正在删除证书目录: ${LIGHT_GREEN}$cert_path${WHITE}...${WHITE}"
        sudo rm -rf "$cert_path"
    fi
    
    echo -e "${LIGHT_GREEN}✅ 域名 ${LIGHT_GREEN}'$domain_to_reset'${WHITE} 的清理操作已完成。${WHITE}"
}
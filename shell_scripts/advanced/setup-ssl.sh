#!/bin/bash

### === 脚本描述 === ###
# 名称： setup-ssl.sh
# 功能： SSL 与防火墙管理函数库 (V4 - 最终版)
# 作者： Gemini-AI
# 创建日期：2025-07-18
# 许可证：MIT

### === 函数：安装依赖项与配置防火墙 === ###
_install_dependencies() {
    local os_type
    os_type=$(check_system_type)
    if [[ -z "$os_type" ]]; then
        echo "依赖安装中止，因为系统类型不受支持。" >&2
        return 1
    fi

    echo "✅ 系统已识别: $os_type"

    # --- 步骤 2: 根据系统类型构建待安装的软件包列表 ---
    echo "⚙️  正在检查核心依赖 (curl, socat, cron)..."
    # 收集所有需要安装的软件包的名称
    local packages_to_install=""
    # 检查是否安装了 curl 和 socat
    command -v curl &>/dev/null || packages_to_install+="curl "
    command -v socat &>/dev/null || packages_to_install+="socat "

    # 检查 crontab 命令，如果不存在，则根据已知的 os_type 决定正确的包名。
    if ! command -v crontab &>/dev/null; then
        if [[ "$os_type" == "centos" ]]; then
            packages_to_install+="cronie "
        else # 涵盖 ubuntu 和 debian
            packages_to_install+="cron "
        fi
    fi

    # --- 步骤 3: 如果有需要安装的包，则执行安装 ---
    if [[ -n "$packages_to_install" ]]; then
        echo "⏳ 检测到需要安装的软件包: $packages_to_install"
        # 根据 os_type 选择正确的包管理器进行安装。
        case "$os_type" in
            ubuntu|debian)
                # 更新软件包列表并安装
                sudo apt-get update -y && sudo apt-get install -y $packages_to_install
                ;;
            centos)
                # 安装软件包
                sudo yum install -y $packages_to_install
                ;;
        esac

        # 检查上一条命令（安装）是否成功。$? 变量保存着最后一条命令的退出码，0代表成功。
        if [ $? -ne 0 ]; then
            echo "❌ 依赖安装失败！" >&2
            return 1
        fi
        print_echo_line_1 "front_line"
        echo -e "${LIGHT_GREEN}✅ 依赖安装完成。${WHITE}"
        print_echo_line_1 "back_line"
    else
        echo -e "${LIGHT_GREEN}✅ 核心依赖已满足。${WHITE}"
    fi

    # --- 步骤 4: 处理特定于系统的服务 ---
    # 如果是 CentOS 系统，确保 crond 服务正在运行并已设为开机自启。
    # 这个操作与 cronie 是否刚刚被安装无关，确保了服务的最终状态是正确的。
    if [[ "$os_type" == "centos" ]]; then
        echo "⚙️  正在为 CentOS 配置并启动 crond 服务..."
        sudo systemctl enable --now crond
    fi

    # 函数成功完成，返回退出码 0。
    return 0
}

### === 函数：安装 acme.sh 客户端 === ###
# @param $1 定时任务执行时间 (可选, 例如 "30 2" 代表凌晨2:30)
_install_acme_client() {
    # 接收传入的时间参数。如果参数为空，则使用默认值 "0 2" (凌晨2点)。
    # 语法 ${1:-"默认值"} 表示如果$1存在且不为空，则使用$1，否则使用默认值。
    local custom_cron_time=${1:-"0 2"}

    # 检查 acme.sh 客户端是否已安装
    if [ -f "$HOME/.acme.sh/acme.sh" ]; then
        echo -e "${LIGHT_GREEN}✅ acme.sh 客户端已安装，尝试更新...${WHITE}"
        "$HOME/.acme.sh/acme.sh" --upgrade
    else
        echo -e "${LIGHT_CYAN}⏳ 正在从官方渠道安装 acme.sh 客户端...${WHITE}"
        # 安装 acme.sh。它会自动创建一个默认的定时任务。
        curl https://get.acme.sh | sh
    fi
    # 将 acme.sh 添加到 PATH 环境变量中，确保后续命令能找到它。
    export PATH="$HOME/.acme.sh:$PATH"
    # 检查 acme.sh 命令是否真的可用了，作为最终验证。
    if ! command -v acme.sh &>/dev/null; then
        echo -e "${LIGHT_RED}❌ acme.sh 安装失败，请检查 ${LIGHT_GREEN}$HOME/.acme.sh${WHITE} 目录并查看日志。"
        return 1
    fi

    # --- 新增：设置自定义定时任务时间 ---
    echo -e "${LIGHT_CYAN}⚙️  正在将自动续期任务时间设置为 [${custom_cron_time}]...${WHITE}"
    # 定义 acme.sh 的 cron 命令部分，便于后续匹配和替换。
    local cron_job_command="$HOME/.acme.sh/acme.sh --cron"
    # 构建完整的新定时任务行。
    local new_cron_job_line="${custom_cron_time} * * * ${cron_job_command} > /dev/null"
    
    # 使用管道和命令组来安全地更新 crontab。
    # 1. crontab -l：列出所有当前的定时任务。
    # 2. grep -v "$cron_job_command"：排除掉所有包含 acme.sh --cron 的旧任务行。
    # 3. ; echo "$new_cron_job_line"：在排除后的结果末尾，追加我们自定义时间的新任务行。
    # 4. | crontab -：将前面处理好的最终结果，重新写入到 crontab 中。
    (crontab -l 2>/dev/null | grep -v "$cron_job_command" ; echo "$new_cron_job_line") | crontab -

    echo -e "${LIGHT_GREEN}✅ acme.sh 客户端准备就绪，并已配置好定时任务。${WHITE}"
}

### === 函数：注册 ACME 账户 === ###
# @param $1 邮箱
# @param $2 证书颁发机构
_register_acme_account() {
    local email="$1"
    local ca_server="$2"
    echo -e "${LIGHT_CYAN}📜 正在使用邮箱 ${LIGHT_GREEN}$email${WHITE} 向 ${LIGHT_GREEN}$ca_server${WHITE} 注册 ACME 账户...${WHITE}"
    "$HOME/.acme.sh/acme.sh" --register-account -m "$email" --server "$ca_server"
}

### === 函数：签发证书 === ###
# @param $1 域名
# @param $2 证书颁发机构
_issue_certificate() {
    local domain="$1"
    local ca_server="$2"
    echo -e "${LIGHT_CYAN}🔐 正在为域名 ${LIGHT_GREEN}$domain${WHITE} 申请证书 (standalone 模式)...${WHITE}"
    # standalone 模式会临时启动一个 web server 来完成验证。
    if ! "$HOME/.acme.sh/acme.sh" --issue --standalone -d "$domain" --server "$ca_server"; then
        log_error "❌ 证书申请失败！"
        echo -e "${LIGHT_YELLOW}🔍 请检查：${WHITE}"
        echo -e "   1. 域名 ($domain) 是否正确解析到本机 IP。"
        echo -e "   2. 80 端口是否已被防火墙放行，并且未被其他程序 (如 Nginx, Apache) 占用。"
        return 1
    fi
}

### === 函数：安装证书 === ###
# @param $1 域名
# @param $2 邮箱
# @param $3 证书颁发机构
# @param $4 证书路径
_install_certificate() {
    local domain="$1"
    local email="$2"
    local ca_server="$3"
    local cert_path="$4"

    echo -e "${LIGHT_CYAN}📦 正在将证书安装到 ${LIGHT_GREEN}$cert_path${WHITE} ...${WHITE}"
    sudo mkdir -p "$cert_path"
    if "$HOME/.acme.sh/acme.sh" --install-cert -d "$domain" \
        --key-file       "$cert_path/private.key" \
        --fullchain-file "$cert_path/fullchain.crt" \
        --server "$ca_server" \
        --reloadcmd "echo '证书已为 $domain 自动续期。'"
        # --reloadcmd "echo '证书已为 $domain 自动续期。可在此处添加服务重启命令'"
    then
        echo_info "🎉 SSL 证书配置成功！"
        echo_info "🔔 记得复制以下路径信息，用于后续配置。"
        echo_info "   - 证书路径: ${BOLD_LIGHT_GREEN}$cert_path/fullchain.crt${WHITE}"
        echo_info "   - 私钥路径: ${BOLD_LIGHT_GREEN}$cert_path/private.key${WHITE}"
        echo_info "   - 证书路径: ${BOLD_LIGHT_GREEN}$cert_path${WHITE} ..."
        echo_info "   - acme.sh 已自动为您创建定时续期任务。"
    else
        log_error "❌ 证书安装步骤失败。"
        return 1
    fi
}

### === 函数：配置防火墙 === ###
# @param $1 操作指令 ("disable" 或 "allow_http")
_configure_firewall() {
    # 接收传入的第一个参数作为操作指令
    local action="$1"
    # 如果没有接收到指令，则直接退出
    if [[ -z "$action" ]]; then
        return
    fi

    # 调用之前定义的函数来获取操作系统类型
    local os_type
    os_type=$(check_system_type)

    if [[ -z "$os_type" ]]; then
        log_error "❌ 防火墙配置失败：无法识别操作系统。"
        return 1
    fi

    print_echo_line_1

    echo -e "${LIGHT_CYAN}⚙️  正在根据您的选择配置防火墙...${WHITE}"

    # 根据操作系统类型执行不同的防火墙命令
        case "$os_type" in
        ubuntu|debian)
            # 检查 ufw 命令是否存在
            if ! command -v ufw &>/dev/null; then
                log_error "⚠️ UFW 防火墙工具未安装，跳过配置。"
                return
            fi

            if [[ "$action" == "disable" ]]; then
                echo -e"   - 正在禁用 UFW 防火墙..."
                sudo ufw disable
            elif [[ "$action" == "allow_http" ]]; then
                echo -e "   - 正在 UFW 中放行 HTTP (80/tcp) 端口..."
                # 'allow 80/tcp' 确保只开放 80 端口的 TCP 协议
                sudo ufw allow 80/tcp
                # 确保防火墙是开启状态才能让规则生效
                sudo ufw enable
            fi
            ;;
        centos)
            # 检查 firewalld 服务是否存在
            if ! systemctl list-unit-files | grep -q "firewalld.service"; then
                log_error "⚠️ firewalld 防火墙服务未安装，跳过配置。"
                return
            fi

            if [[ "$action" == "disable" ]]; then
                echo -e "   - 正在停止并禁用 firewalld 防火墙..."
                sudo systemctl stop firewalld
                sudo systemctl disable firewalld
            elif [[ "$action" == "allow_http" ]]; then
                echo -e "   - 正在 firewalld 中永久放行 http 服务..."
                # --add-service=http 比直接开放 80 端口更标准
                sudo firewall-cmd --permanent --add-service=http
                # 重新加载防火墙规则以使更改生效
                sudo firewall-cmd --reload
            fi
            ;;
    esac
    echo "✅ 防火墙配置完成。"
}

### === 函数：申请 SSL 证书 === ###
# @param $1 域名
# @param $2 邮箱
# @param $3 证书颁发机构
# @param $4 证书路径
_apply_ssl_certificate() {
    local domain="$1"
    local email="$2"
    local ca_server="$3"
    # 接收第四个参数作为自定义的定时任务时间
    local custom_cron_time="$4"
    local cert_path="/etc/ssl/custom/$domain"
    
    # print_echo_line_1 "front_line"
    echo -e "${LIGHT_CYAN}证书申请流程开始...${WHITE}"
    
    # --- 步骤 1: 安装依赖 ---
    _install_dependencies || return 1
    
    # --- 步骤 2: 安装/更新 acme.sh ---
    _install_acme_client "$custom_cron_time" || return 1

    # --- 步骤 3: 注册 ACME 账户 ---
    # 调用只负责注册的函数，传入它需要的参数
    _register_acme_account "$email" "$ca_server" || return 1

    # --- 步骤 4: 签发证书 ---
    # 调用只负责申请证书的函数，传入它需要的参数
    _issue_certificate "$domain" "$ca_server" || return 1

    # --- 步骤 5: 安装证书并设置自动续期 ---
    _install_certificate  "$domain" "$email" "$ca_server" "$cert_path" || return 1

    print_echo_line_1 "front_line"
    echo -e "${BOLD_LIGHT_GREEN}✅ 所有证书申请和安装步骤已成功完成。${WHITE}"
    print_echo_line_1 "back_line"
}

### === 函数：证书申请交互 === ###
get_ssl_interaction() {
    clear
    # 检查是否是 root 用户
    if ! is_user_root; then
        break_end
        return 1
    fi

    print_echo_line_1
    echo -e "${BOLD_YELLOW}SSL 证书申请向导${WHITE}"
    print_echo_line_1

    # ======================================================================================

    # --- 步骤 1: 收集基本信息 ---
    read -rp "${LIGHT_CYAN}请输入域名 (例如: example.com): ${WHITE}" domain
    if [[ -z "$domain" ]]; then
        echo "❌ 错误: 域名不能为空。" && sleep 2
        return
    fi

    read -rp "${LIGHT_CYAN}请输入电子邮件 (用于ACME账户): ${WHITE}" email
    if [[ -z "$email" ]]; then
        echo "❌ 错误: 邮箱不能为空。" && sleep 2
        return
    fi

    echo -e "${LIGHT_CYAN}请选择证书颁发机构 (CA):${WHITE}"
    echo -e "  ${LIGHT_CYAN}1) ${LIGHT_GREEN}Let's Encrypt (推荐)"
    echo -e "  ${LIGHT_CYAN}2) ${WHITE}Buypass"
    echo -e "  ${LIGHT_CYAN}3) ${WHITE}ZeroSSL"
    read -rp "${LIGHT_CYAN}输入选项 [1-3] (默认为1): ${WHITE}" ca_choice
    local ca_server
    case $ca_choice in
        2) ca_server="buypass" ;;
        3) ca_server="zerossl" ;;
        *) ca_server="letsencrypt" ;;
    esac

    clear

     # ======================================================================================

    # --- 步骤 1.5: 定时续期时间设置 (新増) ---
    print_echo_line_1
    echo -e "${LIGHT_CYAN}定时续期时间设置${WHITE}"
    print_echo_line_1
    echo -e "${LIGHT_YELLOW}请设置自动续期任务的执行时间 (24小时制)。合理的随机时间有助于避免网络拥堵。\n${WHITE}"

    # 让用户输入小时，提供默认值
    read -rp "${LIGHT_CYAN}请输入小时 (0-23, 默认为凌晨2点): ${WHITE}" cron_hour
    # 如果用户输入为空或不是数字，则使用默认值 2
    [[ -z "$cron_hour" || ! "$cron_hour" =~ ^[0-9]+$ || "$cron_hour" -gt 23 ]] && cron_hour=2

    # 让用户输入分钟，提供随机默认值
    # $((RANDOM % 60)) 会生成一个 0-59 之间的随机数
    default_minute=$((RANDOM % 60))
    read -rp "${LIGHT_CYAN}请输入分钟 (0-59, 默认为随机值 ${default_minute}): ${WHITE}" cron_minute
    # 如果用户输入为空或不是数字，则使用随机默认值
    [[ -z "$cron_minute" || ! "$cron_minute" =~ ^[0-9]+$ || "$cron_minute" -gt 59 ]] && cron_minute=$default_minute

    # 将小时和分钟组合成 crontab 需要的格式，例如 "30 2"
    local cron_time_setting="$cron_minute $cron_hour"

    clear

    # ======================================================================================

    # --- 步骤 2: 防火墙配置 ---
    print_echo_line_1
    echo -e "${LIGHT_CYAN}防火墙配置${WHITE}"
    print_echo_line_1
    echo -e "${LIGHT_YELLOW}证书申请需要通过公网HTTP(80端口)验证，请配置防火墙。\n${WHITE}"

    # 定义一个变量来存储用户的防火墙操作选择
    local firewall_action=""
    
    echo -e "${LIGHT_CYAN}防火墙操作:${WHITE}"
    echo -e "  ${LIGHT_CYAN}1) ${WHITE}禁用防火墙 ${LIGHT_GREEN}(推荐)${WHITE}"
    echo -e "  ${LIGHT_CYAN}2) ${WHITE}允许 HTTP (80端口) 流量通过防火墙${WHITE}"
    echo -e "  ${LIGHT_CYAN}3) ${WHITE}不做任何更改 (我已手动配置好)${WHITE}"
    read -rp "${LIGHT_CYAN}输入选项 [1-3] (默认为1): ${WHITE}" firewall_choice

    case $firewall_choice in
        2)
            firewall_action="allow_http"
            ;;
        3)
            firewall_action="" # 用户选择不操作，所以为空
            echo -e "${LIGHT_YELLOW}⚠️  您选择了不自动配置防火墙，请确保80端口可被公网访问。${WHITE}"
            ;;
        *) # 包含输入1和直接回车的情况
            firewall_action="disable"
            ;;
    esac

    clear

    print_echo_line_1
    echo -e "${LIGHT_CYAN}请确认申请信息：${WHITE}"
    echo -e "  - ${LIGHT_CYAN}域名:${WHITE}   $domain"
    echo -e "  - ${LIGHT_CYAN}邮箱:${WHITE}   $email"
    echo -e "  - ${LIGHT_CYAN}CA:${WHITE}     $ca_server"
    # print_echo_line_1

    # 根据用户的选择显示防火墙的配置意图
    case "$firewall_action" in
        "disable")
            echo -e "  - ${LIGHT_CYAN}防火墙:${WHITE} ${YELLOW}将完全禁用 (您的默认选择)${WHITE}"
            ;;
        "allow_http")
            echo -e "  - ${LIGHT_CYAN}防火墙:${WHITE} ${LIGHT_GREEN}将放行 HTTP (80端口)${WHITE}"
            ;;
        "")
            echo -e "  - ${LIGHT_CYAN}防火墙:${WHITE} ${WHITE}不作更改${WHITE}"
            ;;
    esac
    
    print_echo_line_1
    read -rp "${LIGHT_YELLOW}确认无误并开始申请吗? ${LIGHT_RED}[y/N]: ${WHITE}" start_apply
    if [[ "$start_apply" =~ ^[yY](es)?$ ]]; then
        # 在执行核心申请流程之前，先根据用户的选择配置好防火墙。
        _configure_firewall "$firewall_action"

        # 在确保环境就绪后，才开始调用核心的证书申请函数。
        _apply_ssl_certificate "$domain" "$email" "$ca_server" "$cron_time_setting"

    else
        echo
        echo -e "${LIGHT_RED}🚫 操作已取消。${WHITE}"
    fi

    break_end
}

### === 函数：列出已签发的域名 === ###
_list_issued_domains() {
    clear
    print_echo_line_1
    echo -e "${LIGHT_CYAN}🔎  正在查询已由 acme.sh 签发的域名列表...${WHITE}"
    print_echo_line_1

    local acme_sh_path="$HOME/.acme.sh/acme.sh"

    # 首先，检查 acme.sh 是否已安装
    if ! [ -f "$acme_sh_path" ]; then
        log_error "❌ acme.sh 客户端未安装，无法查询列表。"
        break_end
        return 1
    fi

    # 执行 --list 命令，并检查其输出是否包含 "Main_Domain" 这个表头。
    # 如果不包含，说明列表为空。
    # 使用 awk 是为了在输出不为空时，能优雅地打印整个列表，包括表头。
    local list_output
    list_output=$("$acme_sh_path" --list)
    
    if echo "$list_output" | grep -q "Main_Domain"; then
        echo "$list_output"
    else
        echo -e "${LIGHT_YELLOW}当前没有找到任何已签发的域名记录。${WHITE}"
    fi

    break_end
}

### === 函数：重置环境 === ###
_reset_environment() {
    clear
    print_echo_line_1
    echo -e "${LIGHT_RED}${BOLD}🔥🔥🔥 警告：危险操作 🔥🔥🔥${WHITE}"
    print_echo_line_1
    echo -e "${YELLOW}此操作将彻底删除 acme.sh 的所有数据，包括："
    echo -e "  - 客户端程序 (${HOME}/.acme.sh)"
    echo -e "  - 所有账户信息和证书记录"
    echo -e "  - 所有相关的定时续期任务"
    echo -e "此过程几乎是不可逆的！\n${WHITE}"

    read -rp "您确定要继续吗? 请输入 'yes' 确认: " confirmation
    if [[ "$confirmation" != "yes" ]]; then
        echo -e "\n ${LIGHT_GREEN}🚫 操作已取消。${WHITE}"
        break_end
        return
    fi

    # 第二次确认，针对已安装的证书目录
    echo ""
    read -rp "${LIGHT_RED}${BOLD}是否同时删除所有已安装的证书目录 (/etc/ssl/custom)？这也是不可逆的！ [y/N]: ${WHITE}" delete_certs
    if [[ "$delete_certs" =~ ^[yY](es)?$ ]]; then
        echo -e "${YELLOW}⚙️  正在删除已安装的证书目录...${WHITE}"
        # 使用 sudo 是因为该目录通常由 root 创建
        sudo rm -rf /etc/ssl/custom
        echo "✅ 已删除 /etc/ssl/custom"
    fi

    echo -e "${YELLOW}⚙️  正在移除 acme.sh 的定时续期任务...${WHITE}"
    # 安全地从 crontab 中移除 acme.sh 的任务行
    (crontab -l 2>/dev/null | grep -v 'acme.sh --cron') | crontab -
    echo "✅ 定时任务已移除。"

    echo -e "${YELLOW}⚙️  正在删除 acme.sh 客户端主目录...${WHITE}"
    rm -rf "$HOME/.acme.sh"
    echo "✅ 已删除 $HOME/.acme.sh"

    print_echo_line_1
    echo -e "${LIGHT_GREEN}✅ 环境重置完成。${WHITE}"
    print_echo_line_1
    break_end
}
#!/bin/bash

### =================================================================================
# @名称:         change_ssh.sh
# @功能描述:      以安全、交互式的方式修改 SSH 端口，并自动配置防火墙与 SELinux。
# @作者:         Vskit (vskit@vskit.com)
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-21
#
# 使用方法:
# 1. 保存脚本: `chmod +x change_ssh_port_pro.sh`
# 2. 运行脚本: `sudo ./change_ssh_port_pro.sh`
#
# @许可证:       MIT
### =================================================================================

# --- 全局变量和函数定义 ---
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# 核心功能函数：应用新的端口配置
# 接收一个参数：新的端口号
apply_new_port() {
    local new_port=$1
    
    # 1. 备份原始配置文件
    local backup_file="${SSH_CONFIG_FILE}.bak_$(date +%F_%T)"
    info "正在备份当前配置文件到: $backup_file"
    cp "$SSH_CONFIG_FILE" "$backup_file" || { warn "备份失败！"; return 1; }

    # 2. 修改 SSH 配置文件 (使用精确的 sed 命令)
    info "正在修改 SSH 配置文件 ($SSH_CONFIG_FILE)..."
    if grep -qE "^\s*#?\s*Port\s" "$SSH_CONFIG_FILE"; then
        sed -i -E "s/^\s*#?\s*Port\s.*/Port $new_port/" "$SSH_CONFIG_FILE"
    else
        echo -e "\n# 由脚本自动添加\nPort $new_port" >> "$SSH_CONFIG_FILE"
    fi
    info "配置文件修改完成。"

    # 3. 配置防火墙
    if command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
        info "检测到 firewalld，正在开放端口 $new_port/tcp..."
        firewall-cmd --permanent --add-port="$new_port/tcp" >/dev/null
        firewall-cmd --reload >/dev/null
        info "firewalld 配置完成。"
    elif command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        info "检测到 ufw，正在开放端口 $new_port/tcp..."
        ufw allow "$new_port/tcp" >/dev/null
        info "ufw 配置完成。"
    else
        warn "未检测到活动的 firewalld 或 ufw。请务必手动配置防火墙！"
    fi

    # 4. 配置 SELinux
    if command -v sestatus &> /dev/null && sestatus | grep -q "SELinux status:\s*enabled"; then
        if command -v semanage &> /dev/null; then
            info "检测到 SELinux，正在添加端口上下文..."
            semanage port -a -t ssh_port_t -p tcp "$new_port" &>/dev/null || warn "添加 SELinux 端口策略失败，可能已存在。"
            info "SELinux 配置完成。"
        else
            warn "'semanage' 命令未找到。如果 SELinux 处于 enforcing 模式，您必须手动配置！"
            warn "请安装 'policycoreutils-python-utils' (CentOS/RHEL) 或类似包后执行："
            warn "semanage port -a -t ssh_port_t -p tcp $new_port"
        fi
    fi

    # 5. 重启 SSH 服务并检查状态
    info "正在重启 SSH 服务..."
    local ssh_service_name="sshd"
    systemctl list-units --type=service | grep -q 'ssh.service' && ssh_service_name="ssh"
    
    systemctl restart "$ssh_service_name"
    sleep 1 # 等待服务重启

    if systemctl is-active --quiet "$ssh_service_name"; then
        info "SSH 服务已成功在端口 $new_port 上重启！"
        echo
        echo -e "\033[32m============================================================\033[0m"
        echo -e "\033[32m         SSH 端口修改成功!                                  \033[0m"
        echo -e "\033[32m============================================================\033[0m"
        info "您的新 SSH 端口是: \033[1;33m$new_port\033[0m"
        info "请使用新端口重新连接: \033[1mssh your_user@your_server_ip -p $new_port\033[0m"
        info "原始配置文件已备份至: $backup_file"
        echo
        return 0
    else
        warn "SSH 服务重启失败！配置可能存在问题。"
        warn "正在尝试恢复原始配置..."
        mv "$backup_file" "$SSH_CONFIG_FILE"
        systemctl restart "$ssh_service_name"
        error "已从备份恢复配置。请检查日志 ('journalctl -xeu $ssh_service_name') 以排查问题。"
        return 1
    fi
}

### === 函数：读取当前的 SSH 端口号 === ###
_read_current_ssh_port() {
    # 读取当前的 SSH 端口号
    local current_port=$(grep -E "^\s*Port\s+[0-9]+" "$SSH_CONFIG_FILE" | awk '{print $2}' | tail -n 1)
    echo $current_port
}

### === 函数：修改 SSH 端口 主函数 === ###
change_ssh_main() {
    clear
    if ! is_user_root; then
        break_end
    fi

    local new_port=$1
    apply_new_port "$new_port"
}
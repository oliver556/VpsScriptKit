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

    # local new_port=$1
    # apply_new_port "$new_port"
}
#!/bin/bash

### =================================================================================
# @名称:         change_ssh.sh
# @功能描述:      以安全、交互式的方式修改 SSH 端口，并自动配置防火墙与 SELinux。
# @作者:         5oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-21
#
# @许可证:       MIT
### =================================================================================

### === 全局变量和函数定义 === ###
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

### === 应用新的端口配置 === ###
#
# @描述
#   本函数用于应用新的端口配置。
#
# @参数 $1: 字符串 - 新的端口号。
#
# @示例
#   apply_new_port
apply_new_port() {
    local new_port=$1

}

### === 读取当前的 SSH 端口号 === ###
#
# @描述
#   本函数用于读取当前的 SSH 端口号。
#
# @返回值
#   成功返回 当前的 SSH 端口号。
#
# @示例
#   _read_current_ssh_port
###
_read_current_ssh_port() {
    # 读取当前的 SSH 端口号
    local current_port=$(grep -E "^\s*Port\s+[0-9]+" "$SSH_CONFIG_FILE" | awk '{print $2}' | tail -n 1)
    echo $current_port
}

### === 修改 SSH 端口 主函数 === ###
#
# @描述
#   本函数用于修改 SSH 端口主函数。
#
# @示例
#   change_ssh_main
###
change_ssh_main() {
    clear

    is_user_root || return

    # local new_port=$1
    # apply_new_port "$new_port"
}

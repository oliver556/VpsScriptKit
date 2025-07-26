#!/bin/bash

### =================================================================================
# @名称:         change_hostname.sh
# @功能描述:     修改主机名的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 修改主机名 工具函数 === ###
#
# @描述
#   本函数用于修改主机名工具函数。
#
# @示例
#   change_hostname_utils
###
change_hostname_utils() {
    while true; do
        # 读取当前主机名
        local current_hostname
        current_hostname=$(hostname)

        # 打印当前主机名
        print_echo_line_1
        echo -e "${LIGHT_CYAN}当前主机名是: ${BOLD_YELLOW}$current_hostname${LIGHT_WHITE}"
        print_echo_line_1

        read -e -p "${LIGHT_CYAN}请输入新的主机名（输入0退出）: ${LIGHT_WHITE}" new_hostname

        if [ -n "$new_hostname" ] && [ "$new_hostname" != "0" ]; then
            if [ -f /etc/alpine-release ]; then
                # Alpine
                echo "$new_hostname" > /etc/hostname
                hostname "$new_hostname"
            else
                # 其他系统，如 Debian, Ubuntu, CentOS 等
                hostnamectl set-hostname "$new_hostname"
                sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
                systemctl restart systemd-hostnamed
            fi

            if grep -q "127.0.0.1" /etc/hosts; then
                sed -i "s/127.0.0.1 .*/127.0.0.1       $new_hostname localhost localhost.localdomain/g" /etc/hosts
            else
                echo "127.0.0.1       $new_hostname localhost localhost.localdomain" >> /etc/hosts
            fi

            if grep -q "^::1" /etc/hosts; then
                sed -i "s/^::1 .*/::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback/g" /etc/hosts
            else
                echo "::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback" >> /etc/hosts
            fi

            echo -e "${BOLD_GREEN}主机名已更改为: $new_hostname${LIGHT_WHITE}"
            log_action "[system.sh]" "修改主机名"
            sleep 2
            break
        else
            echo -e "${BOLD_RED}已退出，未更改主机名。${LIGHT_WHITE}"
            break
        fi
    done
}

### === 修改主机名 主函数 === ###
#
# @描述
#   本函数用于修改主机名主函数。
#
# @示例
#   change_hostname_main
###
change_hostname_main() {
    clear

    if ! is_user_root; then
        break_end
    fi

    change_hostname_utils
}

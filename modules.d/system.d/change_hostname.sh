#!/bin/bash

change_hostname_utils() {
    while true; do
        # 读取当前主机名
        local current_hostname
        current_hostname=$(hostname)

        # 打印当前主机名
        echo -e "${LIGHT_CYAN}当前主机名是: ${BOLD_YELLOW}$current_hostname${WHITE}"
        print_echo_line_1

        read -e -p "${LIGHT_CYAN}请输入新的主机名（输入0退出）: ${WHITE}" new_hostname
        
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

            echo "主机名已更改为: $new_hostname"
            send_stats "主机名已更改"
            sleep 1
        else
            echo "已退出，未更改主机名。"
            break
        fi
    done
}

change_hostname_main() {
    clear

    # if ! is_user_root; then
    #     break_end
    # fi

    change_hostname_utils
    echo "1"
    sleep 1
}
#!/bin/bash

### =================================================================================
# @名称:         user_management.sh
# @功能描述:     用户管理的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-27
# @修改日期:     2025-07-27
#
# @许可证:       MIT
### =================================================================================

### === 用户管理 主菜单 === ###
#
# @描述
#   本函数用于显示用户管理主菜单。
#
# @示例
#   system_user_management_menu
###
system_user_management_menu() {
    while true; do
        clear
        sub_menu_title "⚙️  用户管理"

        gran_menu_title "[A] 用户列表"
        print_echo_line_1

        printf "%-24s %-34s %-20s %-10s\n" "用户名" "用户权限" "用户组" "sudo权限"
        while IFS=: read -r username _ userid groupid _ _ homedir shell; do
            local groups=$(groups "$username" | cut -d : -f 2)
            local sudo_status=$(sudo -n -lU "$username" 2>/dev/null | grep -q '(ALL : ALL)' && echo "Yes" || echo "No")
            printf "%-20s %-30s %-20s %-10s\n" "$username" "$homedir" "$groups" "$sudo_status"
        done < /etc/passwd

        gran_menu_title "[B] 账户操作"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}创建普通用户         ${LIGHT_CYAN}2.  ${LIGHT_WHITE}创建高级用户"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}3.  ${LIGHT_WHITE}赋予最高权限         ${LIGHT_CYAN}4.  ${LIGHT_WHITE}取消最高权限"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}5.  ${LIGHT_WHITE}删除账号"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回主菜单"
        print_echo_line_3
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                is_user_root || continue

                read -e -p "请输入新用户名: " new_username

                # 创建新用户并设置密码
                useradd -m -s /bin/bash "$new_username"
                passwd "$new_username"

                echo_success "操作已完成。"
                ;;
            2)
                is_user_root || continue

                # 提示用户输入新用户名
                read -e -p "请输入新用户名: " new_username

                # 创建新用户并设置密码
                useradd -m -s /bin/bash "$new_username"
                passwd "$new_username"

                # 赋予新用户sudo权限
                echo "$new_username ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers

                echo_success "操作已完成。"
                ;;
            3)
                is_user_root || continue

                read -e -p "请输入用户名: " username
                # 赋予新用户sudo权限
                echo "$username ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers
                ;;
            4)
                is_user_root || continue

                read -e -p "请输入用户名: " username
                # 从sudoers文件中移除用户的sudo权限
                sed -i "/^$username\sALL=(ALL:ALL)\sALL/d" /etc/sudoers
                ;;
            5)
                is_user_root || continue

                read -e -p "请输入要删除的用户名: " username
                # 删除用户及其主目录
                userdel -r "$username"
                ;;
            # 返回主菜单
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

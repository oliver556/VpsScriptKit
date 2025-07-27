#!/bin/bash

### =================================================================================
# @名称:         system.sh
# @功能描述:     显示系统工具菜单交互
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入系统信息查询 === ###
source "$ROOT_DIR/shell_scripts/system/info.sh"

### === 导入系统更新 === ###
source "$ROOT_DIR/shell_scripts/system/update.sh"

### === 导入系统清理 === ###
source "$ROOT_DIR/shell_scripts/system/clean.sh"

### === 导入修改系统时区 === ###
source "$ROOT_DIR/modules.d/system.d/time_zone.sh"

### === 导入一键重装安装 === ###
source "$ROOT_DIR/modules.d/system.d/reinstall.sh"

### === 导入修改主机名 === ###
source "$ROOT_DIR/modules.d/system.d/change_hostname.sh"

### === 导入修改 SSH 端口 === ###
source "$ROOT_DIR/modules.d/system.d/change_ssh.sh"

### === 导入设置 root 用户密码 === ###
source "$ROOT_DIR/shell_scripts/system/set_root_login.sh"

### === 导入优化 DNS 地址 === ###
source "$ROOT_DIR/modules.d/system.d/optimize_dns.sh"

### === 导入切换优先ipv4/ipv6 === ###
source "$ROOT_DIR/modules.d/system.d/v4_v6_priority.sh"

### === 导入系统通用工具 === ###
source "$ROOT_DIR/shell_scripts/system/general.sh"

### === 系统工具 主菜单 === ###
#
# @描述
#   本函数用于系统工具主菜单。
#
###
system_menu() {
    while true; do
        clear
        sub_menu_title "⚙️  系统工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}系统信息查询         ${LIGHT_CYAN}2.  ${LIGHT_WHITE}系统更新             ${LIGHT_CYAN}3.  ${LIGHT_WHITE}系统清理"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}4.  ${LIGHT_WHITE}修改登录密码         ${LIGHT_CYAN}5.  ${LIGHT_WHITE}开启ROOT密码登录     ${BOLD_GREY}6.  ${LIGHT_WHITE}开放所有端口"
        echo -e "${BOLD_GREY}7.  ${LIGHT_WHITE}修改SSH端口          ${LIGHT_CYAN}8.  ${LIGHT_WHITE}优化DNS地址          ${LIGHT_CYAN}9.  ${LIGHT_WHITE}禁用ROOT账户创建新账户"
        echo -e "${LIGHT_CYAN}10. ${LIGHT_WHITE}切换优先ipv4/ipv6    ${LIGHT_CYAN}11. ${LIGHT_WHITE}查看端口占用状态     ${BOLD_GREY}12. ${LIGHT_WHITE}修改虚拟内存大小"
        echo -e "${BOLD_GREY}13. ${LIGHT_WHITE}用户管理             ${BOLD_GREY}14. ${LIGHT_WHITE}用户/密码生成器"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}15. ${LIGHT_WHITE}修改主机名           ${LIGHT_CYAN}16. ${LIGHT_WHITE}修改系统时区         ${BOLD_GREY}17. ${LIGHT_WHITE}设置BBR3加速"
        echo -e "${BOLD_GREY}18. ${LIGHT_WHITE}防火墙高级管理器     ${BOLD_GREY}19. ${LIGHT_WHITE}iptables一键转发     ${BOLD_GREY}20. ${LIGHT_WHITE}NAT批量SSH连接测试"
        echo -e "${BOLD_GREY}21. ${LIGHT_WHITE}切换系统更新源       ${BOLD_GREY}22. ${LIGHT_WHITE}定时任务管理         ${BOLD_GREY}23. ${LIGHT_WHITE}ip开放端口扫描"
        print_echo_line_1
        echo -e "${BOLD_GREY}55. ${LIGHT_WHITE}设置脚本启动快捷键"
        echo -e "${BOLD_GREY}66. ${LIGHT_WHITE}一条龙系统调优"
        echo -e "${BOLD_GREY}98. ${LIGHT_WHITE}NAT小鸡一键重装系统"
        echo -e "${LIGHT_RED}99. ${LIGHT_WHITE}一键重装系统 ▶"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回主菜单"
        print_echo_line_3
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # 系统信息查询
            1)
                log_action "[system.sh]" "系统信息查询"
                system_info_main
                break_end ;;
            # 系统更新
            2)
                log_action "[system.sh]" "系统更新"
                system_update_main
                break_end no_wait ;;
            # 系统清理
            3)
                log_action "[system.sh]" "系统清理"
                system_clean_main
                break_end no_wait ;;
            # 修改登录密码
            4)
                log_action "[system.sh]" "修改登录密码"
                clear
                echo -e "${BOLD_YELLOW}设置你的登录密码...${LIGHT_WHITE}"
                passwd
                echo -e "${BOLD_GREEN}密码修改成功！${LIGHT_WHITE}"
                log_action "[system.sh]" "修改登录密码"
                break_end no_wait ;;
            # 开启ROOT密码登录
            5)
                log_action "[system.sh]" "开启ROOT密码登录"
                if is_user_root; then
                    set_root_login
                    break_end
                else
                    break_end
                fi
                ;;
            # 开放所有端口
            6)
                log_action "[system.sh]" "开放所有端口"
                # open_iptables
                print_dev
                break_end ;;
            # 修改SSH端口
            7)
                log_action "[system.sh]" "修改SSH端口"
                # change_ssh_main
                print_dev
                break_end ;;
            # 优化DNS地址
            8)
                log_action "[system.sh]" "优化DNS地址"
                system_optimize_dns_menu
                break_end no_wait;;
            # 禁用ROOT账户创建新账户
            9)
                log_action "[system.sh]" "禁用ROOT账户创建新账户"
                create_sudo_user_and_disable_root
                break_end ;;
            # 切换优先ipv4/ipv6
            10)
                log_action "[system.sh]" "切换优先ipv4/ipv6"
                system_v4_v6_priority_menu
                break_end no_wait;;
            # 查看端口占用状态
            11)
                log_action "[system.sh]" "查看端口占用状态"
                clear
                ss -tulnape
                break_end ;;
            # 修改虚拟内存大小
            12)
                log_action "[system.sh]" "修改虚拟内存大小"
                print_dev
                break_end ;;
            # 用户/密码生成器
            13)
                log_action "[system.sh]" "用户/密码生成器"
                print_dev
                break_end ;;
            # 用户管理
            14)
                log_action "[system.sh]" "用户管理"
                print_dev
                break_end ;;
            #==========================================
            # 修改主机名
            15)
                log_action "[system.sh]" "修改主机名"
                change_hostname_main
                break_end no_wait ;;
            # 修改系统时区
            16)
                log_action "[system.sh]" "修改系统时区"
                system_time_zone_menu
                break_end no_wait ;;
            # 设置BBR3加速
            17)
                log_action "[system.sh]" "设置BBR3加速"
                print_dev
                break_end ;;
            # 防火墙高级管理器
            18)
                log_action "[system.sh]" "防火墙高级管理器"
                print_dev
                break_end ;;
            # iptables一键转发
            19)
                log_action "[system.sh]" "iptables一键转发"
                print_dev
                break_end ;;
            # NAT批量SSH连接测试
            20)
                log_action "[system.sh]" "NAT批量SSH连接测试"
                print_dev
                break_end ;;
            # 切换系统更新源
            21)
                log_action "[system.sh]" "切换系统更新源"
                print_dev
                break_end ;;
            # 定时任务管理
            22)
                log_action "[system.sh]" "定时任务管理"
                print_dev
                break_end ;;
            # ip开放端口扫描
            23)
                log_action "[system.sh]" "ip开放端口扫描"
                print_dev
                break_end ;;
            #==========================================
            55)
                log_action "[system.sh]" "设置脚本启动快捷键"
                print_dev
                break_end ;;
            # 一条龙系统调优
            66)
                log_action "[system.sh]" "一条龙系统调优"
                print_dev
                break_end ;;
            # NAT小鸡一键重装系统
            98)
                log_action "[system.sh]" "NAT小鸡一键重装系统"
                print_dev
                break_end ;;
            # 一键重装安装
            99)
                log_action "[system.sh]" "一键重装系统"
                system_reinstall_menu
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

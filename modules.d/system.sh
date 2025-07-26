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
        echo -e "${LIGHT_CYAN}1.  ${WHITE}系统信息查询         ${LIGHT_CYAN}2.  ${WHITE}系统更新             ${LIGHT_CYAN}3.  ${WHITE}系统清理"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}4.  ${WHITE}修改登录密码         ${BOLD_GREY}5.  ${WHITE}开启ROOT密码登录     ${BOLD_GREY}6.  ${WHITE}开放所有端口"
        echo -e "${BOLD_GREY}7.  ${WHITE}修改SSH端口          ${BOLD_GREY}8.  ${WHITE}优化DNS地址          ${BOLD_GREY}9.  ${WHITE}禁用ROOT账户创建新账户"
        echo -e "${BOLD_GREY}10. ${WHITE}切换优先ipv4/ipv6    ${BOLD_GREY}11. ${WHITE}查看端口占用状态     ${BOLD_GREY}12. ${WHITE}修改虚拟内存大小"
        echo -e "${BOLD_GREY}13. ${WHITE}用户管理             ${BOLD_GREY}14. ${WHITE}用户/密码生成器"
        print_echo_line_1
        echo -e "${BOLD_GREY}15. ${WHITE}修改主机名           ${BOLD_GREY}16. ${WHITE}修改系统时区         ${BOLD_GREY}17. ${WHITE}设置BBR3加速"
        echo -e "${BOLD_GREY}18. ${WHITE}防火墙高级管理器     ${BOLD_GREY}19. ${WHITE}iptables一键转发       ${BOLD_GREY}20. ${WHITE}NAT批量SSH连接测试"
        echo -e "${BOLD_GREY}21. ${WHITE}切换系统更新源       ${BOLD_GREY}22. ${WHITE}定时任务管理       ${BOLD_GREY}23. ${WHITE}ip开放端口扫描"
        print_echo_line_1
        echo -e "${BOLD_GREY}55. ${WHITE}设置脚本启动快捷键"
        echo -e "${BOLD_GREY}66. ${WHITE}一条龙系统调优"
        echo -e "${BOLD_GREY}98. ${WHITE}NAT小鸡一键重装系统"
        echo -e "${LIGHT_RED}99. ${WHITE}一键重装系统 ▶"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
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
                echo -e "${BOLD_YELLOW}设置你的登录密码...${WHITE}"
                passwd
                echo -e "${BOLD_GREEN}密码修改成功！${WHITE}"
                log_action "[system.sh]" "修改登录密码"
                break_end no_wait ;;
            # 开启ROOT密码登录
            5)
                log_action "[system.sh]" "开启ROOT密码登录"
                print_dev
                break_end ;;
            # 开放所有端口
            6)
                log_action "[system.sh]" "开放所有端口"
                open_iptables
                ;;
            # 修改SSH端口
            7)
                log_action "[system.sh]" "修改SSH端口"
                change_ssh_main
                print_dev
                break_end ;;
            # 优化DNS地址
            8)
                log_action "[system.sh]" "优化DNS地址"
                print_dev
                break_end ;;
            # 禁用ROOT账户创建新账户
            9)
                log_action "[system.sh]" "禁用ROOT账户创建新账户"
                print_dev
                break_end ;;
            # 切换优先ipv4/ipv6
            10)
                log_action "[system.sh]" "切换优先ipv4/ipv6"
                print_dev
                break_end ;;
            # 查看端口占用状态
            11)
                log_action "[system.sh]" "查看端口占用状态"
                print_dev
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

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
        sub_menu_title "🖥️  系统工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}系统信息查询"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}2.  ${WHITE}系统更新             ${LIGHT_CYAN}3.  ${WHITE}系统清理"
        echo -e "${BOLD_GREY}4.  ${WHITE}系统用户管理         ${LIGHT_CYAN}5.  ${WHITE}开放所有端口"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}11. ${WHITE}修改登录密码         ${BOLD_GREY}12. ${WHITE}修改 SSH 端口"
        echo -e "${LIGHT_CYAN}13. ${WHITE}修改主机名           ${BOLD_GREY}14. ${WHITE}修改虚拟内存大小"
        echo -e "${LIGHT_CYAN}15. ${WHITE}修改系统时区"
        print_echo_line_1
        echo -e "${BOLD_GREY}21. ${WHITE}定时任务管理器       ${BOLD_GREY}22. ${WHITE}切换系统更新源"
        echo -e "${BOLD_GREY}23. ${WHITE}待定                 ${BOLD_GREY}24. ${WHITE}待定"
        print_echo_line_1
        echo -e "${BOLD_GREY}66. ${WHITE}一条龙系统调优             "
        echo -e "${LIGHT_CYAN}99. ${WHITE}一键重装系统 ▶            "
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # 系统信息查询
            1)
                log_action "[system.sh]" "系统信息查询系统信息查询"
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
            # 系统用户管理
            4)
                log_action "[system.sh]" "系统用户管理"
                break_end no_wait ;;
            # 开放所有端口
            5)
                log_action "[system.sh]" "开放所有端口"
                open_iptables
                ;;
            # 修改登录密码
            11)
                clear
                echo -e "${BOLD_YELLOW}设置你的登录密码...${WHITE}"
                passwd
                echo -e "${BOLD_GREEN}密码修改成功！${WHITE}"
                log_action "[system.sh]" "修改登录密码"
                break_end no_wait ;;
            # 修改 SSH 端口
            12)
                change_ssh_main
                break_end no_wait ;;
            # 修改主机名
            13)
                change_hostname_main
                break_end no_wait ;;
            # 修改虚拟内存大小
            14)
                log_action "[system.sh]" "修改虚拟内存大小"
                break_end no_wait ;;
            # 修改系统时区
            15)
                system_time_zone_menu
                break_end no_wait ;;
            # 一条龙系统调优
            66)
                log_action "[system.sh]" "一条龙系统调优"
                break_end no_wait ;;
            # 一键重装安装
            99)
                system_reinstall_menu
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

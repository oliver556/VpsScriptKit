#!/bin/bash

### === 脚本描述 === ###
# 名称： system.sh
# 功能： 系统工具
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

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

### === 系统工具 主菜单 === ###
system_menu() {
    while true; do
        clear
        title="🖥️  系统工具"
        printf "${LIGHT_CYAN}"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        printf "| %-${width_48}s |\n" "$title"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}1.  ${WHITE}系统信息查询"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}2.  ${WHITE}系统更新             ${LIGHT_CYAN}3. ${WHITE}系统清理"
        echo -e "${BOLD_GREY}4.  ${WHITE}系统用户管理"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}11. ${WHITE}修改登录密码         ${BOLD_GREY}12. ${WHITE}修改 SSH 端口"
        echo -e "${BOLD_GREY}13. ${WHITE}修改主机名           ${BOLD_GREY}14. ${WHITE}修改虚拟内存大小"
        echo -e "${LIGHT_CYAN}15. ${WHITE}修改系统时区"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${BOLD_GREY}66. ${WHITE}一条龙系统调优             "
        echo -e "${LIGHT_CYAN}99. ${WHITE}一键重装系统             "
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}0. ${WHITE}返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # 系统信息查询
            1)
                system_info_main
                break_end;;
            # 系统更新
            2)
                system_update_main
                break_end no_wait ;;
            # 系统清理
            3)
                system_clean_main
                break_end no_wait ;;
            # 系统用户管理
            4)
                break_end no_wait ;;
            # 修改登录密码
            11)
                echo -e "${BOLD_YELLOW}设置你的登录密码...${WHITE}"
                passwd
                echo -e "${BOLD_GREEN}密码修改成功！${WHITE}"
                break_end no_wait ;;
            # 修改 SSH 端口
            12)
                break_end no_wait ;;
            # 修改主机名
            13)
                break_end no_wait ;;
            # 修改虚拟内存大小
            14)
                break_end no_wait ;;
            # 修改系统时区
            15)
                system_time_zone_menu
                break_end no_wait ;;
            # 一条龙系统调优
            66)
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
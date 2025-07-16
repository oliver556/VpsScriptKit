#!/bin/bash

### === 脚本描述 === ###
# 名称： system.sh
# 功能： 系统工具
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

### === 导入系统信息查询 === ###
source "$ROOT_DIR/shell_scripts/system/system_info.sh"

### === 导入系统更新 === ###
source "$ROOT_DIR/modules.d/update.sh"

### === 导入系统清理 === ###
source "$ROOT_DIR/shell_scripts/system/system_clean.sh"

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
        echo -e "${LIGHT_CYAN}1. ${WHITE}系统信息查询         ${LIGHT_CYAN}2. ${WHITE}系统更新"
        echo -e "${LIGHT_CYAN}3. ${WHITE}系统清理             ${LIGHT_CYAN}4. ${WHITE}修改登录密码"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}0. ${WHITE}返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                system_info_main
                break_end;;
            2)
                system_info_main
                break_end no_wait ;;
            3)
                system_clean_main
                break_end no_wait ;;
            4)
                echo -e "${BOLD_YELLOW}设置你的登录密码...${WHITE}"
                passwd
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
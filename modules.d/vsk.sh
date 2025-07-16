#!/bin/bash

### === 脚本描述 === ###
# 名称： vsk.sh
# 功能： 脚本工具
# 作者：
# 创建日期：2025-07-17
# 许可证：MIT

source "$ROOT_DIR/shell_scripts/vsk/vsk_update.sh"
source "$ROOT_DIR/shell_scripts/vsk/vsk_uninstall.sh"

### === 系统工具 主菜单 === ###
vsk_menu() {
    while true; do
        clear
        title="🖥️  脚本工具"
        printf "${LIGHT_CYAN}"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        printf "| %-${width_48}s |\n" "$title"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}1. ${WHITE}脚本更新"
        echo -e "${LIGHT_CYAN}2. ${WHITE}脚本卸载"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}0. ${WHITE}返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                vsk_update_menu
                break_end no_wait ;;
            2)
                vsk_uninstall_menu
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
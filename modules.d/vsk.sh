#!/bin/bash

### === 脚本描述 === ###
# 名称： vsk.sh
# 功能： 脚本工具
# 作者：
# 创建日期：2025-07-17
# 许可证：MIT

source "$ROOT_DIR/modules.d/vsk.d/update.sh"
source "$ROOT_DIR/modules.d/vsk.d/uninstall.sh"
source "$ROOT_DIR/modules.d/vsk.d/vsk_log.sh"

### === 系统工具 主菜单 === ###
vsk_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  脚本工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1. ${WHITE}脚本更新"
        echo -e "${LIGHT_CYAN}2. ${WHITE}脚本卸载"
        echo -e "${LIGHT_CYAN}3. ${WHITE}脚本操作日志"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                vsk_update_menu
                break_end no_wait ;;
            2)
                vsk_uninstall_menu
                ;;
            3)
                vsk_log_tool_menu
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

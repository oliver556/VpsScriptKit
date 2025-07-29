#!/bin/bash

### =================================================================================
# @名称:         bbrv3.sh
# @功能描述:     BBRv3的脚本。
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-28
# @修改日期:     2025-07-28
#
# @许可证:       MIT
### =================================================================================

### === BBRv3 主菜单 === ###
#
# @描述
#   本函数用于显示BBRv3主菜单。
#
# @示例
#   system_bbrv3_menu
###
system_bbrv3_menu() {
    is_user_root || return

    while true; do
        clear
        sub_menu_title "⚙️  BBR3管理"

        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}IPv4 优先            ${LIGHT_CYAN}2.  ${LIGHT_WHITE}IPv6 优先            ${LIGHT_CYAN}3.  ${LIGHT_WHITE}IPv6 修复工具"
        break_menu_options "up"
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

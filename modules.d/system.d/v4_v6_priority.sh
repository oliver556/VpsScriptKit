#!/bin/bash

### =================================================================================
# @名称:         v4_v6_priority.sh
# @功能描述:     切换优先ipv4/ipv6的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-25
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入切换优先ipv4/ipv6 === ###
source "$ROOT_DIR/shell_scripts/system/v4_v6_priority.sh"

### === 切换优先ipv4/ipv6 主菜单 === ###
#
# @描述
#   本函数用于显示切换优先ipv4/ipv6主菜单。
#
# @示例
#   system_v4_v6_priority_menu
###
system_v4_v6_priority_menu() {
    is_user_root || return

    while true; do
        clear
        sub_menu_title "⚙️  切换优先ipv4/ipv6"
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}IPv4 优先            ${LIGHT_CYAN}2.  ${LIGHT_WHITE}IPv6 优先            ${LIGHT_CYAN}3.  ${LIGHT_WHITE}IPv6 修复工具"
        break_menu_options "up"
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null 2>&1
                echo -e "${LIGHT_GREEN}已切换为 IPv4 优先${LIGHT_WHITE}"
                ;;
            2)
                sysctl -w net.ipv6.conf.all.disable_ipv6=0 > /dev/null 2>&1
                echo -e "${LIGHT_GREEN}已切换为 IPv6 优先${LIGHT_WHITE}"
                ;;
            3)
                clear
                bash <(curl -L -s jhb.ovh/jb/v6.sh)
                echo -e "${GREY}感谢 jhb 大佬 的脚本支持！${LIGHT_WHITE} "
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

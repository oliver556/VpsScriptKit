#!/bin/bash

### =================================================================================
# @名称:         iptables_panel.sh
# @功能描述:     防火墙管理面板。
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-28
# @修改日期:     2025-07-28
#
# @许可证:       MIT
### =================================================================================

### === 防火墙管理面板 主菜单 === ###
#openwert
# @描述
#   本函数用于显示防火墙管理面板主菜单。
#
# @示例
#   system_iptables_panel_menu
###
system_iptables_panel_menu() {
    # is_user_root || return

    while true; do
        clear
        sub_menu_title "⚙️  高级防火墙管理"
        print_echo_line_1
        iptables -L INPUT

        echo ""
        gran_menu_title "[A] 防火墙管理"
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}开放指定端口           ${LIGHT_CYAN}2.  ${LIGHT_WHITE}关闭指定端口"
        echo -e "${LIGHT_CYAN}3.  ${LIGHT_WHITE}开放所有端口           ${LIGHT_CYAN}4.  ${LIGHT_WHITE}关闭所有端口"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}5.  ${LIGHT_WHITE}IP白名单               ${LIGHT_CYAN}6.  ${LIGHT_WHITE}IP黑名单"
        echo -e "${LIGHT_CYAN}7.  ${LIGHT_WHITE}清除指定IP"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}11. ${LIGHT_WHITE}允许PING               ${LIGHT_CYAN}12. ${LIGHT_WHITE}禁止PING"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}13. ${LIGHT_WHITE}启动DDOS防御           ${LIGHT_CYAN}14. ${LIGHT_WHITE}关闭DDOS防御"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}15. ${LIGHT_WHITE}阻止指定国家IP         ${LIGHT_CYAN}16. ${LIGHT_WHITE}仅允许指定国家IP"
        echo -e "${LIGHT_CYAN}17. ${LIGHT_WHITE}解除指定国家IP限制"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回上一级菜单"
        print_echo_line_3
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                system_time_zone_main "Asia/Shanghai"
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

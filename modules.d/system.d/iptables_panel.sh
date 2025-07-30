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

source "$ROOT_DIR/shell_scripts/system/iptables_panel.sh"

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

    # 确保 iptables-persistent 或同类工具已安装
    # if ! command -v netfilter-persistent &> /dev/null && ! (command -v systemctl &> /dev/null && systemctl list-unit-files | grep -q 'iptables.service'); then
    #     read -p "未检测到iptables持久化工具,是否现在尝试安装(iptables-persistent)? [y/n]: " choice
    #     if [[ "$choice" =~ ^[Yy]$ ]]; then
    #         apt-get update && apt-get install iptables-persistent -y
    #     fi
    # fi

    while true; do
        clear
        sub_menu_title "⚙️  高级防火墙管理"

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
        
        gran_menu_title "[B] 当前 INPUT 链规则"
        echo -e "${LIGHT_CYAN}99. ${LIGHT_WHITE}显示当前 INPUT 链规则"
        break_menu_options "up"
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                prompt_and_open_ports
                break_end no_wait
                ;;
            2)
                prompt_and_close_ports
                break_end no_wait
                ;;
            3)
                # 在这里调用新的“开放所有端口”函数
                open_all_ports
                break_end
                ;;
            4)
                # 在这里调用新的“关闭所有端口”函数
                close_all_ports
                break_end
                ;;
            5)
                prompt_and_add_to_whitelist
                break_end
                ;;
            6)
                prompt_and_add_to_blacklist
                break_end
                ;;
            7)
                prompt_and_remove_ip_rules
                break_end
                ;;
            11)
                allow_ping
                break_end
                ;;
            12)
                deny_ping
                break_end
                ;;
            13)
                start_ddos_protection
                break_end
                ;;
            14)
                stop_ddos_protection
                break_end
                ;;
            15)
                block_country_ip
                break_end
                ;;
            16)
                allow_only_country_ip
                break_end
                ;;
            17)
                unblock_country_ip
                break_end
                ;;
            99)
                clear
                gran_menu_title "[S] 当前 INPUT 链规则"
                iptables -L INPUT -n --line-numbers
                break_end
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

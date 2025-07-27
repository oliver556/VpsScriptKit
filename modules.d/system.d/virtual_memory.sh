#!/bin/bash

### =================================================================================
# @名称:         virtual_memory.sh
# @功能描述:     修改虚拟内存大小的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-27
# @修改日期:     2025-07-27
#
# @许可证:       MIT
### =================================================================================

### === 导入修改虚拟内存大小 === ###
source "$ROOT_DIR/shell_scripts/system/virtual_memory.sh"

### === 修改虚拟内存大小 主菜单 === ###
#
# @描述
#   本函数用于显示修改虚拟内存大小主菜单。
#
# @示例
#   system_virtual_memory_menu
###
system_virtual_memory_menu() {
    is_user_root || return

    while true; do
        clear
        sub_menu_title "⚙️  修改虚拟内存大小"
        echo -e "${LIGHT_CYAN}当前虚拟内存: ${LIGHT_WHITE}$swap_info"
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}修改虚拟内存大小"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回主菜单"
        print_echo_line_3
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
            # 返回主菜单
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

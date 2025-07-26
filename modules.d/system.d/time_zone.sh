#!/bin/bash

### =================================================================================
# @名称:         time_zone.sh
# @功能描述:     修改系统时区的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入修改系统时区 === ###
source "$ROOT_DIR/shell_scripts/system/time_zone.sh"

### === 修改系统时区 主菜单 === ###
#
# @描述
#   本函数用于显示系统时区主菜单。
#
# @示例
#   system_time_zone_menu
###
system_time_zone_menu() {
    is_user_root

    while true; do
        clear
        sub_menu_title "🖥️  系统时间信息"

        # 系统当前时区
        timezone=$(system_info_current_timezone)
        # 系统当前时间
        current_time=$(date "+%Y-%m-%d %I:%M %p")

        # 显示系统当前时区
        echo -e "${LIGHT_CYAN}系统当前时区: ${LIGHT_WHITE}$timezone"
        # 显示系统当前时间
        echo -e "${LIGHT_CYAN}系统当前时间: ${LIGHT_WHITE}$current_time"
        echo -e "${LIGHT_CYAN}时区切换: ${LIGHT_WHITE}$current_time"
        gran_menu_title "[A] 亚洲"
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}中国上海              ${LIGHT_CYAN}2.  ${LIGHT_WHITE}中国香港"
        echo -e "${LIGHT_CYAN}3.  ${LIGHT_WHITE}日本东京              ${LIGHT_CYAN}4.  ${LIGHT_WHITE}韩国首尔"
        echo -e "${LIGHT_CYAN}5.  ${LIGHT_WHITE}新加坡                ${LIGHT_CYAN}6.  ${LIGHT_WHITE}印度加尔各答"
        echo -e "${LIGHT_CYAN}7.  ${LIGHT_WHITE}阿联酋迪拜            ${LIGHT_CYAN}8.  ${LIGHT_WHITE}澳大利亚悉尼"
        echo -e "${LIGHT_CYAN}9.  ${LIGHT_WHITE}泰国曼谷"
        gran_menu_title "[B] 欧洲"
        echo -e "${LIGHT_CYAN}11. ${LIGHT_WHITE}英国伦敦时间          ${LIGHT_CYAN}12. ${LIGHT_WHITE}法国巴黎时间"
        echo -e "${LIGHT_CYAN}13. ${LIGHT_WHITE}德国柏林时间          ${LIGHT_CYAN}14. ${LIGHT_WHITE}俄罗斯莫斯科时间"
        echo -e "${LIGHT_CYAN}15. ${LIGHT_WHITE}荷兰尤特赖赫特时间    ${LIGHT_CYAN}16. ${LIGHT_WHITE}西班牙马德里时间"
        gran_menu_title "[C] 美洲"
        echo -e "${LIGHT_CYAN}21. ${LIGHT_WHITE}美国西部时间          ${LIGHT_CYAN}22. ${LIGHT_WHITE}美国东部时间"
        echo -e "${LIGHT_CYAN}23. ${LIGHT_WHITE}加拿大时间            ${LIGHT_CYAN}24. ${LIGHT_WHITE}墨西哥时间"
        echo -e "${LIGHT_CYAN}25. ${LIGHT_WHITE}巴西时间              ${LIGHT_CYAN}26. ${LIGHT_WHITE}阿根廷时间"
        gran_menu_title "[D] 其他"
        echo -e "${LIGHT_CYAN}31. ${LIGHT_WHITE}UTC全球标准时间"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回主菜单"
        print_echo_line_3
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                system_time_zone_main "Asia/Shanghai"
                break_end ;;
            2)
                system_time_zone_main "Asia/Hong_Kong"
                break_end ;;
            3)
                system_time_zone_main "Asia/Tokyo"
                break_end ;;
            4)
                system_time_zone_main "Asia/Seoul"
                break_end ;;
            5)
                system_time_zone_main "Asia/Singapore"
                break_end ;;
            6)
                system_time_zone_main "Asia/Kolkata"
                break_end ;;
            7)
                system_time_zone_main "Asia/Dubai"
                break_end ;;
            8)
                system_time_zone_main "Australia/Sydney"
                break_end ;;
            9)
                system_time_zone_main "Asia/Bangkok"
                break_end ;;
            11)
                system_time_zone_main "Europe/London"
                break_end ;;
            12)
                system_time_zone_main "Europe/Paris"
                break_end ;;
            13)
                system_time_zone_main "Europe/Berlin"
                break_end ;;
            14)
                system_time_zone_main "Europe/Moscow"
                break_end ;;
            15)
                system_time_zone_main "Europe/Amsterdam"
                break_end ;;
            16)
                system_time_zone_main "Europe/Madrid"
                break_end ;;
            21)
                system_time_zone_main "America/Los_Angeles"
                break_end ;;
            22)
                system_time_zone_main "America/New_York"
                break_end ;;
            23)
                system_time_zone_main "America/Vancouver"
                break_end ;;
            24)
                system_time_zone_main "America/Mexico_City"
                break_end ;;
            25)
                system_time_zone_main "America/Sao_Paulo"
                break_end ;;
            26)
                system_time_zone_main "America/Argentina/Buenos_Aires"
                break_end ;;
            31)
                system_time_zone_main "UTC"
                break_end ;;
            # 返回主菜单
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

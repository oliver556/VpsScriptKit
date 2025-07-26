#!/bin/bash

### =================================================================================
# @名称:         reinstall.sh
# @功能描述:     一键重装安装的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入一键重装系统 === ###
source "$ROOT_DIR/shell_scripts/system/reinstall.sh"

### === 一键重装安装 主菜单 === ###
#
# @描述
#   本函数用于显示一键重装安装主菜单。
#
# @示例
#   system_reinstall_menu
###
system_reinstall_menu() {
    local system_param="$1"
    while true; do
        clear
        sub_menu_title "⚙️  一键重装系统"
        echo -e "${BOLD_RED}注意: 重装系统有风险失联，不放这心者慎用。重装预计花费15分钟，请提前备份数据。"
        echo -e "${GREY}感谢 MollyLau 大佬 和 bin456789 大佬 的脚本支持！${LIGHT_WHITE} "
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}Debian 12            ${LIGHT_CYAN}2.  ${LIGHT_WHITE}Debian 11 ${BOLD_YELLOW}★${LIGHT_WHITE}"
        echo -e "${LIGHT_CYAN}3.  ${LIGHT_WHITE}Debian 10            ${LIGHT_CYAN}4.  ${LIGHT_WHITE}Debian 9"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}11. ${LIGHT_WHITE}Ubuntu 24.04         ${LIGHT_CYAN}12. ${LIGHT_WHITE}Ubuntu 22.04 ${BOLD_YELLOW}★${LIGHT_WHITE}"
        echo -e "${LIGHT_CYAN}13. ${LIGHT_WHITE}Ubuntu 20.04         ${LIGHT_CYAN}14. ${LIGHT_WHITE}Ubuntu 18.04"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}21. ${LIGHT_WHITE}CentOS 10            ${LIGHT_CYAN}22. ${LIGHT_WHITE}CentOS 9"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}31. ${LIGHT_WHITE}Alpine Linux"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}41. ${LIGHT_WHITE}Windows 11           ${LIGHT_CYAN}42. ${LIGHT_WHITE}Windows 10"
        echo -e "${BOLD_GREY}43. ${LIGHT_WHITE}Windows 7            ${LIGHT_CYAN}44. ${LIGHT_WHITE}Windows Server 2022"
        echo -e "${LIGHT_CYAN}45. ${LIGHT_WHITE}Windows Server 2019  ${LIGHT_CYAN}46. ${LIGHT_WHITE}Windows Server 2016"
        print_echo_line_1
        if [ "$system_param" = "dd" ]; then
            echo -e "${LIGHT_CYAN}0. ${LIGHT_WHITE}退出脚本"
            print_echo_line_3
        else
            echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回上一级菜单"
            print_echo_line_3
        fi
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # Debian 12
            1)
                system_reinstall_main "Debian 12"
                break_end no_wait ;;
            # Debian 11
            2)
                system_reinstall_main "Debian 11"
                break_end no_wait ;;
            # Debian 10
            3)
                system_reinstall_main "Debian 10"
                break_end no_wait ;;
            # Debian 9
            4)
                system_reinstall_main "Debian 9"
                break_end no_wait ;;
            # Ubuntu 24.04
            11)
                system_reinstall_main "Ubuntu 24.04"
                break_end no_wait ;;
            # Ubuntu 22.04
            12)
                system_reinstall_main "Ubuntu 22.04"
                break_end no_wait ;;
            # Ubuntu 20.04
            13)
                system_reinstall_main "Ubuntu 20.04"
                break_end no_wait ;;
            # Ubuntu 18.04
            14)
                system_reinstall_main "Ubuntu 18.04"
                break_end no_wait ;;
            # CentOS 10
            21)
                system_reinstall_main "CentOS 10"
                break_end no_wait ;;
            # CentOS 9
            22)
                system_reinstall_main "CentOS 9"
                break_end no_wait ;;
            # Alpine Linux
            31)
                system_reinstall_main "Alpine Linux"
                break_end no_wait ;;
            # Windows 11
            41)
                system_reinstall_main "Windows 11"
                break_end no_wait ;;
            # Windows 10
            42)
                system_reinstall_main "Windows 10"
                break_end no_wait ;;
            # Windows 7
            43)
                # system_reinstall_main "Windows 7";;
                clear
                echo "暂不支持 Windows 7 重装系统，请使用 Windows 10 或 Windows Server 2022 重装系统"
                sleep 2
                break_end no_wait ;;
            # Windows Server 2022
            44)
                system_reinstall_main "Windows Server 2022"
                break_end no_wait ;;
            # Windows Server 2019
            45)
                system_reinstall_main "Windows Server 2019"
                break_end no_wait ;;
            # Windows Server 2016
            46)
                system_reinstall_main "Windows Server 2016"
                break_end no_wait ;;

            # 返回主菜单
            0)
                if [ "$system_param" = "dd" ]; then
                    clear
                    exit 0
                else
                    break
                fi
                ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

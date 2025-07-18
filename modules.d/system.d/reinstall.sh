#!/bin/bash

### === 脚本描述 === ###
# 名称： reinstall.sh
# 功能： 一键重装安装
# 作者：
# 创建日期：
# 许可证：MIT

### === 导入一键重装系统 === ###

source "$ROOT_DIR/shell_scripts/system/reinstall.sh"

### === 一键重装安装 主菜单 === ###
system_reinstall_menu() {
    while true; do
        clear
        title="🖥️  一键重装系统"
        printf "${LIGHT_CYAN}"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        printf "| %-${width_48}s |\n" "$title"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        echo -e "${BOLD_RED}注意: 重装系统有风险失联，不放这心者慎用。重装预计花费15分钟，请提前备份数据。"
        echo -e "${GREY}感谢 MollyLau 大佬 和 bin456789 大佬 的脚本支持！${WHITE} "
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}1.  ${WHITE}Debian 12            ${LIGHT_CYAN}2.  ${WHITE}Debian 11 ${BOLD_YELLOW}★${WHITE}"
        echo -e "${LIGHT_CYAN}3.  ${WHITE}Debian 10            ${LIGHT_CYAN}4.  ${WHITE}Debian 9"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}11. ${WHITE}Ubuntu 24.04         ${LIGHT_CYAN}12. ${WHITE}Ubuntu 22.04 ${BOLD_YELLOW}★${WHITE}"
        echo -e "${LIGHT_CYAN}13. ${WHITE}Ubuntu 20.04         ${LIGHT_CYAN}14. ${WHITE}Ubuntu 18.04"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}21. ${WHITE}CentOS 10            ${LIGHT_CYAN}22. ${WHITE}CentOS 9"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}31. ${WHITE}Alpine Linux"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}41. ${WHITE}Windows 11           ${LIGHT_CYAN}42. ${WHITE}Windows 10"
        echo -e "${BOLD_GREY}43. ${WHITE}Windows 7            ${LIGHT_CYAN}44. ${WHITE}Windows Server 2022"
        echo -e "${LIGHT_CYAN}45. ${WHITE}Windows Server 2019  ${LIGHT_CYAN}46. ${WHITE}Windows Server 2016"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}0. ${WHITE}返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

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
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
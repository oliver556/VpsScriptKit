#!/bin/bash

### === 脚本描述 === ###
# 名称： base.sh
# 功能： 基础工具
# 作者：
# 创建日期：2025-07-18
# 许可证：MIT

### === 基础工具 主菜单 === ###
base_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  基础工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}curl 下载工具        ${LIGHT_CYAN}2.  ${WHITE}wget 下载工具"
        echo -e "${LIGHT_CYAN}3.  ${WHITE}htop 系统监控工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}11. ${WHITE}nano 文本编辑器"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}31. ${WHITE}全部安装             ${LIGHT_CYAN}32. ${WHITE}全部卸载"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # curl 下载工具
            1)
                clear
                install curl
                clear
                echo -e "${BOLD_GREEN}curl 下载工具安装成功！${WHITE}"
                curl --help
                break_end ;;
            # wget 下载工具
            2)
                clear
                install wget
                clear
                echo -e "${BOLD_GREEN}wget 下载工具安装成功！${WHITE}"
                wget --help
                break_end ;;
            # htop 系统监控工具
            3)
                clear
                install htop
                clear
                htop
                break_end ;;
            # nano 文本编辑器
            11)
                clear
			    install nano
                cd /
                clear
                nano -h
                cd ~
                break_end ;;
            # 全部安装
            31)
                clear
                if ! ask_to_continue; then
                    continue
                fi
                install curl wget htop nano
                break_end ;;
            # 全部卸载
            32)
                clear
                if ! ask_to_continue; then
                    continue
                fi
                uninstall curl wget htop nano
                break_end ;;
            # 返回主菜单
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
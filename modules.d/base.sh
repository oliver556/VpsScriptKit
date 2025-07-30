#!/bin/bash

### =================================================================================
# @名称:         base.sh
# @功能描述:     基础工具的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-18
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 基础工具 主菜单 === ###
#
# @描述
#   本函数用于显示基础工具主菜单。
#
# @示例
#   base_menu
###
base_menu() {
    while true; do
        clear
        sub_menu_title "🛠️  基础工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}curl 下载工具        ${LIGHT_CYAN}2.  ${LIGHT_WHITE}wget 下载工具"
        echo -e "${LIGHT_CYAN}3.  ${LIGHT_WHITE}htop 系统监控工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}11. ${LIGHT_WHITE}nano 文本编辑器"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}21. ${LIGHT_WHITE}iPerf3 网络测试工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}31. ${LIGHT_WHITE}全部安装             ${LIGHT_CYAN}32. ${LIGHT_WHITE}全部卸载"
        break_menu_options "host"
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # curl 下载工具
            1)
                clear
                install curl
                clear
                echo -e "${BOLD_GREEN}curl 下载工具安装成功！${LIGHT_WHITE}"
                curl --help
                break_end ;;
            # wget 下载工具
            2)
                clear
                install wget
                clear
                echo -e "${BOLD_GREEN}wget 下载工具安装成功！${LIGHT_WHITE}"
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
            # iPerf3 网络测试工具
            21)
                clear
                echo_info "正在安装 iPerf3 网络测试工具... \n "
                apt-get install iperf3 -y
                echo_success "\niPerf3 网络测试工具安装成功！"
                break_end ;;
            # 全部安装
            31)
                clear
                if ! ask_to_continue; then
                    continue
                fi
                install curl wget htop nano
                apt-get install iperf3 -y
                break_end ;;
            # 全部卸载
            32)
                clear
                if ! ask_to_continue; then
                    continue
                fi
                uninstall curl wget htop nano
                break_end ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

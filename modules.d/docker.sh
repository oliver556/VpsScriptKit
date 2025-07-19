#!/bin/bash

### === 脚本描述 === ###
# 名称： docker.sh
# 功能： Docker 管理
# 作者：
# 创建日期：2025-07-16
# 许可证：MIT

docker_menu() {
    while true; do
        clear
        sub_menu_title "🐳  Docker 管理"
        print_echo_line_1
        echo "${BOLD_GREY}1. ${WHITE}安装更新 Docker 环境"
        print_echo_line_1
        echo "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
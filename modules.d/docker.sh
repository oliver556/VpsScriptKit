#!/bin/bash

### === 脚本描述 === ###
# 名称： docker.sh
# 功能： Docker 管理
# 作者：
# 创建日期：2025-07-16
# 许可证：MIT

source "$ROOT_DIR/shell_scripts/docker/install.sh"
source "$ROOT_DIR/shell_scripts/docker/uninstall.sh"
source "$ROOT_DIR/shell_scripts/docker/global_status.sh"
source "$ROOT_DIR/modules.d/docker.d/ps.sh"

docker_menu() {
    while true; do
        clear
        sub_menu_title "🐳  Docker 管理"
        print_echo_line_1
        echo "${LIGHT_CYAN}1.  ${WHITE}安装更新Docker环境  ${BOLD_YELLOW}★${WHITE}"
        echo "${LIGHT_CYAN}2.  ${WHITE}查看Docker全局状态  ${BOLD_YELLOW}★${WHITE}"
        print_echo_line_1
        echo "${LIGHT_CYAN}3.  ${WHITE}Docker容器管理 ▶"
        echo "${BOLD_GREY}4.  ${WHITE}Docker镜像管理 ▶"
        echo "${BOLD_GREY}5.  ${WHITE}Docker网络管理 ▶"
        echo "${BOLD_GREY}6.  ${WHITE}Docker卷管理 ▶"
        print_echo_line_1
        echo "${BOLD_GREY}7.  ${WHITE}清除无用docker容器和镜像网络数据卷 ▶"
        print_echo_line_1
        echo "${LIGHT_CYAN}8.  ${WHITE}卸载Docker环境"
        print_echo_line_1
        echo "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                clear
                docker_install_main
                sleep 1
                break_end no_wait ;;
            2)
                clear
                docker_global_status_main
                break_end
                ;;
            3)
                docker_ps_menu
                break_end no_wait
                ;;
            8)
                clear
                docker_uninstall_main
                break_end
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

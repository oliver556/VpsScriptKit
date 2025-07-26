#!/bin/bash

### =================================================================================
# @名称:         docker.sh
# @功能描述:     Docker 管理
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-16
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入 Docker 安装 脚本 === ###
source "$ROOT_DIR/shell_scripts/docker/install.sh"

### === 导入 Docker 卸载 脚本 === ###
source "$ROOT_DIR/shell_scripts/docker/uninstall.sh"

### === 导入 Docker 全局状态 脚本 === ###
source "$ROOT_DIR/shell_scripts/docker/global_status.sh"

### === 导入 Docker 容器管理 脚本 === ###
source "$ROOT_DIR/modules.d/docker.d/ps.sh"

### === Docker 主菜单 === ###
#
# @描述
#   本函数用于显示 Docker 主菜单。
#
# @示例
#   docker_menu
###
docker_menu() {
    while true; do
        clear
        sub_menu_title "🐳  Docker 管理"
        print_echo_line_1
        echo "${LIGHT_CYAN}1.  ${LIGHT_WHITE}安装更新Docker环境  ${BOLD_YELLOW}★${LIGHT_WHITE}"
        echo "${LIGHT_CYAN}2.  ${LIGHT_WHITE}查看Docker全局状态  ${BOLD_YELLOW}★${LIGHT_WHITE}"
        print_echo_line_1
        echo "${LIGHT_CYAN}3.  ${LIGHT_WHITE}Docker容器管理 ▶"
        echo "${BOLD_GREY}4.  ${LIGHT_WHITE}Docker镜像管理 ▶"
        echo "${BOLD_GREY}5.  ${LIGHT_WHITE}Docker网络管理 ▶"
        echo "${BOLD_GREY}6.  ${LIGHT_WHITE}Docker卷管理 ▶"
        print_echo_line_1
        echo "${BOLD_GREY}7.  ${LIGHT_WHITE}清除无用docker容器和镜像网络数据卷 ▶"
        print_echo_line_1
        echo "${LIGHT_CYAN}8.  ${LIGHT_WHITE}卸载Docker环境"
        print_echo_line_1
        echo "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回主菜单"
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

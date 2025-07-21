#!/bin/bash


### =================================================================================
# @名称:         node_building.sh
# @功能描述:     一个用于管理 VPS 的脚本工具。
# @作者:         Vskit (vskit@vskit.com)
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-20
#
# @许可证:       MIT
### =================================================================================

source "$ROOT_DIR/shell_scripts/node_building/node_building.sh"

### === 节点搭建脚本合集 主菜单 === ###
node_building_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  节点搭建脚本合集"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}伊朗版3X-UI面板一键脚本 ${BOLD_YELLOW}★${WHITE}      ${LIGHT_CYAN}2.  ${WHITE}新版X-UI面板一键脚本"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # 伊朗版3X-UI面板一键脚本
            1)
                node_building_main "3x_ui"
                break_end ;;
            # 新版X-UI面板一键脚本
            2)
                node_building_main "x_ui"
                break_end no_wait;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
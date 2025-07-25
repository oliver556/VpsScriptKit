#!/bin/bash

### =================================================================================
# @名称:         node_building.sh
# @功能描述:     节点搭建脚本合集
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-20
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入节点搭建脚本合集 脚本 === ###
source "$ROOT_DIR/shell_scripts/node_building/node_building.sh"

### === 节点搭建脚本合集 主菜单 === ###
#
# @描述
#   本函数用于显示节点搭建脚本合集主菜单。
#
# @示例
#   node_building_menu
###
node_building_menu() {
    while true; do
        clear
        sub_menu_title "🏗️  节点搭建脚本合集"
        gran_menu_title "[A] 节点面板"
        echo -e "${LIGHT_CYAN}1.  ${WHITE}伊朗版3X-UI面板一键脚本 ${BOLD_YELLOW}★${WHITE}      ${LIGHT_CYAN}2.  ${WHITE}新版X-UI面板一键脚本"
        gran_menu_title "[B] 节点工具"
        echo -e "${LIGHT_CYAN}11.  ${WHITE}TCP调优工具"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单                                               ${LIGHT_CYAN}#"
        print_echo_line_3
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # 伊朗版3X-UI面板一键脚本
            1)
                node_building_main "3x_ui"
                break_end no_wait;;
            # 新版X-UI面板一键脚本
            2)
                node_building_main "x_ui"
                break_end no_wait;;
            # TCP调优工具
            11)
                node_building_main "tcp_tuning"
                break_end no_wait;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

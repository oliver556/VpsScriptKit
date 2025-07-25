#!/bin/bash

### =================================================================================
# @名称:         advanced.sh
# @功能描述:     进阶工具的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-18
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入证书管理 === ###
source "$ROOT_DIR/modules.d/advanced.d/manage.sh"

### === 进阶工具 主菜单 === ###
#
# @描述
#   本函数用于显示进阶工具主菜单。
#
# @示例
#   advanced_menu
###
advanced_menu() {
    while true; do
        clear
        sub_menu_title "🚀  进阶工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}SSL 证书管理         ${LIGHT_CYAN}2.  ${WHITE}暂未定"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_3
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                advanced_manage_menu
                break_end no_wait;;

            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

#!/bin/bash

### === 脚本描述 === ###
# 名称： advanced.sh
# 功能： 进阶工具
# 作者：
# 创建日期：2025-07-18
# 许可证：MIT

### === 导入证书管理 === ###
source "$ROOT_DIR/modules.d/advanced.d/manage.sh"

### === 进阶工具 主菜单 === ###
advanced_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  进阶工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}SSL 证书管理         ${LIGHT_CYAN}2.  ${WHITE}暂未定"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
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
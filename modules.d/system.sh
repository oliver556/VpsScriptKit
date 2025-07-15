#!/bin/bash

### === 脚本描述 === ###
# 名称： system.sh
# 功能： 系统工具
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

source "$ROOT_DIR/shell_scripts/system/system_info.sh"
source "$ROOT_DIR/shell_scripts/system/system_update.sh"
source "$ROOT_DIR/shell_scripts/system/system_clean.sh"

system_menu() {
    while true; do
        clear
        title="🖥️  系统工具"
        printf "${BLUE}+%${width_40}s+${RESET}\n" | tr ' ' '-'
        printf "${BLUE}| %-${width_48}s |${RESET}\n" "$title"
        printf "${BLUE}+%${width_40}s+${RESET}\n" | tr ' ' '-'
        echo " 1. 系统信息查询         2. 系统更新"
        echo -e "${BLUE}------------------------------------------${RESET}"
        echo " 0. 返回主菜单"
        echo -e "${BLUE}------------------------------------------${RESET}"
        echo ""
        read -p "👉 请输入操作编号: " sys_choice

        case "$sys_choice" in
            1)
                system_info_main
                break_end;;
            2)
                system_update_main
                break_end;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
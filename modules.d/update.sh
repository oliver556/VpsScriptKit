#!/bin/bash

### === 脚本描述 === ###
# 名称： update.sh
# 功能： 更新脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

# ==============================================================================
# == 通用导入
# 获取当前脚本所在的真实目录 (例如 /opt/VpsScriptKit/modules.d)
CURRENT_SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
# 获取项目根目录 (即当前脚本目录的上一级)
PROJECT_ROOT=$(dirname "$CURRENT_SCRIPT_DIR")
# 从项目根目录出发，引用 init.sh
source "$PROJECT_ROOT/lib/init.sh"
# ==============================================================================

update_now() {
    echo -e "${GREEN_BOLD}正在更新...${RESET_BOLD}"
    sleep 1
    echo -e "${GREEN_BOLD}更新完成！${RESET_BOLD}"
    sleep 1
    clear
}

update_menu() {
    clear

    while true; do
        clear
        echo -e "🖥️  系统信息查询"
        echo -e "${CYAN}-------------${RESET}"
        echo "1. 现在更新            2. 开启自动更新            3. 关闭自动更新"
        echo -e "${BLUE}-------------${RESET}"
        echo " 0. 返回主菜单"
        echo -e "${BLUE}-------------${RESET}"
        echo ""
        read -p "👉 请输入操作编号: " sys_choice

        case "$sys_choice" in
            1)
               
                break_end;;
            2)
                break_end;;
            3)
                break_end;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

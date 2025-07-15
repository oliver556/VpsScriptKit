#!/bin/bash

### === 脚本描述 === ###
# 名称： system.sh
# 功能： 系统工具
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd) # 获取当前脚本所在目录

# 引用 config 中 color.sh 中的颜色变量
source "$SCRIPT_DIR/config/color.sh"
# 导入 public 中的 public_lib.sh
source "$SCRIPT_DIR/lib/public/public_lib.sh"
# 导入 shell_script 中的 system_info.sh
source "$SCRIPT_DIR/shell_scripts/system/system_info.sh"

system_menu() {
    while true; do
        clear
        echo -e "🖥️  系统信息查询"
        echo -e "${CYAN}-------------${RESET}"
        echo " 1. 系统信息查询"
        echo -e "${BLUE}-------------${RESET}"
        echo " 0. 返回主菜单"
        echo -e "${BLUE}-------------${RESET}"
        echo ""
        read -p "👉 请输入操作编号: " sys_choice

        case "$sys_choice" in
            1)
                system_info_main
                break_end;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
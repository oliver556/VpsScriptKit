#!/bin/bash

### === 脚本描述 === ###
# 名称： test.sh
# 功能： 测试工具
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

source "$ROOT_DIR/shell_scripts/test/test.tool.sh"

test_menu() {
    while true; do
        clear
        echo -e "🧪  常用测试脚本"
        echo -e "${CYAN}-------------${RESET}"
	    echo -e "${CYAN}IP及解锁状态检测"${RESET}
        echo " 1. IP质量测试"
        echo -e "${BLUE}-------------${RESET}"
        echo " 0. 返回主菜单"
        echo -e "${BLUE}-------------${RESET}"
        echo ""
        read -p "👉 请输入操作编号: " sys_choice

        case "$sys_choice" in
            1)
                clear
                echo -e "正在运行 IP质量测试..."
                bash <(curl -Ls Check.Place) -I
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
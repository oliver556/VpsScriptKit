#!/bin/bash

### === 脚本描述 === ###
# 名称： uninstall.sh
# 功能： 卸载脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd) # 获取当前脚本所在目录

# 引用 config 中 color.sh 中的颜色变量
source "$SCRIPT_DIR/config/color.sh"

INSTALL_DIR="/opt/VpsScriptKit"

uninstall_main() {
    while true; do
        clear
        echo -e "🔄 卸载 vsk 脚本"
        echo -e "${CYAN}-------------${RESET}"
        echo "将彻底卸载 VpsScriptKit 脚本，不影响你其他功能"
        echo -e "${BLUE}-------------${RESET}"
        read -e -p "确定继续吗？(Y/N): " choice

        case "$choice" in
            [Yy])
                clear
                echo -e "${CYAN}🧹 正在清理卸载...${RESET}"
                rm -rf "$INSTALL_DIR"
                rm -rf "/usr/local/bin/vsk"
                sleep 1
                echo ""
                echo -e "${CYAN}✅ 脚本已卸载，江湖有缘再见！${RESET}"
                sleep 2
                clear
                break_end;;
            [Nn])
                clear
                echo -e "${YELLOW_BOLD}已取消卸载。${RESET}"
                sleep 1
                clear
                break_end;;
            *)
                echo -e "${RED_BOLD}❌ 无效选项，请输入 Y 或 N。${RESET}"
                sleep 1
                clear
                break_end;;
        esac
    done
}

uninstall_main
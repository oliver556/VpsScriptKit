#!/bin/bash

### === 脚本描述 === ###
# 名称： uninstall.sh
# 功能： 卸载脚本
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
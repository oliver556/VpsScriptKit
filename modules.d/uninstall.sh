#!/bin/bash

### === 脚本描述 === ###
# 名称： uninstall.sh
# 功能： 卸载脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

INSTALL_DIR="/opt/VpsScriptKit"

### === 卸载脚本 主菜单 === ###
uninstall_main() {
    while true; do
        clear
        echo -e "🔄 卸载 vsk 脚本"
        echo -e "${LIGHT_CYAN}-------------${WHITE}"
        echo "将彻底卸载 VpsScriptKit 脚本，不影响你其他功能"
        echo -e "${BLUE}-------------${WHITE}"
        read -e -p "确定继续吗？(Y/N): " choice

        case "$choice" in
            [Yy])
                clear
                echo -e "${LIGHT_CYAN}🧹 正在清理卸载...${WHITE}"
                rm -rf "$INSTALL_DIR"
                rm -rf "/usr/local/bin/vsk"
                rm -rf "/usr/local/bin/v"
                sleep 1
                echo ""
                echo -e "${LIGHT_CYAN}✅ 脚本已卸载，江湖有缘再见！${WHITE}"
                sleep 2
                clear
                break_end no_wait ;;
            [Nn])
                clear
                echo -e "${YELLOW_BOLD}已取消卸载。${WHITE}"
                sleep 1
                clear
                break_end no_wait ;;
            *)
                echo -e "${RED_BOLD}❌ 无效选项，请输入 Y 或 N。${WHITE}"
                sleep 1
                clear
                break_end no_wait ;;
        esac
    done
}

uninstall_main
#!/bin/bash

### === 脚本描述 === ###
# 名称： update.sh
# 功能： 更新脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

### === 导入更新脚本 === ###
source "$ROOT_DIR/shell_scripts/vsk/uninstall.sh"

### === 主菜单 === ###
vsk_update_menu() {
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
                vsk_uninstall_utils "yes"
                break_end no_wait ;;
            [Nn])
                clear
                echo -e "${YELLOW_BOLD}已取消卸载。${WHITE}"
                sleep 1
                clear
                break_end no_wait
                break ;;
            *)
                echo -e "${RED_BOLD}❌ 无效选项，请输入 Y 或 N。${WHITE}"
                sleep 1
                clear
                break_end no_wait
        esac
    done
}
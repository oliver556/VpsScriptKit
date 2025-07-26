#!/bin/bash

### =================================================================================
# @名称:         uninstall.sh
# @功能描述:     卸载 vsk 脚本
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入卸载 vsk 脚本 === ###
source "$ROOT_DIR/shell_scripts/vsk/uninstall.sh"

### === 卸载 vsk 脚本 主菜单 === ###
#
# @描述
#   本函数用于显示卸载 vsk 脚本主菜单。
#
# @示例
#   vsk_uninstall_menu
###
vsk_uninstall_menu() {
    while true; do
        clear
        echo -e "🔄 卸载 vsk 脚本"
        echo -e "${LIGHT_CYAN}-------------${LIGHT_WHITE}"
        echo "将彻底卸载 VpsScriptKit 脚本，不影响你其他功能"
        echo -e "${BLUE}-------------${LIGHT_WHITE}"
        read -e -p "确定继续吗？(Y/N): " choice

        case "$choice" in
            [Yy])
                clear
                vsk_uninstall_utils "yes"
                break_end no_wait ;;
            [Nn])
                clear
                echo -e "${YELLOW_BOLD}已取消卸载。${LIGHT_WHITE}"
                sleep 1
                clear
                break ;;
            *)
                echo -e "${RED_BOLD}❌ 无效选项，请输入 Y 或 N。${LIGHT_WHITE}"
                sleep 1
                clear
                break_end no_wait ;;
        esac
    done
}

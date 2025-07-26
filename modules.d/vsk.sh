#!/bin/bash

### =================================================================================
# @名称:         vsk.sh
# @功能描述:     脚本工具
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-17
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入脚本工具 脚本 === ###
source "$ROOT_DIR/modules.d/vsk.d/update.sh"

### === 导入脚本卸载 脚本 === ###
source "$ROOT_DIR/modules.d/vsk.d/uninstall.sh"

### === 导入脚本操作日志 脚本 === ###
source "$ROOT_DIR/modules.d/vsk.d/vsk_log.sh"

### === 导入 v 命令参考用例 脚本 === ###
source "$ROOT_DIR/shell_scripts/vsk/v_info.sh"

### === 脚本工具 主菜单 === ###
#
# @描述
#   本函数用于显示脚本工具主菜单。
#
# @示例
#   vsk_menu
###
vsk_menu() {
    while true; do
        clear
        sub_menu_title "🧰  脚本工具"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}脚本更新"
        echo -e "${LIGHT_CYAN}2.  ${WHITE}脚本卸载"
        echo -e "${LIGHT_CYAN}3.  ${WHITE}脚本操作日志"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}66. ${BOLD_GREEN}v${WHITE} 命令高级用法${WHITE}"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                vsk_update_menu
                # 检查下一级是否发来了重启信号
                if [[ $? -eq 10 ]]; then
                    # 继续向上传递信号，中断当前菜单
                    return 10
                fi
                break_end no_wait ;;
            2)
                vsk_uninstall_menu
                ;;
            3)
                vsk_log_tool_menu
                break_end no_wait ;;
            66)
                clear
                v_info
                break_end ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

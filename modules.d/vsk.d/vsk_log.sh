#!/bin/bash

### =================================================================================
# @名称:         vsk_log.sh
# @功能描述:     脚本操作日志交互界面
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-22
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入脚本操作日志 脚本 === ###
source "$ROOT_DIR/shell_scripts/vsk/log.sh"

### === 按模块筛选日志 === ###
#
# @描述
#   本函数用于按模块筛选日志。
#
# @示例
#   vsk_log_filter_menu
###
vsk_log_filter_menu() {
    # 用户输入了有效的模块编号
    while true; do
        clear
        sub_menu_title "📋 按模块筛选日志"
        print_echo_line_1

        vsk_log_filter_modules
        
        print_echo_line_1
        echo -e "0  ) 返回上一级"
        print_echo_line_1
        read -rp "👉 请输入选项编号来筛选日志: " choice

        if [[ "$choice" == "0" ]]; then
            break # 跳出筛选菜单的循环，返回
        elif [[ -n "${modules[$choice]}" ]]; then
            vsk_log_filter
            # 显示完结果后，暂停等待用户按键
            break_end
            # 结束后不再循环，直接返回上一级菜单
            break
        else
            echo "❌ 无效选项，请重新输入。" && sleep 1
        fi
    done
}

### === 脚本操作日志 主菜单 === ###
#
# @描述
#   本函数用于显示脚本操作日志主菜单。
#
# @示例
#   vsk_log_tool_menu
###
vsk_log_tool_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  脚本操作日志"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1. ${WHITE}查看最近日志（最新在上）"
        echo -e "${LIGHT_CYAN}2. ${WHITE}按模块筛选日志"
        echo -e "${LIGHT_CYAN}3. ${WHITE}清空日志文件"
        echo -e "${LIGHT_CYAN}4. ${WHITE}导出日志副本"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                vsk_log_view
                break_end
                ;;
            2)
                vsk_log_filter_menu
                break_end no_wait
                ;;
            3)
                vsk_log_clear
                break_end
                ;;
            4)
                vsk_log_export
                break_end
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
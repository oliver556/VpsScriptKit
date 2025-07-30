#!/bin/bash

### =================================================================================
# @名称:         update_source.sh
# @功能描述:     切换系统更新源的菜单。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-30
# @修改日期:     2025-07-30
#
# @许可证:       MIT
### =================================================================================

source "$ROOT_DIR/shell_scripts/system/update_source.sh"

### === 切换系统更新源 主菜单 === ###
#
# @描述
#   本函数用于显示切换系统更新源主菜单。
#
# @示例
#   system_update_source_menu
###
system_update_source_menu() {
    # is_user_root || return

    while true; do
        clear
        sub_menu_title "⚙️  切换系统更新源"

        # 显示当前源的部分信息以供参考
        echo "当前源 (部分示例):"
        grep -v '^#' /etc/apt/sources.list | grep 'deb ' | head -n 2
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}中国大陆 - 默认源 (中科大 USTC)"
        echo -e "${LIGHT_CYAN}2.  ${LIGHT_WHITE}中国大陆 - 阿里源 (Aliyun)"
        echo -e "${LIGHT_CYAN}3.  ${LIGHT_WHITE}中国大陆 - 教育网 (清华 TUNA)"
        echo -e "${LIGHT_CYAN}4.  ${LIGHT_WHITE}中国大陆 - LinuxMirrors 源"
        echo -e "${LIGHT_CYAN}5.  ${LIGHT_WHITE}海外地区 - 官方源"
        break_menu_options "host"
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1) _change_sources "ustc"; break_end no_wait ;;
            2) _change_sources "aliyun"; break_end no_wait ;;
            3) _change_sources "edu"; break_end no_wait ;;
            4) _change_sources "linuxmirrors"; break_end no_wait ;;
            5) _change_sources "official"; break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

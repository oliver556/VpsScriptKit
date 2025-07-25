#!/bin/bash

### =================================================================================
# @名称:         update.sh
# @功能描述:     更新 vsk 脚本
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入更新脚本 === ###
source "$ROOT_DIR/shell_scripts/vsk/update.sh"

### === 更新 vsk 脚本 主菜单 === ###
#
# @描述
#   本函数用于显示更新 vsk 脚本主菜单。
#
# @示例
#   vsk_update_menu
###
vsk_update_menu() {
    clear

    while true; do
        clear
        title="🖥️  更新脚本"
        printf "${LIGHT_CYAN}"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        printf "| %-${width_48}s |\n" "$title"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'

        # 获取最新版本号
        local LATEST_SCRIPT_VERSION
        LATEST_SCRIPT_VERSION=$(vsk_update_get_latest_version_tag)

        if [[ "${SCRIPT_VERSION}" == "${LATEST_SCRIPT_VERSION}" ]]; then
            echo -e "${BOLD_GREEN}✅ 您当前已是最新版本 ${SCRIPT_VERSION}。${LIGHT_WHITE}"
        else
            echo -e "${BOLD_GREEN}🚀  发现新版本！"
            echo -e "${LIGHT_CYAN}当前版本：${SCRIPT_VERSION}       最新版本：${YELLOW}${LATEST_SCRIPT_VERSION}${LIGHT_WHITE}"
        fi

        print_echo_line_1
        echo -e "${LIGHT_CYAN}1. ${LIGHT_WHITE}现在更新            ${BOLD_GREY}2. ${LIGHT_WHITE}开启自动更新            ${BOLD_GREY}3. ${LIGHT_WHITE}关闭自动更新"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0. ${LIGHT_WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                vsk_update_now "$LATEST_SCRIPT_VERSION"
                # 立刻检查是否存在重启的“信件”
                if [[ -f /tmp/vsk_restart_flag ]]; then
                    # 销毁信件，以免重复触发
                    rm -f /tmp/vsk_restart_flag
                    # 将“信件”转换为“重启信号”，并立即返回，中断当前菜单
                    return 10
                fi
                break_end no_wait ;;
            2)
                enable_auto_update ;;
            3)
                disable_auto_update ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

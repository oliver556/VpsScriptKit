#!/bin/bash

### === 脚本描述 === ###
# 名称： update.sh
# 功能： 更新脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

### === 导入更新脚本 === ###
source "$ROOT_DIR/shell_scripts/vsk/update.sh"

### === 主菜单 === ###
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
            echo -e "${BOLD_GREEN}✅ 您当前已是最新版本 ${SCRIPT_VERSION}。${WHITE}"
        else 
            echo -e "${BOLD_GREEN}🚀  发现新版本！"
            echo -e "${LIGHT_CYAN}当前版本：${SCRIPT_VERSION}       最新版本：${YELLOW}${LATEST_SCRIPT_VERSION}${WHITE}"
        fi

        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}1. ${WHITE}现在更新            ${BOLD_GREY}2. ${WHITE}开启自动更新            ${BOLD_GREY}3. ${WHITE}关闭自动更新"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}0. ${WHITE}返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                vsk_update_main
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
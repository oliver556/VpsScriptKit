#!/bin/bash

### === 脚本描述 === ###
# 名称： docker.sh
# 功能： Docker 管理
# 作者：
# 创建日期：2025-07-16
# 许可证：MIT

docker_menu() {
    while true; do
        clear
        # 标题，补充一个docker 的 icons
        title="🐳  Docker 管理"
        printf "${LIGHT_CYAN}"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        printf "| %-${width_42}s |\n" "$title"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo " ${LIGHT_CYAN}1. ${WHITE}安装更新 Docker 环境"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo " 0. 返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
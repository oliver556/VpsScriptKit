#!/bin/bash

### === 脚本描述 === ###
# 名称： system.sh
# 功能： 系统工具
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

### === 导入系统信息查询 === ###
source "$ROOT_DIR/shell_scripts/system/system_info.sh"

### === 导入系统更新 === ###
source "$ROOT_DIR/modules.d/update.sh"

### === 导入系统清理 === ###
source "$ROOT_DIR/shell_scripts/system/system_clean.sh"

### === 系统工具 主菜单 === ###
system_menu() {
    while true; do
        clear
        title="🖥️  系统工具"
        printf "${LIGHT_CYAN}"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        printf "| %-${width_48}s |\n" "$title"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}1.  ${WHITE}系统信息查询"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}2.  ${WHITE}系统更新             ${LIGHT_CYAN}3. ${WHITE}系统清理"
        echo -e "${LIGHT_YELLOW}4.  ${WHITE}系统用户管理"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_YELLOW}11. ${WHITE}修改登录密码         ${LIGHT_YELLOW}12. ${WHITE}修改 SSH 端口"
        echo -e "${LIGHT_YELLOW}13. ${WHITE}修改主机名           ${LIGHT_YELLOW}14. ${WHITE}修改虚拟内存大小"
        echo -e "${LIGHT_YELLOW}15. ${WHITE}修改系统时区"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_YELLOW}66. ${WHITE}一条龙系统调优             "
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}0. ${WHITE}返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # 系统信息查询
            1)
                system_info_main
                break_end;;
            # 系统更新
            2)
                system_info_main
                break_end no_wait ;;
            # 系统清理
            3)
                system_clean_main
                break_end no_wait ;;
            # 系统用户管理
            4)
                break_end no_wait ;;
            # 修改登录密码
            11)
                echo -e "${BOLD_YELLOW}设置你的登录密码...${WHITE}"
                passwd
                break_end no_wait ;;
            # 修改 SSH 端口
            12)
                break_end no_wait ;;
            # 修改主机名
            13)
                break_end no_wait ;;
            # 修改虚拟内存大小
            14)
                break_end no_wait ;;
            # 修改系统时区
            15)
                break_end no_wait ;;
            # 一条龙系统调优
            66)
                break_end no_wait ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
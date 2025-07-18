#!/bin/bash

### === 脚本描述 === ###
# 名称: public_lib.sh
# 功能: 公共函数库
# 作者: 
# 创建日期: 2025-07-15
# 许可证: MIT

# 函数: 提示用户按任意键继续
break_end() {
    echo ""
    echo -e "${GREEN}操作完成${WHITE}"
    if [[ "$1" != "no_wait" ]]; then
        echo "按任意键继续..."
        read -n 1 -s -r -p ""
        echo ""
    fi
    clear
}

# 函数: 询问用户是否继续 (返回状态码版本)
# 返回值:
#   0 - 如果用户选择 Y/y (继续)
#   1 - 如果用户选择其他任意键 (取消)
ask_to_continue() {
    echo # 保持界面美观
    echo -e "按 ${BOLD_RED}(Y/y)${WHITE} 键确认操作，按其它任意键返回。"
    echo 
    read -p "$(echo -e "${LIGHT_CYAN}👉 请输入你的选择: ${WHITE}")" user_choice
    
    case "$user_choice" in
      y|Y)
        return 0  # 返回 0, 代表“成功/继续”
        ;;
      *)
        echo -e "\n${BOLD_YELLOW}操作已取消，正在返回...${WHITE}"
        sleep 1
        return 1  # 返回 1, 代表“失败/取消”
        ;;
    esac
}

# 快速启动脚本
vskit() {
    clear
	cd ~
	bash v
}

# 判断当前用户是否为 root 用户
is_user_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${BOLD_YELLOW}提示: 该功能需要使用 root 用户才能运行此脚本"
		sleep 1
		break_end
		vskit
    fi
}
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
    echo -e "${GREEN}操作完成${RESET}"
    if [[ "$1" != "no_wait" ]]; then
        echo "按任意键继续..."
        read -n 1 -s -r -p ""
        echo ""
    fi
    clear
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
        echo -e "${YELLOW}提示: 该功能需要使用 root 用户才能运行此脚本"
		sleep 1
		break_end
		vskit
    fi
}
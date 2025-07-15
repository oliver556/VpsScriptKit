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
    echo -e "操作完成"
	echo "按任意键继续..."
	read -n 1 -s -r -p ""
	echo ""
	clear
}
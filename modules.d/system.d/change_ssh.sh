#!/bin/bash

### === 脚本描述 === ###
# 名称： change_ssh.sh
# 功能： 修改 SSH 端口
# 作者：
# 创建日期：
# 许可证：MIT

### === 导入修改 SSH 端口 脚本 === ###
source "$ROOT_DIR/shell_scripts/system/change_ssh.sh"

### === 修改 SSH 端口 主菜单 === ###
change_ssh_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  SSH 端口修改"
    done
}
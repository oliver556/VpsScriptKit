#!/bin/bash

### === 脚本描述 === ###
# 名称： uninstall.sh
# 功能： 卸载脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

### === 卸载脚本判断 === ###
vsk_uninstall_utils() {
    # 是否卸载判断，默认不卸载
    local Delete="$1"
    if [ "$Delete" == "yes" ]; then
        vsk_uninstall_yes
    elif [ "$Delete" == "no" ]; then
        echo "不卸载"
    fi
}

### === 卸载脚本方法 === ###
vsk_uninstall_yes() {
    echo -e "${LIGHT_CYAN}🧹 正在清理卸载...${WHITE}"
    rm -rf "$INSTALL_DIR"
    rm -rf "/usr/local/bin/vsk"
    rm -rf "/usr/local/bin/v"
    sleep 1
    echo ""
    echo -e "${LIGHT_CYAN}✅ 脚本已卸载，江湖有缘再见！${WHITE}"
    sleep 2
    clear
}

### === 卸载脚本方法 === ###
vsk_uninstall_no() {
    echo "不卸载"
}
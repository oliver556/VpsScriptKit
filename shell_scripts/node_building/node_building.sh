#!/bin/bash

### =================================================================================
# @名称:         node_building.sh
# @功能描述:     节点搭建脚本合集 utils 函数
# @作者:         Vskit (vskit@vskit.com)
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-20
#
# @许可证:       MIT
### =================================================================================

set_node_building_utils() {
	clear
	local NODE_BUILDING="$1"
    case "$NODE_BUILDING" in
        "3x_ui")
            install_3x_ui
            break_end
            ;;
        "x_ui")
            install_x_ui
            break_end
            ;;
    esac
}

### === 伊朗版3X-UI面板一键脚本 主函数 === ###
install_3x_ui() {
    clear
    echo -e "${BOLD_LIGHT_GREEN}正在安装伊朗版 3X-UI 面板一键脚本...${WHITE}"
	bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
}

### === 新版X-UI面板一键脚本 主函数 === ###
install_x_ui() {
    clear
    echo -e "${BOLD_LIGHT_GREEN}正在安装新版 X-UI 面板一键脚本...${WHITE} \n "
	bash <(curl -Ls https://raw.githubusercontent.com/oliver556/x-ui/main/install.sh)
}

### === 修改系统时区 主函数 === ###
node_building_main() {
    local NODE_BUILDING="$1"
	set_node_building_utils "$NODE_BUILDING"
}

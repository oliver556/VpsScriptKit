#!/bin/bash

### =================================================================================
# @名称:         handle_args.sh
# @功能描述:     一个用于处理命令行参数的脚本。
# @作者:         Vskit (vskit@vskit.com)
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-20
#
# @使用方法:     ./handle_args.sh [参数]
# @参数选项:
#   -h, --help      显示此帮助信息。
#   -u, --update    更新脚本到最新版本。
#   -d, --uninstall 卸载脚本。
#   -v, --version   显示脚本版本。
#
# @依赖:         bash
# @许可证:       MIT
### =================================================================================

### === 处理命令行参数 === ###
#
# @描述
#   本函数接收一个命令行参数作为输入，根据参数执行相应的操作。
#
# @参数 $1: 字符串 - 命令行参数。
#
# @返回值
#   成功返回 0。
#
# @示例
#   handle_args "-u"
###
handle_args (){
    local args="$1"
    case "$args" in
        -u|--update)
            echo -e "${BOLD_YELLOW}检测到更新请求，正在调用安装/更新程序...${WHITE}"
            log_action "[system.sh]" "系统更新"
            system_update_main
            exit 0
            ;;
        -d|--uninstall)
            echo -e "${BOLD_YELLOW}检测到卸载请求，正在调用卸载程序...${WHITE}"
            vsk_uninstall_utils "yes"
            exit 0
            ;;
        -v|--version)
            echo "${BOLD_CYAN}${SCRIPT_VERSION}${WHITE}"
            exit 0
            ;;
        -h|--help)
            grep -E '@(使用方法|参数选项)|^#   -' "$0" | sed -e 's/^#//' -e 's/@/  /'
            exit 0
            ;;
    esac
}

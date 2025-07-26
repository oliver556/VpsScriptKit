#!/bin/bash

### =================================================================================
# @名称:         handle_args.sh
# @功能描述:     一个用于处理命令行参数的脚本。
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-20
#
# @使用方法:     ./handle_args.sh [参数]
# @参数选项:
#   h, help                      显示此帮助信息
#   v, version                   显示脚本版本
#   install, add, 安装            安装
#   remove, uninstall, 卸载       卸载
#   update, 更新                  系统更新
#   docker [install|uninstall]   管理 Docker
#   dd, 重装                      重装系统
#
# @依赖:         bash
# @许可证:       MIT
### =================================================================================

### === 导入系统更新模块 === ###
source "$ROOT_DIR/modules.d/system.d/system_update.sh"

### === 导入系统清理模块 === ###
source "$ROOT_DIR/modules.d/system.d/system_clean.sh"

### === 导入重装系统模块 === ###
source "$ROOT_DIR/modules.d/system.d/reinstall.sh"

### === 导入 v 命令参考用例 === ###
source "$ROOT_DIR/shell_scripts/vsk/v_info.sh"

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
        h|help)
            # grep -E '@(使用方法|参数选项)|^#   -' "$0" | sed -e 's/^#//' -e 's/@/  /'
            v_info
            exit 0
            ;;
        v|version)
            echo "${BOLD_CYAN}${SCRIPT_VERSION}${WHITE}"
            exit 0
            ;;
        #==========================================
        install|add|安装)
            shift
            install "$@"
            ;;
        remove|uninstall|卸载)
            shift
            uninstall "$@"
            ;;
        update|更新)
            echo -e "${BOLD_YELLOW}检测到系统更新请求，正在调用系统更新程序...${WHITE}"
            log_action "[system.sh]" "系统更新"
            system_update_main
            exit 0
            ;;
        clean|清理)
            system_clean_main
            exit 0
            ;;
        dd|重装)
            system_reinstall_menu "dd"
            exit 0
            ;;
        #==========================================
        ssl)
            shift
            case "$1" in
                "")
                    clear
                    echo -e "${BOLD_GREEN}检测到 SSL 安装请求...${WHITE}"
                    sleep 2
                    # 要删除的代码
                    exit 1
                    # get_ssl_interaction
                    ;;

                ps)
                    clear
                    echo -e "${BOLD_GREEN}检测到 SSL 安装请求...${WHITE}"
                    ;;

                *)
                    echo "错误: 无效的 ssl 命令 '$2'"
                    echo "用法: v ssl [ps]"
                    exit 1
                    ;;
            esac
            ;;

        docker)
            shift
            case "$1" in
                install)
                    clear
                    echo -e "${BOLD_GREEN}检测到 Docker 安装请求...${WHITE}"
                    docker_install_main
                    sleep 2
                    exit 0
                ;;
                uninstall)
                    clear
                    echo -e "${BOLD_RED}检测到 Docker 卸载请求...${WHITE}"
                    docker_global_status_main
                    sleep 2
                    exit 0
                ;;
                *)
                    echo "错误: 无效的 docker 命令 '$2'"
                    echo "用法: v docker [install|uninstall]"
                    exit 1
                    ;;
            esac
            ;;

        *)
            echo "错误: 无效的命令 '$1'"
            echo "用法: v -h"
            exit 1
            ;;
    esac
}

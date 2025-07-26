#!/bin/bash

### =================================================================================
# @名称:         v_info.sh
# @功能描述:      v 命令参考用例。
# @作者:         oliver556
# @版本:         1.0.0
# @创建日期:     2025-07-26
# @修改日期:     2025-07-26
#
# @许可证:       MIT
### =================================================================================

### === 打印 v 命令参考用例 === ###
#
# @描述
#   本函数用于打印 v 命令参考用例。
#
# @示例
#   v_info
###
v_info() {
    clear
    sub_menu_title "🧰  v 命令参考用例"
    print_echo_line_1
    echo_info_light "v [参数]"
    print_echo_line_1
    gran_menu_title "[A]"
    echo_info_light "启动脚本            v"
    echo_info_light "脚本帮助            v h | help"
    echo_info_light "脚本版本            v v | version"
    gran_menu_title "[B]"
    echo_info_light "安装软件包          v install | v add       | v 安装"
    echo_info_light "卸载软件包          v remove  | v uninstall | v 卸载"
    echo_info_light "更新系统            v update                | v 更新"
    echo_info_light "清理系统垃圾        v clean                 | v 清理"
    echo_info_light "DD 重装系统         v dd                    | v 重装"
    echo_info_light "Docker 安装         v docker install"
    echo_info_light "Docker 卸载         v docker uninstall"
    echo_info_light "域名证书申请        v ssl"
    echo_info_light "域名证书状态        v ssl ps"
    gran_menu_title "[C]"
    echo_info_light "BBR3控制面板        v bbr3"
    echo_info_light "设置虚拟内存        v swap 2048"
    
}
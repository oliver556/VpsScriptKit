#!/bin/bash

### =================================================================================
# @名称:         vps_script_kit.sh
# @功能描述:     一个用于管理 VPS 的脚本工具。
# @作者:         oliver556
# @版本:         0.0.18
# @创建日期:     2025-07-15
# @修改日期:     2025-07-21
#
# @使用方法:     v -[参数]
# @参数选项:
#   -h, --help                       显示此帮助信息
#   -v, --version                    显示脚本版本
#   -u, --update                     系统更新
#   -ssl                             安装 SSL 证书
#   -dd                              一键重装系统
#   -docker [install|uninstall]      管理 Docker
#
# @依赖:         bash, wget, curl, git
# @许可证:       MIT
### =================================================================================

### === 通用导入 === ###
source "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/lib/public/init_lib.sh"

### === 模块目录 === ###
MODULE_DIR="$ROOT_DIR/modules.d"

### === 处理 v 快捷命令行参数 === ###
handle_args "$@"

### === 日志记录 === ###
log_action "Vps Script Kit 脚本 已启动。"

### === 模块映射表 === ###
# 格式： [菜单编号]="模块文件名:要调用的函数名"
declare -A modules=(
  [1]="system.sh:system_menu:系统工具"
  [2]="base.sh:base_menu:基础工具"
  [3]="advanced.sh:advanced_menu:进阶工具"
  [4]="docker.sh:docker_menu:Docker 管理"
  [9]="node_building.sh:node_building_menu:节点搭建脚本"
  [8]="test.sh:test_menu:测试脚本合集"
  [99]="vsk.sh:vsk_menu:脚本工具"
)

### === 动态加载所有在映射表中的模块 === ###
# 这个循环只在脚本启动时运行一次

for key in "${!modules[@]}"; do
  IFS=":" read -r file func _ <<< "${modules[$key]}"
  path="$MODULE_DIR/$file"
  if [[ -f "$path" ]]; then
    source "$path"
    if ! declare -F "$func" >/dev/null; then
      echo "❌ 模块 $file 加载失败：未定义函数 $func"
      exit 1
    fi
  else
    echo "❌ 模块文件缺失：$file"
    exit 1
  fi
done

### === 主菜单循环 === ###

while true; do
    clear

    main_menu_title " 🚀 一款全功能的 Linux 管理脚本！    | ${SCRIPT_VERSION}"
    echo -e "${LIGHT_YELLOW}# ──────────── Tip: 命令行输入 ${BOLD_GREEN}v${WHITE} ${LIGHT_YELLOW}可快速启动脚本 ──────────── #${WHITE}"
    # 📋 菜单项
    print_echo_line_1
    printf "${LIGHT_CYAN}1. ${WHITE} 系统工具     ▶ \n"
    printf "${LIGHT_CYAN}2. ${WHITE} 基础工具     ▶ \n"
    printf "${LIGHT_CYAN}3. ${WHITE} 进阶工具     ▶ \n"
    printf "${LIGHT_CYAN}4. ${WHITE} Docker 管理  ▶ \n"
    print_echo_line_1
    printf "${LIGHT_CYAN}8. ${WHITE} 测试脚本合集 ▶ \n"
    printf "${LIGHT_CYAN}9. ${WHITE} 节点搭建脚本 ▶ \n"
    print_echo_line_1
    printf "${LIGHT_CYAN}99.${WHITE} 脚本工具 ▶\n"
    print_echo_line_1
    printf "${LIGHT_CYAN}0. ${WHITE} 退出程序 \n"
    print_echo_line_1

    # 🔽 用户输入
    read -rp "$(echo -e "${LIGHT_CYAN}👉 请输入你的选择: ${WHITE}")" choice

    if [[ -z "$choice" ]]; then
        # -z 判断字符串是否为空，如果为空则为 true
        echo -e "${YELLOW}❌ 无效选项，请重新输入。${WHITE}" && sleep 1
    elif [[ "$choice" = "0" ]]; then
        clear
        echo
        print_echo_line_1
        echo -e "${BOLD_GREEN}感谢使用，再见！${WHITE}"
        print_echo_line_1
        sleep 1
        clear
        exit "$EXIT_SUCCESS"
    elif [[ -n "${modules[$choice]}" ]]; then
        IFS=":" read -r _ func _ <<< "${modules[$choice]}"
        "$func"
        # 检查是否收到了最终的重启信号
        if [[ $? -eq 10 ]]; then
            echo "收到重启信号，正在无缝重启脚本..."
            sleep 1
            # 使用 exec 实现原地重启
            exec "$0" "$@"
        fi
    else
        echo -e "${YELLOW}❌ 无效选项，请重新输入。${WHITE}" && sleep 1
    fi
done

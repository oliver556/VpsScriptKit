#!/bin/bash

### === 脚本描述 === ###
# 名称: vps_script_kit.sh
# 功能: 交互式列举、管理、卸载 systemd 服务
# 作者: 
# 创建日期: 2025-07-15
# 许可证: MIT

### === 通用导入 === ###
source "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/lib/public/init_lib.sh"

### === 导入更新脚本 === ###
source "$ROOT_DIR/modules.d/update.sh"

### === 模块目录 === ###
MODULE_DIR="$ROOT_DIR/modules.d"

### === 命令行参数【进阶用法】 === ###
# 检查命令行参数
if [[ "$1" == "--update" ]]; then
    update_now
    exit 0
fi

### === 模块映射表 === ###
# 格式： [菜单编号]="模块文件名:要调用的函数名"

declare -A modules=(
  [1]="system.sh:system_menu"
  [2]="docker.sh:docker_menu"
  [8]="test.sh:test_menu"
  [00]="vsk.sh:vsk_menu"
)

### === 动态加载所有在映射表中的模块 === ###
# 这个循环只在脚本启动时运行一次

for key in "${!modules[@]}"; do
  IFS=":" read -r file func <<< "${modules[$key]}"
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
    
    # # 标题
    title="${BOLD}🚀 一款全功能的 Linux 管理脚本！ | By Vskit | ${SCRIPT_VERSION}"
    # 🔷 ASCII 标题框
    printf "${LIGHT_CYAN}"
    printf "+%${width_60}s+\n" "" | tr ' ' '-'
    printf "| %-${width_71}s |\n" "$title"
    printf "+%${width_60}s+\n" "" | tr ' ' '-'

    echo -e "${LIGHT_CYAN}# == Tip: 命令行输入 ${YELLOW}v${WHITE} ${LIGHT_CYAN}可快速启动脚本 =======================#${WHITE}"
    # 📋 菜单项
    printf "${LIGHT_CYAN}%s${WHITE}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${LIGHT_CYAN}1. ${WHITE} 系统工具     ▶ \n"
    printf "${LIGHT_CYAN}2. ${WHITE} Docker 管理  ▶ \n"
    printf "${LIGHT_CYAN}8. ${WHITE} 测试脚本合集 ▶ \n"
    printf "${LIGHT_CYAN}%s${WHITE}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${LIGHT_CYAN}00.${WHITE} 脚本工具 \n"
    printf "${LIGHT_CYAN}%s${WHITE}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${LIGHT_CYAN}0. ${WHITE} 退出程序 \n"
    printf "${LIGHT_CYAN}%s${WHITE}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"

    # 🔽 用户输入
    read -p "$(echo -e "${LIGHT_CYAN}👉 请输入你的选择: ${WHITE}")" choice

    if [[ "$choice" = "0" ]]; then
        echo
        echo -e "${BOLD_GREEN}感谢使用，再见！${WHITE}"
        sleep 1
        clear
        exit $EXIT_SUCCESS
    elif [[ -n "${modules[$choice]}" ]]; then
        IFS=":" read -r _ func <<< "${modules[$choice]}"
        "$func"
    else
        echo -e "${YELLOW}❌ 无效选项，请重新输入。${WHITE}" && sleep 1
    fi
done

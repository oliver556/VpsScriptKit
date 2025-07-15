#!/bin/bash

### === 脚本描述 === ###
# 名称: vps_script_kit.sh
# 功能: 交互式列举、管理、卸载 systemd 服务
# 作者: 
# 创建日期: 2025-07-15
# 许可证: MIT

# ==============================================================================
# == 通用导入
# ==============================================================================
source "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/lib/public/init_lib.sh"

# 模块目录
MODULE_DIR="$ROOT_DIR/modules.d"

# ==============================================================================
# == 模块加载
# ==============================================================================

# ==============================================================================
# == ✅ 模块映射表
# == 格式： [菜单编号]="模块文件名:要调用的函数名"
# ==============================================================================

declare -A modules=(
  [1]="system.sh:system_menu"
  [8]="test.sh:test_menu"
  [00]="update.sh:update_menu"
)

# ==============================================================================
# == ✅ 动态加载所有在映射表中的模块
# == 这个循环只在脚本启动时运行一次
# ==============================================================================

for key in "${!modules[@]}"; do
  IFS=":" read -r file func <<< "${modules[$key]}"
  path="$MODULE_DIR/$file"
  echo "$path"
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

# ==============================================================================
# == ✅ 主菜单循环
# ==============================================================================

while true; do
    clear
    
    # 标题
    title="🚀 一款全功能的 Linux 管理脚本！ |  By JAMISON  |  v$SCRIPT_VERSION"

    # 🔷 打印 ASCII 标题框（兼容所有终端）
    printf "${BLUE}+%${width_60}s+${RESET}\n" | tr ' ' '-'
    printf "${BLUE}| %-${width_71}s |${RESET}\n" "$title"
    printf "${BLUE}+%${width_60}s+${RESET}\n" | tr ' ' '-'
    # 命令行输入 v  可快速启动脚本
    echo -e "${BLUE}+--------------- 命令行输入 ${YELLOW}v${RESET} ${BLUE}可快速启动脚本 ----------------+${RESET}"
    # 📋 菜单项
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${BLUE}1. ${RESET} 系统工具     ▶ \n"
    printf "${BLUE}2. ${RESET} Docker 管理  ▶ \n"
    printf "${BLUE}8. ${RESET} 常用测试脚本 ▶ \n"
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${BLUE}00.${RESET} 脚本更新 \n"
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${BLUE}0. ${RESET} 退出程序 \n"
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"

    # 🔽 用户输入
    read -p "$(echo -e "${BLUE}👉 请输入选项编号: ${RESET}")" choice

    if [[ "$choice" = "0" ]]; then
        echo
        echo -e "${GREEN_BOLD}感谢使用，再见！${RESET_BOLD}"
        sleep 1
        clear
        exit $EXIT_SUCCESS
    elif [[ -n "${modules[$choice]}" ]]; then
        IFS=":" read -r _ func <<< "${modules[$choice]}"
        "$func"
    else
        echo -e "${YELLOW}❌ 无效选项，请重新输入。${RESET}" && sleep 1
    fi
done

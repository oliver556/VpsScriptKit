#!/bin/bash

### === 脚本描述 === ###
# 名称: vps_script_kit.sh
# 功能: 交互式列举、管理、卸载 systemd 服务
# 作者: 
# 创建日期: 2025-07-15
# 许可证: MIT

# ==============================================================================
# == 通用导入
# 获取当前脚本所在的真实目录 (例如 /opt/VpsScriptKit/modules.d)
CURRENT_SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
# 获取项目根目录 (即当前脚本目录的上一级)
PROJECT_ROOT=$(dirname "$CURRENT_SCRIPT_DIR")
# 从项目根目录出发，引用 init.sh
source "$PROJECT_ROOT/lib/init.sh"
# ==============================================================================

# 模块目录
MODULE_DIR="$SCRIPT_DIR/modules.d"

# ✅ 模块映射表
declare -A modules=(
  [1]="system.sh:system_menu"
  [9]="test.sh:test_menu"
  [00]="update.sh:update_menu"
)

# ✅ 加载所有模块
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

# ✅ 主菜单循环
while true; do
    clear
    
    # 标题
    title="🚀 一款全功能的 Linux 管理脚本！ | By JAMISON  |  v: $SCRIPT_VERSION"

    # 🔷 打印 ASCII 标题框（兼容所有终端）
    printf "${BLUE}+%${width_60}s+${RESET}\n" | tr ' ' '-'
    printf "${BLUE}| %-${width_60}s |${RESET}\n" "$title"
    printf "${BLUE}+%${width_60}s+${RESET}\n" | tr ' ' '-'

    # 📋 菜单项
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${BLUE}1. ${RESET} 系统工具  ▶ \n"
    printf "${BLUE}9. ${RESET} 常用测试脚本  ▶ \n"
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${BLUE}00.${RESET} 脚本更新 \n"
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"
    printf "${BLUE}0. ${RESET} 退出程序 \n"
    printf "${BLUE}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width_60+2))))"

    # 🔽 用户输入
    read -p "$(echo -e "${BLUE}👉 请输入选项编号: ${RESET}")" choice

    if [[ "$choice" = "0" ]]; then
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

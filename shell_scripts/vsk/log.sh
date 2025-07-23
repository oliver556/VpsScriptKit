#!/bin/bash

### =================================================================================
# @名称:         log.sh
# @功能描述:     一个用于记录脚本操作日志的脚本。
# @作者:         viplee
# @版本:         1.0.0
# @创建日期:     2025-07-22
# @修改日期:     2025-07-22
#
# @许可证:       MIT
### =================================================================================

### === 查看最近日志 === ###
vsk_log_view() {
    clear
    echo -e "\n📋 ${LIGHT_CYAN}最近日志记录（最多显示 30 条）：${WHITE}"
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        tac "$LOG_FILE" | head -n 30
    else
        echo "❌ 日志文件不存在或为空。"
    fi
}

### === 按模块筛选日志 模块列表 === ###
vsk_log_filter_modules() {
    # 动态生成菜单选项
    # 我们需要一个有序的列表来保证显示顺序和主菜单一致
    local menu_order=(1 2 3 4 8 9 99)
    for key in "${menu_order[@]}"; do
        # 检查该选项是否存在于 modules 数组中
        if [[ -n "${modules[$key]}" ]]; then
            # 从数组中解析出中文名和文件名
            IFS=":" read -r filename _ chinese_name <<< "${modules[$key]}"
            # 格式化输出，使其对齐美观
            printf "%-3s) %-20s \n" "$key" "$chinese_name"
        fi
    done
}

### === 按模块筛选日志 === ###
vsk_log_filter() {
    clear
    IFS=":" read -r filename _ _ <<< "${modules[$choice]}"

    echo -e "\n📋 ${LIGHT_CYAN}筛选模块 ${BOLD_GREEN}[$filename]${WHITE} ${LIGHT_CYAN}的日志（最多显示最新的 100 条）：${WHITE}"
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        grep --color=auto "\[$filename\]" "$LOG_FILE" | tail -n 100
    else
        echo "❌ 日志文件不存在或为空。"
    fi
}

### === 清空日志文件 === ###
vsk_log_clear() {
    clear
    read -p "${YELLOW}⚠️ 是否确认清空日志文件？(y/n): ${WHITE}" confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        > "$LOG_FILE"
        echo
        echo_success "✅ 日志文件已清空"
        log_action "[vsk_log]" "用户清空了日志文件"
    else
        echo_error "❌ 已取消清空操作"
    fi
}

### === 导出日志副本 === ###
# 在 log.sh 文件中

### === 导出日志副本 === ###
vsk_log_export() {
    clear
    echo_info "\n🔄 正在准备用于下载的日志副本...\n"
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        # 1. 定义一个带有唯一时间戳的文件名
        local backup_name="vps_script_kit_$(date +%Y%m%d_%H%M%S).log"

        # 2. 将日志文件复制到当前用户的家目录 (~)
        cp "$LOG_FILE" ~/"$backup_name"

        # 3. 给出清晰、可操作的提示信息
        echo_success "✅ 日志副本已成功导出！"
        echo -e "   ${BOLD_CYAN}文件位置: ${BOLD_GREEN}$(realpath ~/"$backup_name")${WHITE}" # realpath 会显示绝对路径
        echo ""
        echo -e "${BOLD_YELLOW}您现在可以在您的本地电脑上，打开一个新的终端窗口，使用以下命令来下载它：${WHITE}"
        # 假设用户名为 root，如果不是，用户需要自行替换
        echo_info "scp root@<您的服务器IP>:~/${backup_name} ."

        # 4. 同时，也在主日志中记录下这个导出事件
        log_action "[vsk_log]" "用户导出了日志副本到 ~/$backup_name"
    else
        echo "❌ 日志文件不存在或为空，无法导出。"
    fi
}

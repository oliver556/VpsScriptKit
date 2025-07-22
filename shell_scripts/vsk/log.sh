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
    local menu_order=(1 2 3 4 5 8 99)
    for key in "${menu_order[@]}"; do
        # 检查该选项是否存在于 modules 数组中
        if [[ -n "${modules[$key]}" ]]; then
            # 从数组中解析出中文名和文件名
            IFS=":" read -r filename _ chinese_name <<< "${modules[$key]}"
            # 格式化输出，使其对齐美观
            printf "  %-3s) %-20s (%s)\n" "$key" "$chinese_name" "$filename"
        fi
    done
}

### === 按模块筛选日志 === ###
vsk_log_filter() {
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
    read -p "⚠️ 是否确认清空日志文件？(y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        > "$LOG_FILE"
        echo "✅ 日志文件已清空"
        log_action "[vsk_log]" "用户清空了日志文件"
    else
        echo "❌ 已取消清空操作"
    fi
}

### === 导出日志副本 === ###
vsk_log_export() {
    echo -e "\n🔄 ${LIGHT_CYAN}导出日志副本...${WHITE}"
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        backup_name="vps_script_kit_$(date +%Y%m%d_%H%M%S).log"
        cp "$LOG_FILE" "$backup_name"
        echo_success "✅ ${LIGHT_CYAN}日志副本已保存到 ${BOLD_GREEN}$backup_name${WHITE}"
        log_action "[vsk_log]" "用户导出了日志副本到 $backup_name"
    else
        echo_error "❌ 日志文件不存在或为空，无法导出。"
    fi
}
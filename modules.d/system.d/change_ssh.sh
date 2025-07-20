#!/bin/bash

### === 脚本描述 === ###
# 名称： change_ssh.sh
# 功能： 修改 SSH 端口
# 作者：
# 创建日期：
# 许可证：MIT

### === 导入修改 SSH 端口 === ###

source "$ROOT_DIR/shell_scripts/system/change_ssh.sh"

### === 一键重装安装 主菜单 === ###
system_reinstall_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  SSH 端口修改"

        # 获取并显示当前端口
        current_port=$(_read_current_ssh_port)
        if [ -z "$current_port" ]; then
            current_port="22 (默认)"
        fi

        echo -e "当前活动的 SSH 端口是: \033[1;33m$current_port\033[0m"

        print_echo_line_1

        echo -e "${BOLD_YELLOW}请输入一个新的 SSH 端口号 (有效范围: 1-65535)。${WHITE}"
        read -p "输入 '0' 可以随时退出脚本: " new_port

        # 验证输入
        if [[ "$new_port" -eq 0 ]] 2>/dev/null; then
            info "用户选择退出。未作任何更改。"
            break
        fi

        if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
            warn "输入无效！请输入 1-65535 之间的数字。"
            sleep 2
            continue
        fi

        if [ "$new_port" == "$(echo $current_port | awk '{print $1}')" ]; then
            warn "新端口与当前端口相同，无需修改。"
            sleep 2
            continue
        fi
        
        # 最终确认
        print_echo_line_1
        warn "您即将把 SSH 端口修改为 \033[1;33m$new_port\033[0m。"
        warn "在继续前，请确保您有服务器的控制台访问权限（如 VNC/KVM）。"
        read -p "确认要执行此操作吗? (y/N): " confirm
        
        if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
            # 调用核心函数执行所有修改
            apply_new_port "$new_port"
            # 无论成功失败，都退出循环，因为操作已执行
            break
        else
            info "操作已取消。"
            sleep 2
            continue
        fi
    done
}
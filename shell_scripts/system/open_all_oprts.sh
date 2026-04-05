#! /bin/bash

### =================================================================================
# @名称:         open_all_ports
# @功能描述:     开放所有端口 (高风险操作)。
#                通过清空INPUT链规则并将默认策略设置为ACCEPT实现。
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-30
# @修改日期:     2025-07-30
#
# @许可证:       MIT
### =================================================================================

source "$ROOT_DIR/shell_scripts/system/general.sh"

### === 开放所有端口 (高风险操作) === ###
#
# @描述
#   本函数用于开放所有端口 (高风险操作)。
#   通过清空INPUT链规则并将默认策略设置为ACCEPT实现。
#
# @示例
#   open_all_ports
###
open_all_ports() {
    # 权限检查，确保是 root 用户
    is_user_root || return

    clear
    # 明确地向用户发出高风险警告
    echo -e "${BOLD_RED}警告：这是一个高风险操作！${NC}"
    echo "该操作将移除所有 INPUT 链的防火墙规则，并将默认策略设置为 ACCEPT。"
    echo "这意味着您的服务器将对所有新的入站连接请求完全开放，会显著增加安全风险。"
    echo -e "通常只在进行网络调试或确信内部网络安全时才使用此功能。"
    
    # 使用您已有的 ask_to_continue 函数进行二次确认
    if ! ask_to_continue "您确定要开放所有端口吗？"; then
        echo "操作已取消。"
        return
    fi

    echo ""
    echo_info "--> 正在清空 INPUT 链的所有规则..."
    iptables -F INPUT
    
    echo_info "--> 正在将 INPUT 链的默认策略设置为 ACCEPT..."
    iptables -P INPUT ACCEPT
    
    echo ""
    echo_success "所有端口已开放。防火墙处于默认接受（完全开放）状态。"
    
    # 调用我们之前重构的保存函数，使其持久化
    save_firewall_state
}
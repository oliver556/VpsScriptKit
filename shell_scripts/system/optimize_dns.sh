#! /bin/bash

### =================================================================================
# @名称:         optimize_dns.sh
# @功能描述:     优化 DNS 地址
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-27
# @修改日期:     2025-07-27
#
# @许可证:       MIT
### =================================================================================

### === 优化 DNS 地址 工具函数 === ###
#
# @描述
#   本函数用于优化 DNS 地址。
#
# @示例
#   set_dns
###
set_dns() {
    is_user_root || return

    echo -e "${LIGHT_YELLOW}正在应用DNS设置...${LIGHT_WHITE}"

    # 重要的持久化步骤：如果 resolv.conf 文件被锁定了，先解锁
    # chattr (change attribute) 是一个用于改变文件属性的 Linux 命令
    if [ -f /etc/resolv.conf ]; then
        chattr -i /etc/resolv.conf 2>/dev/null
    fi

    # 检查机器是否有可用的 IPv6 地址
    ipv6_available=0
    if [[ $(ip -6 addr | grep -c "inet6") -gt 0 ]]; then
        ipv6_available=1
        echo "检测到IPv6网络，将同时设置IPv6 DNS。"
    else
        echo "未检测到IPv6网络，仅设置IPv4 DNS。"
    fi

    # 写入 IPv4 DNS (使用 > 覆盖旧文件)
    echo "nameserver ${dns1_ipv4}" > /etc/resolv.conf
    echo "nameserver ${dns2_ipv4}" >> /etc/resolv.conf

    # 如果有 IPv6 地址，则追加写入 IPv6 DNS
    if [[ $ipv6_available -eq 1 ]]; then
        echo "nameserver ${dns1_ipv6}" >> /etc/resolv.conf
        echo "nameserver ${dns2_ipv6}" >> /etc/resolv.conf
    fi

    echo -e "${LIGHT_GREEN}DNS设置已更新！${NC}"
    echo "------------------------"
    cat /etc/resolv.conf
    echo "------------------------"

    # 询问用户是否要锁定文件以防止被覆盖
    read -p "${LIGHT_YELLOW}是否要锁定 /etc/resolv.conf 文件以防止被系统自动修改？(y/n): ${LIGHT_WHITE}" lock_choice
    if [[ "$lock_choice" == "y" || "$lock_choice" == "Y" ]]; then
        chattr +i /etc/resolv.conf
        echo -e "${LIGHT_GREEN}文件已锁定。${LIGHT_WHITE}"
    fi
}

### === 优化 DNS 地址 === ###
#
# @描述
#   本函数用于优化 DNS 地址。
#
# @示例
#   optimize_dns
###
optimize_dns_main() {
    clear
    is_user_root || return
}

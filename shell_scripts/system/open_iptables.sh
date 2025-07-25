#!/bin/bash

### =================================================================================
# @名称:         open_iptables.sh
# @功能描述:     打开所有端口
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-20
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 保存 iptables 规则 === ###
#
# @描述
#   本函数用于保存 iptables 规则。
#
# @示例
#   _save_iptables_rules
###
_save_iptables_rules() {
    # 1. 保存当前的防火墙规则
    mkdir -p /etc/iptables
	touch /etc/iptables/rules.v4
    # iptables-save > /etc/iptables/rules.v4: 将当前（也就是执行脚本时，端口还未被打开的）防火墙规则保存到一个文件中。
	iptables-save > /etc/iptables/rules.v4

    # 2. 设置一个定时任务 (cron job)，让系统在每次重启时恢复这些规则
	check_crontab_installed
	crontab -l | grep -v 'iptables-restore' | crontab - > /dev/null 2>&1
    # @reboot iptables-restore < /etc/iptables/rules.v4: 这行命令被添加到了系统的定时任务中，它的意思是“在系统每次启动时（@reboot），从指定文件中读取并恢复防火墙规则”。
	(crontab -l ; echo '@reboot iptables-restore < /etc/iptables/rules.v4') | crontab - > /dev/null 2>&1
}

### === 检查是否安装了 iptables === ###
#
# @描述
#   本函数用于检查是否安装了 iptables。
#
# @示例
#   _check_iptables_installed
###
_check_iptables_installed() {
    if ! command -v iptables > /dev/null 2>&1; then
        echo "iptables 未安装，正在安装..."
        apt-get install -y iptables
    fi
}

### === 打开所有端口 === ###
#
# @描述
#   本函数用于打开所有端口。
#
# @示例
#   open_iptables
###
open_iptables() {
    clear
    
    if ! is_user_root; then
        break_end
    fi
    
    _check_iptables_installed
    _save_iptables_rules

    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
	iptables -F

    ip6tables -P INPUT ACCEPT
	ip6tables -P OUTPUT ACCEPT
	ip6tables -P FORWARD ACCEPT
	ip6tables -F
}


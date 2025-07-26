#!/bin/bash

### =================================================================================
# @名称:         system_update.sh
# @功能描述:     系统更新的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 系统更新 工具函数 === ###
#
# @描述
#   本函数用于系统更新工具函数。
#
# @示例
#   system_update_utils
###
system_update_utils() {
    clear

	echo -e "${LIGHT_CYAN}正在更新系统...${LIGHT_WHITE}"
    echo -e "${LIGHT_CYAN}--------------------------------${LIGHT_WHITE}"
	sleep 1
	# Fedora, CentOS 8+, RHEL 8+
	if command -v dnf &>/dev/null; then
		dnf -y update
	# CentOS ≤7, RHEL ≤7, Amazon Linux
	elif command -v yum &>/dev/null; then
		yum -y update
	# Debian, Ubuntu, Mint, Kali 等
	elif command -v apt &>/dev/null; then
		fix_dpkg
		DEBIAN_FRONTEND=noninteractive apt update -y
		DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
	# Alpine Linux
	elif command -v apk &>/dev/null; then
		apk update && apk upgrade
	# Arch Linux, Manjaro 等
	elif command -v pacman &>/dev/null; then
		pacman -Syu --noconfirm
	# openSUSE, SUSE Linux Enterprise
	elif command -v zypper &>/dev/null; then
		zypper refresh
		zypper update
	# OpenWrt, LEDE, 嵌入式 Linux
	elif command -v opkg &>/dev/null; then
		opkg update
	else
		echo "未知的包管理器!"
		return
	fi
}

### === 系统更新 主函数 === ###
#
# @描述
#   本函数用于系统更新主函数。
#
# @示例
#   system_update_main
###
system_update_main() {
	clear
	if ! ask_to_continue; then
		return
	fi
    system_update_utils
}

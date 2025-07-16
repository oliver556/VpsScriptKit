#!/bin/bash

### === 脚本描述 === ###
# 名称： system_update.sh
# 功能： 系统更新
# 作者：
# 创建日期：
# 许可证：MIT

### === 系统更新 === ###
linux_update_utils() {
    clear
	echo -e "${YELLOW_BOLD}正在系统更新...${RESET}"
    echo -e "${BLUE}--------------------------------${RESET}"
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

### === 主函数 === ###
system_update_main() {
    linux_update_utils
}
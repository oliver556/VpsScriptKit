#!/bin/bash

### === 脚本描述 === ###
# 名称： time_zone.sh
# 功能： 修改系统时区
# 作者：
# 创建日期：2025-07-18
# 许可证：MIT

set_system_time_zone_utils() {
	clear
	local time_zone="$1"
	if grep -q 'Alpine' /etc/issue; then
		install tzdata
		cp /usr/share/zoneinfo/${time_zone} /etc/localtime
		hwclock --systohc
	else
		timedatectl set-timezone ${time_zone}
	fi
	echo
  echo -e "${BOLD_GREEN}时区已经设置为: $time_zone${WHITE}"
  log_action "[system.sh]" "修改系统时区"
	sleep 1
}

### === 修改系统时区 主函数 === ###
system_time_zone_main() {
	if ! is_user_root; then
        break_end
    fi

    local TIME_ZONE="$1"
	set_system_time_zone_utils "$TIME_ZONE"
}

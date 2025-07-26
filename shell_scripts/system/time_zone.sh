#!/bin/bash

### =================================================================================
# @名称:         time_zone.sh
# @功能描述:     修改系统时区
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-18
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 设置系统时区 工具函数 === ###
#
# @描述
#   本函数用于设置系统时区。
#
# @示例
#   set_system_time_zone_utils "Asia/Shanghai"
###
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
  echo -e "${BOLD_GREEN}时区已经设置为: $time_zone${LIGHT_WHITE}"
  log_action "[system.sh]" "修改系统时区"
	sleep 1
}

### === 修改系统时区 主函数 === ###
#
# @描述
#   本函数用于修改系统时区。
#
# @示例
#   system_time_zone_main "Asia/Shanghai"
###
system_time_zone_main() {
	if ! is_user_root; then
        break_end
    fi

    local TIME_ZONE="$1"
	set_system_time_zone_utils "$TIME_ZONE"
}

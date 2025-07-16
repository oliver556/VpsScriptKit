#!/bin/bash

### === 脚本描述 === ###
# 名称： system_info.sh
# 功能： 系统信息查询
# 作者：
# 创建日期：
# 许可证：MIT

### === 获取当前时区函数 === ###
current_timezone() {
	if grep -q 'Alpine' /etc/issue; then
	   date +"%Z %z"
	else
	   timedatectl | grep "Time zone" | awk '{print $3}'
	fi
}

### === 获取网络状态 === ###
output_status() {
	output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
		$1 ~ /^(eth|ens|enp|eno)[0-9]+/ {
			rx_total += $2
			tx_total += $10
		}
		END {
			rx_units = "Bytes";
			tx_units = "Bytes";
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "K"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "M"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "G"; }

			if (tx_total > 1024) { tx_total /= 1024; tx_units = "K"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "M"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "G"; }

			printf("%.2f%s %.2f%s\n", rx_total, rx_units, tx_total, tx_units);
		}' /proc/net/dev)

	rx=$(echo "$output" | awk '{print $1}')
	tx=$(echo "$output" | awk '{print $2}')

}

### === 系统信息查询 === ###
system_info_utils() {
    # ==========================================================
    # 主机名
	hostname=$(uname -n)

    # 操作系统版本
	os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')

    # Linux 内核版本
    kernel_version=$(uname -r)

    # ==========================================================
    # CPU 架构
	cpu_arch=$(uname -m)

    # CPU 型号 信息
    cpu_info=$(lscpu | awk -F': +' '/Model name:/ {print $2; exit}')

    # CPU 核心数
    cpu_cores=$(nproc)

    # CPU 频率
    cpu_freq=$(cat /proc/cpuinfo | grep "MHz" | head -n 1 | awk '{printf "%.1f GHz\n", $4/1000}')

    # ==========================================================
    # CPU 占用/使用率
	cpu_usage_percent=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f\n", (($2+$4-u1) * 100 / (t-t1))}' \
		<(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))
    
    # 系统负载 / CPU 负载
    load=$(uptime | awk '{print $(NF-2), $(NF-1), $NF}')

    # 物理内存
    mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2fM (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

    # 虚拟内存 / 交换分区
    swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')

    # 硬盘占用
    disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')

    # ==========================================================
	# 获取系统网络状态
	output_status
	
    # ==========================================================
    # 网络算法
	congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
	queue_algorithm=$(sysctl -n net.core.default_qdisc)

    # ==========================================================
    # 运营商
	isp_info=$(echo "$ipinfo" | grep 'org' | awk -F': ' '{print $2}' | tr -d '",')

    # DNS 地址
	dns_addresses=$(awk '/^nameserver/{printf "%s ", $2} END {print ""}' /etc/resolv.conf)

    # ==========================================================
    # 获取服务器 IPV4、IPV6 公网地址
    ip_address() {
        ipv4_address=$(curl -s https://ipinfo.io/ip && echo)
        ipv6_address=$(curl -s --max-time 1 https://v6.ipinfo.io/ip && echo)
    }

    ip_address
    # ==========================================================

    # 地理位置
	ipinfo=$(curl -s ipinfo.io)
	# 国家
	country=$(echo "$ipinfo" | grep 'country' | awk -F': ' '{print $2}' | tr -d '",')
	# 城市
	city=$(echo "$ipinfo" | grep 'city' | awk -F': ' '{print $2}' | tr -d '",')

    # 时区 / 当前时间
	timezone=$(current_timezone)
	current_time=$(date "+%Y-%m-%d %I:%M %p")
    
    # ==========================================================
    # 运行时间
	runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')
}

show_system_info() {
	clear

    echo -e "${BLUE}正在查询中，请稍后...${WHITE}"

    system_info_utils

    echo -e "${GREEN}查询完成${WHITE}"
    sleep 1
    clear
    
	echo ""
	echo -e "系统信息查询"
	echo -e "${LIGHT_CYAN}-------------"
	echo -e "${LIGHT_CYAN}主机名:       ${WHITE}$hostname"
	echo -e "${LIGHT_CYAN}系统版本:     ${WHITE}$os_info"
	echo -e "${LIGHT_CYAN}Linux版本:    ${WHITE}$kernel_version"
	echo -e "${LIGHT_CYAN}-------------"
	echo -e "${LIGHT_CYAN}CPU架构:      ${WHITE}$cpu_arch"
	echo -e "${LIGHT_CYAN}CPU型号:      ${WHITE}$cpu_info"
	echo -e "${LIGHT_CYAN}CPU核心数:    ${WHITE}$cpu_cores"
	echo -e "${LIGHT_CYAN}CPU频率:      ${WHITE}$cpu_freq"
	echo -e "${LIGHT_CYAN}-------------"
	echo -e "${LIGHT_CYAN}CPU占用:      ${WHITE}$cpu_usage_percent%"
	echo -e "${LIGHT_CYAN}系统负载:     ${WHITE}$load"
	echo -e "${LIGHT_CYAN}物理内存:     ${WHITE}$mem_info"
	echo -e "${LIGHT_CYAN}虚拟内存:     ${WHITE}$swap_info"
	echo -e "${LIGHT_CYAN}硬盘占用:     ${WHITE}$disk_info"
	echo -e "${LIGHT_CYAN}-------------"
	echo -e "${LIGHT_CYAN}总接收:       ${WHITE}$rx"
	echo -e "${LIGHT_CYAN}总发送:       ${WHITE}$tx"
	echo -e "${LIGHT_CYAN}-------------"
	echo -e "${LIGHT_CYAN}网络算法:     ${WHITE}$congestion_algorithm $queue_algorithm"
	echo -e "${LIGHT_CYAN}-------------"
	echo -e "${LIGHT_CYAN}运营商:       ${WHITE}$isp_info"
	if [ -n "$ipv4_address" ]; then
		echo -e "${LIGHT_CYAN}IPv4地址:     ${WHITE}$ipv4_address"
	fi

	if [ -n "$ipv6_address" ]; then
		echo -e "${LIGHT_CYAN}IPv6地址:     ${WHITE}$ipv6_address"
	fi
	echo -e "${LIGHT_CYAN}DNS地址:      ${WHITE}$dns_addresses"
	echo -e "${LIGHT_CYAN}地理位置:     ${WHITE}$country $city"
	echo -e "${LIGHT_CYAN}系统时间:     ${WHITE}$timezone $current_time"
	echo -e "${LIGHT_CYAN}-------------"
	echo -e "${LIGHT_CYAN}运行时长:     ${WHITE}$runtime"
	echo
}

### === 主函数 === ###
system_info_main() {
    show_system_info
}
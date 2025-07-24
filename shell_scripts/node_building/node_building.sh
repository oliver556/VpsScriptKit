#!/bin/bash

### =================================================================================
# @名称:         node_building.sh
# @功能描述:     节点搭建脚本合集 utils 函数
# @作者:         oliver556 (vskit@vskit.com)
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-20
#
# @许可证:       MIT
### =================================================================================

set_node_building_utils() {
	clear
	local NODE_BUILDING="$1"
    case "$NODE_BUILDING" in
        "3x_ui")
            if ! ask_to_continue "伊朗版 3X-UI 面板一键脚本"; then
                return
            fi
            install_3x_ui
            break_end no_wait
            ;;
        "x_ui")
            if ! ask_to_continue "新版 X-UI 面板一键脚本"; then
                return
            fi        
            install_x_ui
            break_end no_wait
            ;;
        "tcp_tuning")
            if ! ask_to_continue "TCP 调优工具"; then
                return
            fi
            install_tcp_tuning
            break_end no_wait
            ;;
    esac
}

### === 伊朗版3X-UI面板一键脚本 主函数 === ###
install_3x_ui() {
    clear
    echo -e "${BOLD_LIGHT_GREEN}正在安装伊朗版 3X-UI 面板一键脚本...${WHITE}"
	bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
}

### === 新版X-UI面板一键脚本 主函数 === ###
install_x_ui() {
    clear
    echo -e "${BOLD_LIGHT_GREEN}正在安装新版 X-UI 面板一键脚本...${WHITE} \n "
	bash <(curl -Ls https://raw.githubusercontent.com/oliver556/x-ui/main/install.sh)
}

### === TCP调优工具 主函数 === ###
install_tcp_tuning() {
    clear
    echo -e "${BOLD_LIGHT_GREEN}正在安装 TCP 调优工具...${WHITE}"
    wget -q https://raw.githubusercontent.com/BlackSheep-cry/TCP-Optimization-Tool/main/tool.sh -O tool.sh && chmod +x tool.sh
    echo_success "\nTCP 调优工具安装成功！\n"

    sub_menu_title "【简易教程】"
    gran_menu_title "【1. 获取平均延迟值】" "front_line"
    echo -e "   打开电脑终端, ping下VPS的IP, 看下延迟, 取平均值, ${LIGHT_RED}并记下这个数值${WHITE}。"

    gran_menu_title "【2. VPS 端操作】" "front_line"
    echo -e "   ${LIGHT_YELLOW}->${WHITE} ${LIGHT_CYAN}(1). ${WHITE}在主菜单选择 ${BOLD}[3] 半自动调优${WHITE}"
    echo -e "   ${LIGHT_YELLOW}->${WHITE} ${LIGHT_CYAN}(2). ${WHITE}接着选择 ${BOLD}[1] 半自动调参A${WHITE}"
    echo -e "   ${LIGHT_YELLOW}->${WHITE} ${LIGHT_CYAN}(3). ${WHITE}按以下提示填写参数:"
    echo -e "        ${CYAN}本机带宽:${WHITE} ${WHITE}2500${WHITE}"
    echo -e "        ${CYAN}对端带宽:${WHITE} ${WHITE}1000${WHITE}"
    echo -e "        ${CYAN}延迟:${WHITE}     ${WHITE}<此处填写第1步记下的延迟值>${WHITE}"
    echo -e "        ${CYAN}继续端口:${WHITE} ${WHITE}5201${WHITE}"
    echo -e "   ${LIGHT_YELLOW}->${WHITE} ${LIGHT_CYAN}(4). ${WHITE}脚本会生成一条 iperf3 命令, ${WHITE}将其完整复制${WHITE}。"

    gran_menu_title "【3. OpenWrt 端操作】" "front_line"
    echo -e "   ${LIGHT_YELLOW}1. 启用 BBR (如果还未启用):${WHITE}"
    echo -e "      执行以下命令。如果提示找不到 BBR 包, 请先在软件包中搜索并安装 ${BOLD}kmod-tcp-bbr${WHITE}。"

    echo -e "${LIGHT_CYAN}── BBR 启用命令 (在 OpenWrt 执行) ────────────────────────────${WHITE}"
    echo -e "echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf"
    echo -e "echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf"
    echo -e "sysctl -p"
    print_echo_line_1
    echo -e "   ${LIGHT_YELLOW}2. 执行以下脚本:${WHITE}"
    echo -e "${LIGHT_CYAN}── TCP 调优 命令 (在 OpenWrt 执行) ───────────────────────────${WHITE}"
    echo -e "wget -q https://raw.githubusercontent.com/BlackSheep-cry/TCP-Optimization-Tool/main/tool.sh -O tool.sh && chmod +x tool.sh && ./tool.sh"
    print_echo_line_1
    echo -e "   ${LIGHT_YELLOW}3. 运行 iperf3 测试:${WHITE}"
    echo -e "      直接在 OpenWrt 的终端中, ${BOLD}粘贴并执行第2步从VPS复制的 iperf3 命令${WHITE}。"
    echo -e "${LIGHT_CYAN}── iperf3 测试命令示例 ───────────────────────────────────────${WHITE}"
    echo -e "iperf3 -c ip -R -t 30 -p 5201"
    print_echo_line_1
    echo -e "      观察输出的速度，完成测试！"

    # 确认继续执行
    if ! ask_to_continue "TCP 调优工具"; then
        return
    fi

    clear
    echo_info "正在执行 TCP 调优工具... \n "
    sleep 1
    ./tool.sh
}

### === 修改系统时区 主函数 === ###
node_building_main() {
    local NODE_BUILDING="$1"
	set_node_building_utils "$NODE_BUILDING"
}

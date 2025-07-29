#!/bin/bash

### =================================================================================
# @名称:         node_building.sh
# @功能描述:     节点搭建脚本合集 utils 函数
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-20
# @修改日期:     2025-07-25
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
            display_tcp_tuning_tutorial

            if ! ask_to_continue "您已阅读完教程，是否要继续下载并执行 TCP 调优工具？"; then
                return
            fi

            install_tcp_tuning
            ;;
    esac
}

### === 伊朗版3X-UI面板一键脚本 主函数 === ###
install_3x_ui() {
    clear
    echo -e "${BOLD_LIGHT_GREEN}正在安装伊朗版 3X-UI 面板一键脚本...${LIGHT_WHITE}"
	exec bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
}

### === 新版X-UI面板一键脚本 主函数 === ###
install_x_ui() {
    clear
    echo -e "${BOLD_LIGHT_GREEN}正在安装新版 X-UI 面板一键脚本...${LIGHT_WHITE} \n "
	exec bash <(curl -Ls https://raw.githubusercontent.com/oliver556/x-ui/main/install.sh)
}

### === TCP调优教程 显示 === ###
display_tcp_tuning_tutorial() {
    clear
    sub_menu_title "【简易教程】"
    gran_menu_title "【1. 获取平均延迟值】" "front_line"
    echo -e "   打开电脑终端, ping下VPS的IP, 看下延迟, 取平均值, ${LIGHT_RED}并记下这个数值${LIGHT_WHITE}。"

    gran_menu_title "【2. VPS 端操作】" "front_line"
    echo -e "   ${LIGHT_YELLOW}->${LIGHT_WHITE} ${LIGHT_CYAN}(1). ${LIGHT_WHITE}在主菜单选择 ${BOLD}[3] 半自动调优${LIGHT_WHITE}"
    echo -e "   ${LIGHT_YELLOW}->${LIGHT_WHITE} ${LIGHT_CYAN}(2). ${LIGHT_WHITE}接着选择 ${BOLD}[1] 半自动调参A${LIGHT_WHITE}"
    echo -e "   ${LIGHT_YELLOW}->${LIGHT_WHITE} ${LIGHT_CYAN}(3). ${LIGHT_WHITE}按以下提示填写参数:"
    echo -e "        ${CYAN}本机带宽:${LIGHT_WHITE} ${LIGHT_WHITE}2500${LIGHT_WHITE}"
    echo -e "        ${CYAN}对端带宽:${LIGHT_WHITE} ${LIGHT_WHITE}1000${LIGHT_WHITE}"
    echo -e "        ${CYAN}延迟:${LIGHT_WHITE}     ${LIGHT_WHITE}<此处填写第1步记下的延迟值>${LIGHT_WHITE}"
    echo -e "        ${CYAN}继续端口:${LIGHT_WHITE} ${LIGHT_WHITE}5201${LIGHT_WHITE}"
    echo -e "   ${LIGHT_YELLOW}->${LIGHT_WHITE} ${LIGHT_CYAN}(4). ${LIGHT_WHITE}脚本会生成一条 iperf3 命令, ${LIGHT_WHITE}将其完整复制${LIGHT_WHITE}。"

    gran_menu_title "【3. OpenWrt 端操作】" "front_line"
    echo -e "   ${LIGHT_YELLOW}1. 启用 BBR (如果还未启用):${LIGHT_WHITE}"
    echo -e "      执行以下命令。如果提示找不到 BBR 包, 请先在软件包中搜索并安装 ${BOLD}kmod-tcp-bbr${LIGHT_WHITE}。"

    echo -e "${LIGHT_CYAN}── BBR 启用命令 (在 OpenWrt 执行) ────────────────────────────${LIGHT_WHITE}"
    echo -e "echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf"
    echo -e "echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf"
    echo -e "sysctl -p"
    print_echo_line_1
    echo -e "   ${LIGHT_YELLOW}2. 执行以下脚本:${LIGHT_WHITE}"
    echo -e "${LIGHT_CYAN}── TCP 调优 命令 (在 OpenWrt 执行) ───────────────────────────${LIGHT_WHITE}"
    echo -e "wget -q https://raw.githubusercontent.com/BlackSheep-cry/TCP-Optimization-Tool/main/tool.sh -O tool.sh && chmod +x tool.sh && ./tool.sh"
    print_echo_line_1
    echo -e "   ${LIGHT_YELLOW}3. 运行 iperf3 测试:${LIGHT_WHITE}"
    echo -e "      直接在 OpenWrt 的终端中, ${BOLD}粘贴并执行第2步从VPS复制的 iperf3 命令${LIGHT_WHITE}。"
    echo -e "${LIGHT_CYAN}── iperf3 测试命令示例 ───────────────────────────────────────${LIGHT_WHITE}"
    echo -e "iperf3 -c ip -R -t 30 -p 5201"
    print_echo_line_1
    echo -e "      观察输出的速度，完成测试！"
}

### === TCP调优工具 主函数 === ###
install_tcp_tuning() {
    clear
        local max_retries=3
        local retry_count=0
        local download_success=false
        local original_url="https://github.viplee.top/https://raw.githubusercontent.com/BlackSheep-cry/TCP-Optimization-Tool/main/tool.sh"

        echo -e "${BOLD_LIGHT_GREEN}正在下载 TCP 调优工具...${LIGHT_WHITE}"

        while [ $retry_count -lt $max_retries ]; do
            if wget -q "$original_url" -O tool.sh; then
                download_success=true
                break
            else
                retry_count=$((retry_count + 1))
                echo_warning "下载失败，正在进行第 $retry_count 次重试..."
                sleep 2 #
            fi
        done

        if [ "$download_success" = "false" ]; then
            echo_error "已达到最大重试次数，工具下载失败。"
            return 1
        fi

        echo_success "工具下载成功！"
        chmod +x tool.sh

        echo_info "正在设置执行权限..."
        exec ./tool.sh

        echo_info "准备执行 TCP 调优工具... \n"
        sleep 1
        exec ./tool.sh
}

### === 修改系统时区 主函数 === ###
node_building_main() {
    local NODE_BUILDING="$1"
	set_node_building_utils "$NODE_BUILDING"
}

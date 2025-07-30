#!/bin/bash

### =================================================================================
# @名称:         iptables_panel.sh
# @功能描述:     防火墙管理面板脚本。
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-30
# @修改日期:     2025-07-30
#
# @许可证:       MIT
### =================================================================================

### =================================================================================
### === 保存 iptables 规则 === ###
# @描述
#   本函数用于保存 iptables 规则 (使用系统标准工具)
#
# @示例
#   save_iptables_rules
###
save_iptables_rules() {
    echo_info "正在尝试使用标准工具持久化iptables规则..."
    if command -v netfilter-persistent &> /dev/null; then
        # 基于 Debian/Ubuntu 的系统
        echo "检测到 'netfilter-persistent'，正在保存规则..."
        netfilter-persistent save
    elif command -v systemctl &> /dev/null && systemctl list-unit-files | grep -q 'iptables.service'; then
        # 基于 RHEL/CentOS 的系统
        echo "检测到 'iptables.service'，正在保存规则..."
        service iptables save
    else
        echo -e "${BOLD_RED}警告: 未找到标准的iptables持久化工具 (如 iptables-persistent)。${LIGHT_WHITE}"
        echo "规则可能在重启后丢失。建议安装 'iptables-persistent' (Debian/Ubuntu) 或 'iptables-services' (CentOS/RHEL)。"
        return 1
    fi
    echo_success "规则已保存。"

    if [ "$1" == "close_all_ports" ]; then
        echo_warning "请立即添加一个新的SSH端口, 否则您将无法再次连接上服务器"
        echo_warning "您可以添加一个新端口, 或者使用以下命令添加一个新端口"
    fi
}
### =================================================================================

### =================================================================================
### === 打开一个或多个指定的TCP/UDP端口 === ###
# @描述
#   本函数用于打开一个或多个指定的TCP/UDP端口
#
# @参数
#   $1: 端口号列表 (例如: 80 443 1000)
#
# @示例
#   open_ports 80 443 1000
###
open_ports() {
    local ports_to_open=("$@")
    if [ ${#ports_to_open[@]} -eq 0 ]; then
        echo "内部错误：没有提供端口号给 open_ports 函数。"
        return 1
    fi

    for port in "${ports_to_open[@]}"; do
        echo "--> 正在处理端口: $port"
        
        # 统一处理TCP和UDP
        for proto in tcp udp; do
            # 先尝试删除可能存在的 DROP 规则，忽略错误
            iptables -D INPUT -p "$proto" --dport "$port" -j DROP &>/dev/null

            # 检查 ACCEPT 规则是否存在，如果不存在则插入到第一条
            if ! iptables -C INPUT -p "$proto" --dport "$port" -j ACCEPT &>/dev/null; then
                iptables -I INPUT 1 -p "$proto" --dport "$port" -j ACCEPT
                echo "    已为协议 ${proto^^} 打开端口 $port"
            else
                echo "    协议 ${proto^^} 的端口 $port 已经是打开状态。"
            fi
        done
    done
    
    # 所有端口处理完毕后，统一保存一次
    save_iptables_rules
}

### === 引导用户输入端口，并调用 open_ports === ###
# @描述
#   本函数用于引导用户输入端口，并调用 open_ports
#
# @示例
#   prompt_and_open_ports
###
prompt_and_open_ports() {
    clear
    echo "您可以输入单个端口、多个端口（用空格或逗号分隔）或一个端口范围（用:或-分隔）。"
    echo "例如: 80,443 3000:4000 999"
    read -rp "请输入要打开的端口: " user_input

    if [ -z "$user_input" ]; then
        echo "未输入任何内容，操作取消。"
        return
    fi

    # 将逗号替换为空格，以便迭代
    user_input_spaced=$(echo "$user_input" | tr ',' ' ')
    
    local final_ports=()
    # 循环处理每个输入项
    for item in $user_input_spaced; do
        # 检查是否为端口范围
        if [[ "$item" =~ ^[0-9]+[:\-][0-9]+$ ]]; then
            local start_port=$(echo "$item" | awk -F'[:-]' '{print $1}')
            local end_port=$(echo "$item" | awk -F'[:-]' '{print $2}')
            if [ "$start_port" -lt "$end_port" ]; then
                # 使用 seq 生成端口序列并添加到数组
                mapfile -t -O "${#final_ports[@]}" final_ports < <(seq "$start_port" "$end_port")
                echo "已添加端口范围: $start_port-$end_port"
            else
                echo "无效的端口范围: $item"
            fi
        # 检查是否为有效端口号
        elif [[ "$item" =~ ^[0-9]+$ ]] && [ "$item" -ge 1 ] && [ "$item" -le 65535 ]; then
            final_ports+=("$item")
        else
            echo "无效的输入项: $item"
        fi
    done

    if [ ${#final_ports[@]} -gt 0 ]; then
        echo "即将打开以下端口: ${final_ports[*]}"
        open_ports "${final_ports[@]}"
    else
        echo "没有解析到任何有效端口。"
    fi
}
### =================================================================================

### =================================================================================
### === 关闭一个或多个指定的TCP/UDP端口 === ###
# @描述
#   本函数用于关闭一个或多个指定的TCP/UDP端口
#
# @参数
#   $1: 端口号列表 (例如: 80 443 1000)
#
# @示例
#   close_ports 80 443 1000
###
close_ports() {
    local ports_to_close=("$@")
    if [ ${#ports_to_close[@]} -eq 0 ]; then
        echo "内部错误：没有提供端口号给 close_ports 函数。"
        return 1
    fi

    for port in "${ports_to_close[@]}"; do
        echo "--> 正在处理端口: $port"

        for proto in tcp udp; do
            # 循环删除所有可能存在的 ACCEPT 规则，直到删除失败 (说明没有更多了)
            while iptables -D INPUT -p "$proto" --dport "$port" -j ACCEPT &>/dev/null; do
                echo "    已为协议 ${proto^^} 删除一条 ACCEPT 规则。"
            done

            # 检查 DROP 规则是否存在，如果不存在则插入到第一条
            if ! iptables -C INPUT -p "$proto" --dport "$port" -j DROP &>/dev/null; then
                iptables -I INPUT 1 -p "$proto" --dport "$port" -j DROP
                echo "    已为协议 ${proto^^} 添加一条 DROP 规则以关闭端口 $port"
            else
                echo "    协议 ${proto^^} 的端口 $port 已经是关闭状态。"
            fi
        done
    done

    # 所有端口处理完毕后，统一保存一次
    save_iptables_rules
}
### =================================================================================

### =================================================================================
### === 引导用户输入要关闭的端口，并调用 close_ports === ###
# @描述
#   本函数用于引导用户输入要关闭的端口，并调用 close_ports
#
# @示例
#   prompt_and_close_ports
###
prompt_and_close_ports() {
    clear
    echo "您可以输入单个端口、多个端口（用空格或逗号分隔）或一个端口范围（用:或-分隔）。"
    echo "例如: 80,443 3000:4000 999"
    read -rp "请输入要关闭的端口: " user_input

    if [ -z "$user_input" ]; then
        echo "未输入任何内容，操作取消。"
        return
    fi

    user_input_spaced=$(echo "$user_input" | tr ',' ' ')
    local final_ports=()
    for item in $user_input_spaced; do
        if [[ "$item" =~ ^[0-9]+[:\-][0-9]+$ ]]; then
            local start_port=$(echo "$item" | awk -F'[:-]' '{print $1}')
            local end_port=$(echo "$item" | awk -F'[:-]' '{print $2}')
            if [ "$start_port" -lt "$end_port" ]; then
                mapfile -t -O "${#final_ports[@]}" final_ports < <(seq "$start_port" "$end_port")
                echo "已添加端口范围: $start_port-$end_port"
            else
                echo "无效的端口范围: $item"
            fi
        elif [[ "$item" =~ ^[0-9]+$ ]] && [ "$item" -ge 1 ] && [ "$item" -le 65535 ]; then
            final_ports+=("$item")
        else
            echo "无效的输入项: $item"
        fi
    done

    if [ ${#final_ports[@]} -gt 0 ]; then
        echo "即将关闭以下端口: ${final_ports[*]}"
        close_ports "${final_ports[@]}"
    else
        echo "没有解析到任何有效端口。"
    fi
}
### =================================================================================

### =================================================================================
### === 开放所有端口 (高风险操作) === ###
# @描述
#   本函数用于开放所有端口 (高风险操作)
#       通过清空INPUT链规则并将默认策略设置为ACCEPT实现。
#
# @示例
#   open_all_ports
###
open_all_ports() {
    clear
    echo -e "${BOLD_RED}警告：这是一个高风险操作！${NC}"
    echo "该操作将移除所有INPUT链的防火墙规则，并将默认策略设置为 ACCEPT。"
    echo "这意味着您的服务器将对所有入站流量开放，会显著增加安全风险。"
    
    if ! ask_to_continue "您确定要开放所有端口吗？"; then
        return
    fi

    echo "--> 正在清空 INPUT 链的所有规则..."
    iptables -F INPUT
    
    echo "--> 正在将 INPUT 链的默认策略设置为 ACCEPT..."
    iptables -P INPUT ACCEPT
    
    echo -e "${GREEN}所有端口已开放。防火墙处于默认接受状态。${NC}"
    save_iptables_rules
}
### =================================================================================

### =================================================================================
### === 关闭所有端口 (极高风险操作) === ###
# @描述
#   本函数用于关闭所有端口 (极高风险操作)
#       通过设置默认策略为DROP实现，并自动添加规则以防止当前SSH会话断开。
#
# @示例
#   close_all_ports
###
close_all_ports() {
    clear
    echo -e "${BOLD_RED}警告：这是一个极高风险操作！${NC}"
    echo "该操作会将防火墙默认策略设置为 DROP，阻止所有新的入站连接。"
    echo "为了防止您被锁在外面，脚本会自动添加一条规则以保持现有连接（如您的SSH）。"
    echo -e "${BOLD_YELLOW}在不完全理解后果的情况下，请不要执行此操作。${NC}"

    if ! ask_to_continue "您确定要关闭所有未明确允许的端口吗？"; then
        return
    fi

    echo "--> 正在清空现有规则以避免冲突..."
    iptables -F INPUT

    echo "--> 正在添加“防锁死”规则 (允许已建立的连接)..."
    # 这是最关键的一步，它允许所有已经建立的连接（比如你当前的SSH）继续通信
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    echo "--> 正在添加“允许本机内部通信”规则..."
    iptables -A INPUT -i lo -j ACCEPT

    echo "--> 正在将 INPUT 链的默认策略设置为 DROP..."
    # 当这条命令执行后，所有不匹配上面两条规则的新连接都将被拒绝
    iptables -P INPUT DROP
    
    echo -e "${GREEN}防火墙已设置为“默认关闭”模式。${NC}"
    echo "仅保留了您当前的连接和本机内部通信。所有其他新连接都将被阻止。"
    save_iptables_rules "close_all_ports"
}
### =================================================================================

### =================================================================================
### === 将一个或多个IP地址添加到白名单 (允许访问所有端口) === ###
# @描述
#   本函数用于将一个或多个IP地址添加到白名单 (允许访问所有端口)
#
# @参数
#   $1: IP地址列表 (例如: 1.1.1.1 8.8.8.8)
#
# @示例
#   add_ip_to_whitelist 1.1.1.1 8.8.8.8
###
add_ip_to_whitelist() {
    local ips_to_add=("$@")
    if [ ${#ips_to_add[@]} -eq 0 ]; then
        echo "内部错误: 没有提供IP地址给 add_ip_to_whitelist 函数。"
        return 1
    fi

    for ip in "${ips_to_add[@]}"; do
        echo "--> 正在处理IP地址: $ip"
        
        # 检查规则是否存在，如果不存在则插入到第一条
        if ! iptables -C INPUT -s "$ip" -j ACCEPT &>/dev/null; then
            iptables -I INPUT 1 -s "$ip" -j ACCEPT
            echo "    已将IP $ip 添加到白名单 (允许所有连接)。"
        else
            echo "    IP $ip 已经在白名单中。"
        fi
    done

    save_iptables_rules
}

### === 引导用户输入要加入白名单的IP === ###
# @描述
#   本函数用于引导用户输入要加入白名单的IP
#
# @示例
#   prompt_and_add_to_whitelist
###
prompt_and_add_to_whitelist() {
    clear
    echo "请输入一个或多个要加入白名单的IP地址，用空格分隔。"
    read -rp "IP地址: " user_input

    if [ -z "$user_input" ]; then
        echo "未输入任何内容，操作取消。"
        return
    fi
    
    # 将用户输入直接传递给核心函数
    add_ip_to_whitelist $user_input
}
### =================================================================================

### =================================================================================

### === 将一个或多个IP地址添加到黑名单 (拒绝所有连接) === ###
# @描述
#   本函数用于将一个或多个IP地址添加到黑名单 (拒绝所有连接)
#
# @参数
#   $1: IP地址列表 (例如: 1.1.1.1 8.8.8.8)
#
# @示例
#   add_ip_to_blacklist 1.1.1.1 8.8.8.8
###
add_ip_to_blacklist() {
    local ips_to_add=("$@")
    if [ ${#ips_to_add[@]} -eq 0 ]; then
        echo "内部错误: 没有提供IP地址给 add_ip_to_blacklist 函数。"
        return 1
    fi

    for ip in "${ips_to_add[@]}"; do
        echo "--> 正在处理IP地址: $ip"
        
        if ! iptables -C INPUT -s "$ip" -j DROP &>/dev/null; then
            iptables -I INPUT 1 -s "$ip" -j DROP
            echo "    已将IP $ip 添加到黑名单 (拒绝所有连接)。"
        else
            echo "    IP $ip 已经在黑名单中。"
        fi
    done

    save_iptables_rules
}

### === 引导用户输入要加入黑名单的IP === ###
# @描述
#   本函数用于引导用户输入要加入黑名单的IP
#
# @示例
#   prompt_and_add_to_blacklist
###
prompt_and_add_to_blacklist() {
    clear
    echo "请输入一个或多个要加入黑名单的IP地址，用空格分隔。"
    read -rp "IP地址: " user_input

    if [ -z "$user_input" ]; then
        echo "未输入任何内容，操作取消。"
        return
    fi
    
    add_ip_to_blacklist $user_input
}
### =================================================================================

### === 清除所有与指定IP地址相关的规则 === ###
# @描述
#   本函数用于清除所有与指定IP地址相关的规则
#
# @参数
#   $1: IP地址列表 (例如: 1.1.1.1 8.8.8.8)
#
# @示例
#   remove_ip_rules 1.1.1.1 8.8.8.8
###
remove_ip_rules() {
    local ips_to_remove=("$@")
    if [ ${#ips_to_remove[@]} -eq 0 ]; then
        echo "内部错误：没有提供IP地址给 remove_ip_rules 函数。"
        return 1
    fi

    for ip in "${ips_to_remove[@]}"; do
        echo "--> 正在清除IP地址 $ip 的所有相关规则..."
        local rule_found=0

        # 循环删除所有与该IP相关的规则 (ACCEPT, DROP等)
        # 先用 iptables-save 获取规则，然后用 grep 找到行号，再用 iptables -D 删除
        # 因为直接用 iptables -D 循环删除会导致行号变化，出现问题
        
        # 获取包含该IP的规则的行号，并倒序排列
        local line_numbers=$(iptables -L INPUT --line-numbers | grep "$ip" | awk '{print $1}' | sort -rn)

        if [ -z "$line_numbers" ]; then
            echo "    未找到与IP $ip 相关的规则。"
            continue
        fi

        for line_num in $line_numbers; do
            iptables -D INPUT "$line_num"
            echo "    已删除INPUT链中第 $line_num 行的规则。"
            rule_found=1
        done
        
        if [ $rule_found -eq 0 ]; then
            echo "    未在INPUT链中找到与IP $ip 相关的规则。"
        fi
    done

    save_iptables_rules
}

### === 引导用户输入要清除规则的IP === ###
# @描述
#   本函数用于引导用户输入要清除规则的IP
#
# @示例
#   prompt_and_remove_ip_rules
###
prompt_and_remove_ip_rules() {
    clear
    echo "请输入一个或多个要清除规则的IP地址，用空格分隔。"
    read -rp "IP地址: " user_input

    if [ -z "$user_input" ]; then
        echo "未输入任何内容，操作取消。"
        return
    fi
    
    remove_ip_rules $user_input
}
### =================================================================================

### =================================================================================
### === 允许外部主机 PING 本机 === ###
# @描述
#   本函数用于允许外部主机 PING 本机
#
# @示例
#   allow_ping
###
allow_ping() {
    clear
    echo "正在配置防火墙以允许 PING..."

    # 遵循我们的设计模式：先清理，后添加
    # 1. 尝试删除可能存在的“禁止PING”规则，忽略错误
    iptables -D INPUT -p icmp --icmp-type echo-request -j DROP &>/dev/null

    # 2. 检查“允许PING”的规则是否存在，不存在则添加
    #    icmp-type 8 和 echo-request 是等效的
    if ! iptables -C INPUT -p icmp --icmp-type echo-request -j ACCEPT &>/dev/null; then
        # 使用 -A (Append) 将其添加到链的末尾即可，通常ICMP规则优先级不高
        iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
        echo "已添加规则：允许 ICMP (Ping) 请求。"
    else
        echo "防火墙已经配置为允许 PING。"
    fi

    save_iptables_rules
}

### === 禁止外部主机 PING 本机 === ###
# @描述
#   本函数用于禁止外部主机 PING 本机
#
# @示例
#   deny_ping
###
deny_ping() {
    clear
    echo "正在配置防火墙以禁止 PING..."

    # 1. 尝试删除可能存在的“允许PING”规则
    iptables -D INPUT -p icmp --icmp-type echo-request -j ACCEPT &>/dev/null

    # 2. 检查“禁止PING”的规则是否存在，不存在则添加
    if ! iptables -C INPUT -p icmp --icmp-type echo-request -j DROP &>/dev/null; then
        # 使用 -I (Insert) 将拒绝规则置顶，确保它最先生效
        iptables -I INPUT 1 -p icmp --icmp-type echo-request -j DROP
        echo "已添加规则：禁止 ICMP (Ping) 请求。"
    else
        echo "防火墙已经配置为禁止 PING。"
    fi

    save_iptables_rules
}

### =================================================================================

### =================================================================================
### === 启动基础的DDOS防御策略 === ###
# @描述
#   本函数用于启动基础的DDOS防御策略
#
# @示例
#   start_ddos_protection
###
start_ddos_protection() {
    clear
    echo "正在启动基础的DDOS防御规则..."

    # 步骤1: 创建一个新的链专门用于DDOS防御规则，避免污染INPUT链
    iptables -N DDOS_PROTECT &>/dev/null

    # 步骤2: 清空旧规则，确保从干净的状态开始
    iptables -F DDOS_PROTECT

    # --- 开始向DDOS_PROTECT链中添加具体的防御规则 ---

    # 规则A: 防御SYN洪水攻击 (限制新建连接的速率)
    # 每秒最多接受5个新连接，超过的放入一个临时的限制区
    iptables -A DDOS_PROTECT -p tcp --syn -m limit --limit 5/s --limit-burst 10 -j ACCEPT
    iptables -A DDOS_PROTECT -p tcp --syn -j DROP
    echo "  > 已添加SYN洪水防御规则。"

    # 规则B: 防御端口扫描 (记录并丢弃可疑的扫描行为)
    # 创建一个专门的链来处理端口扫描
    iptables -N PORT_SCAN &>/dev/null
    iptables -F PORT_SCAN
    iptables -A PORT_SCAN -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j RETURN
    iptables -A PORT_SCAN -j DROP
    # 将可疑的数据包跳转到端口扫描链进行处理
    iptables -A DDOS_PROTECT -p tcp --tcp-flags ALL FIN,URG,PSH -j PORT_SCAN
    iptables -A DDOS_PROTECT -p tcp --tcp-flags ALL ALL -j PORT_SCAN
    iptables -A DDOS_PROTECT -p tcp --tcp-flags ALL NONE -j PORT_SCAN
    iptables -A DDOS_PROTECT -p tcp --tcp-flags SYN,RST SYN,RST -j PORT_SCAN
    iptables -A DDOS_PROTET -p tcp --tcp-flags SYN,FIN SYN,FIN -j PORT_SCAN
    echo "  > 已添加端口扫描防御规则。"

    # 规则C: 丢弃无效的数据包 (如畸形XMAS包)
    iptables -A DDOS_PROTECT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
    iptables -A DDOS_PROTECT -p tcp --tcp-flags ALL ALL -j DROP
    iptables -A DDOS_PROTECT -p tcp --tcp-flags ALL NONE -j DROP
    iptables -A DDOS_PROTECT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    iptables -A DDOS_PROTECT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
    echo "  > 已添加无效数据包丢弃规则。"

    # 规则D: 限制ICMP(Ping)请求，防止Ping洪水
    iptables -A DDOS_PROTECT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
    iptables -A DDOS_PROTECT -p icmp --icmp-type echo-request -j DROP
    echo "  > 已添加Ping洪水防御规则。"

    # --- 防御规则添加完毕 ---

    # 步骤3: 将所有入站流量引导到我们新建的DDOS_PROTECT链进行检查
    # 检查跳转规则是否存在，不存在则插入到INPUT链的顶部
    if ! iptables -C INPUT -j DDOS_PROTECT &>/dev/null; then
        iptables -I INPUT 1 -j DDOS_PROTECT
    fi

    echo -e "\n${GREEN}DDOS防御已启动。${NC}"
    save_iptables_rules
}

### === 关闭DDOS防御策略 === ###
# @描述
#   本函数用于关闭DDOS防御策略
#
# @示例
#   stop_ddos_protection
###
stop_ddos_protection() {
    clear
    echo "正在关闭DDOS防御规则..."

    # 步骤1: 从INPUT链中删除跳转到DDOS_PROTECT链的规则
    # 使用while循环确保所有跳转规则都被删除
    while iptables -D INPUT -j DDOS_PROTECT &>/dev/null; do
        echo "  > 已从INPUT链移除一条DDOS防御跳转规则。"
    done

    # 步骤2: 清空DDOS_PROTECT和PORT_SCAN链中的所有规则
    iptables -F DDOS_PROTECT &>/dev/null
    iptables -F PORT_SCAN &>/dev/null
    echo "  > 已清空DDOS防御规则链。"

    # 步骤3: 删除我们创建的自定义链
    iptables -X DDOS_PROTECT &>/dev/null
    iptables -X PORT_SCAN &>/dev/null
    echo "  > 已删除自定义链。"

    echo -e "\n${GREEN}DDOS防御已关闭。${NC}"
    save_iptables_rules
}

### =================================================================================

### =================================================================================
### === 检查并安装 GeoIP 功能所需的核心依赖 (ipset) === ###
# @描述
#   本函数用于检查并安装 GeoIP 功能所需的核心依赖 (ipset)
#
# @示例
#   setup_geoip_dependencies
###
setup_geoip_dependencies() {
    local installed=1
    if ! command -v ipset &> /dev/null; then
        echo "高级功能需要 'ipset' 工具，正在尝试安装..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y ipset
        elif command -v yum &> /dev/null; then
            yum install -y ipset
        fi

        if ! command -v ipset &> /dev/null; then
            echo_error "'ipset' 安装失败，无法继续。"
            installed=0
        fi
    fi

    # 检查并安装 ipset 的持久化工具
    if command -v apt-get &> /dev/null && ! dpkg -l | grep -q 'ipset-persistent'; then
        echo "为了保存国家IP列表，需要 'ipset-persistent'，正在尝试安装..."
        apt-get install -y ipset-persistent
    elif command -v yum &> /dev/null && ! systemctl list-unit-files | grep -q 'ipset.service'; then
         echo "为了保存国家IP列表，需要 'ipset-services'，正在尝试安装..."
         yum install -y ipset-services && systemctl enable ipset
    fi
    
    [ $installed -eq 1 ]
}

### === 重构后的保存函数，同时保存 iptables 和 ipset 规则 === ###
# @描述
#   本函数用于重构后的保存函数，同时保存 iptables 和 ipset 规则
#
# @示例
#   save_firewall_state
###
save_firewall_state() {
    echo "正在持久化防火墙规则..."
    # 保存 iptables 规则
    if command -v netfilter-persistent &> /dev/null; then
        netfilter-persistent save
    elif command -v systemctl &> /dev/null && systemctl list-unit-files | grep -q 'iptables.service'; then
        service iptables save
    else
        echo_warning "未找到 iptables 持久化工具，规则可能在重启后丢失。"
    fi
    
    # 保存 ipset 规则
    if command -v ipset-persistent &> /dev/null; then
         ipset-persistent save
    elif command -v systemctl &> /dev/null && systemctl list-unit-files | grep -q 'ipset.service'; then
        service ipset save
    else
        echo_warning "未找到 ipset 持久化工具，国家IP列表可能在重启后丢失。"
    fi

    echo "状态已保存。"
}

### === 下载指定国家的IP列表，并使用ipset和iptables进行阻止 === ###
# @描述
#   本函数用于下载指定国家的IP列表，并使用ipset和iptables进行阻止
#
# @示例
#   block_country_ip
###
block_country_ip() {
    clear
    echo "此功能将下载指定国家的IP地址列表并阻止其所有访问。"
    echo "请使用两位大写国家代码, 例如: CN, US, RU..."
    echo "IP数据来源: ipdeny.com"
    read -rp "请输入要阻止的国家代码: " country_code

    if ! [[ "$country_code" =~ ^[A-Z]{2}$ ]]; then
        echo_error "无效的国家代码格式，请输入两位大写字母。"
        return
    fi
    
    local set_name="country_${country_code}_drop"
    local ip_list_url="http://www.ipdeny.com/ipblocks/data/countries/${country_code,,}.zone" # URL需要小写代码

    echo "--> 步骤1: 创建 ipset 集合 '$set_name'..."
    ipset create "$set_name" hash:net -exist

    echo "--> 步骤2: 从 $ip_list_url 下载IP列表..."
    # 使用 curl 下载，如果失败则提示
    local ip_list=$(curl -sL "$ip_list_url")
    if [ -z "$ip_list" ]; then
        echo_error "无法下载国家 '$country_code' 的IP列表，请检查代码是否正确或网络。"
        ipset destroy "$set_name" # 清理掉创建的空集合
        return
    fi

    echo "--> 步骤3: 将IP地址添加到集合中 (这可能需要一些时间)..."
    for ip in $ip_list; do
        ipset add "$set_name" "$ip" -exist
    done

    echo "--> 步骤4: 在 iptables 中添加引用此集合的 DROP 规则..."
    if ! iptables -C INPUT -m set --match-set "$set_name" src -j DROP &>/dev/null; then
        iptables -I INPUT 1 -m set --match-set "$set_name" src -j DROP
    fi

    echo_success "已成功阻止来自国家 '$country_code' 的所有IP地址。"
    save_firewall_state
}

### === 设置防火墙为默认拒绝，并仅允许来自特定国家的IP访问 === ###
# @描述
#   本函数用于设置防火墙为默认拒绝，并仅允许来自特定国家的IP访问
#
# @示例
#   allow_only_country_ip
###
allow_only_country_ip() {
    clear
    echo_error "警告：这是一个极高风险的操作！"
    echo_warning "此功能会首先关闭所有端口（默认DROP），然后仅为您指定的国家开放。"
    echo_warning "如果您的当前IP不在该国家列表中，您将立即被锁定！"
    
    if ! ask_to_continue "您确定要继续吗？"; then
        echo "操作已取消。"
        return
    fi

    read -rp "请输入仅允许访问的国家代码 (例如: US): " country_code
    if ! [[ "$country_code" =~ ^[A-Z]{2}$ ]]; then
        echo_error "无效的国家代码格式。"
        return
    fi

    # 步骤1: 先执行“关闭所有端口”的逻辑，建立一个安全的基础
    echo "--> 正在建立“默认拒绝”的安全基线..."
    close_all_ports # 复用我们之前创建的函数

    local set_name="country_${country_code}_allow"
    local ip_list_url="http://www.ipdeny.com/ipblocks/data/countries/${country_code,,}.zone"

    echo "--> 步骤2: 创建 ipset 集合 '$set_name'..."
    ipset create "$set_name" hash:net -exist
    
    echo "--> 步骤3: 下载并添加IP到集合..."
    local ip_list=$(curl -sL "$ip_list_url")
    if [ -z "$ip_list" ]; then
        echo_error "无法下载国家 '$country_code' 的IP列表。"
        ipset destroy "$set_name"
        return
    fi
    for ip in $ip_list; do
        ipset add "$set_name" "$ip" -exist
    done

    echo "--> 步骤4: 在 iptables 中添加 ACCEPT 规则..."
    # 这条规则需要插在“防锁死”规则之后
    if ! iptables -C INPUT -m set --match-set "$set_name" src -j ACCEPT &>/dev/null; then
        iptables -I INPUT 2 -m set --match-set "$set_name" src -j ACCEPT
    fi

    echo_success "防火墙已配置为仅允许来自 '$country_code' 的IP地址访问。"
    save_firewall_state
}

### === 解除对指定国家的IP限制 === ###
# @描述
#   本函数用于解除对指定国家的IP限制
#
# @示例
#   unblock_country_ip
###
unblock_country_ip() {
    clear
    echo "此功能将从防火墙中移除对特定国家的所有限制规则 (ACCEPT 或 DROP)。"
    read -rp "请输入要解除限制的国家代码: " country_code

    if ! [[ "$country_code" =~ ^[A-Z]{2}$ ]]; then
        echo_error "无效的国家代码格式。"
        return
    fi

    local drop_set_name="country_${country_code}_drop"
    local allow_set_name="country_${country_code}_allow"
    local rule_removed=0

    # 尝试删除 DROP 规则
    if iptables -C INPUT -m set --match-set "$drop_set_name" src -j DROP &>/dev/null; then
        echo "--> 正在删除对 '$country_code' 的 DROP 规则..."
        iptables -D INPUT -m set --match-set "$drop_set_name" src -j DROP
        rule_removed=1
    fi
    # 尝试删除 ipset drop 集合
    if ipset list -n | grep -q "$drop_set_name"; then
        echo "--> 正在销毁 ipset 集合 '$drop_set_name'..."
        ipset destroy "$drop_set_name"
    fi

    # 尝试删除 ALLOW 规则
    if iptables -C INPUT -m set --match-set "$allow_set_name" src -j ACCEPT &>/dev/null; then
        echo "--> 正在删除对 '$country_code' 的 ALLOW 规则..."
        iptables -D INPUT -m set --match-set "$allow_set_name" src -j ACCEPT
        rule_removed=1
    fi
    # 尝试删除 ipset allow 集合
    if ipset list -n | grep -q "$allow_set_name"; then
        echo "--> 正在销毁 ipset 集合 '$allow_set_name'..."
        ipset destroy "$allow_set_name"
    fi
    
    if [ $rule_removed -eq 1 ]; then
        echo_success "已成功解除对国家 '$country_code' 的IP限制。"
        save_firewall_state
    else
        echo_warning "未找到与国家 '$country_code' 相关的限制规则。"
    fi
}
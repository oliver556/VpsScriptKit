#!/bin/bash

### =================================================================================
# @名称:         optimize_dns.sh
# @功能描述:     DNS 优化工具
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-27
# @修改日期:     2025-07-27
#
# @许可证:       MIT
### =================================================================================

### === 导入 DNS 优化工具 === ###
source "$ROOT_DIR/shell_scripts/system/optimize_dns.sh"

### === DNS 优化工具 主菜单 === ###
#
# @描述
#   本函数用于显示 DNS 优化工具主菜单。
#
# @示例
#   system_optimize_dns_menu
###
system_optimize_dns_menu() {
    while true; do
        clear
        sub_menu_title "⚙️  DNS 优化工具"

        echo -e "${LIGHT_RED}警告: 直接修改 /etc/resolv.conf 可能在重启或网络重连后失效。${LIGHT_WHITE}"
        echo -e "${LIGHT_RED}我们提供了锁定文件的选项来尝试解决此问题。${LIGHT_WHITE}"

        print_echo_line_1
        echo -e "${LIGHT_CYAN}当前DNS服务器:${LIGHT_WHITE}"
        cat /etc/resolv.conf
        print_echo_line_1

        echo -e "${BOLD_YELLOW}请选择一个DNS优化方案:${LIGHT_WHITE}"
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_CYAN}使用 Cloudflare DNS${LIGHT_WHITE}"
        echo -e "     v4: 1.1.1.1, 8.8.8.8"
        echo -e "     v6: 2606:4700:4700::1111, 2001:4860:4860::8888"
        echo ""
        echo -e "${LIGHT_CYAN}2. ${LIGHT_CYAN}国内DNS优化 (阿里DNS + DNSPod)${LIGHT_WHITE}"
        echo -e "     v4: 223.5.5.5, 119.29.29.29"
        echo -e "     v6: 2400:3200::1, 2402:4e:b:a::1"
        echo ""
        echo -e "${LIGHT_CYAN}3. ${LIGHT_YELLOW}手动编辑 DNS 配置文件${LIGHT_WHITE}"
        break_menu_options "up"
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                # 定义国外DNS变量
                local dns1_ipv4="1.1.1.1"
                local dns2_ipv4="8.8.8.8"
                local dns1_ipv6="2606:4700:4700::1111"
                local dns2_ipv6="2001:4860:4860::8888"
                set_dns "$dns1_ipv4" "$dns2_ipv4" "$dns1_ipv6" "$dns2_ipv6"
                break_end
                ;;
            2)
                # 定义国内DNS变量
                local dns1_ipv4="223.5.5.5"
                local dns2_ipv4="119.29.29.29"
                local dns1_ipv6="2400:3200::1"
                local dns2_ipv6="2402:4e:b:a::1"
                set_dns "$dns1_ipv4" "$dns2_ipv4" "$dns1_ipv6" "$dns2_ipv6"
                break_end
                ;;
            3)
                # 手动编辑前先解锁文件
                if [ -f /etc/resolv.conf ]; then
                    chattr -i /etc/resolv.conf 2>/dev/null
                fi
                # 优先使用 nano，如果不存在则使用 vi
                if command -v nano &> /dev/null; then
                    nano /etc/resolv.conf
                else
                    vi /etc/resolv.conf
                fi
                break_end
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

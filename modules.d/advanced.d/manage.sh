#!/bin/bash

### === 脚本描述 === ###
# 名称： manage.sh
# 功能： 证书管理
# 作者：
# 创建日期：2025-07-18
# 许可证：MIT

#
# =================================================================================
# SSL Certificate Application & Auto-Renewal Script (Optimized Version)
#
# 功能:
# 1. 自动检测系统并安装所需依赖 (curl, socat, cron)。
# 2. 引导用户输入域名、邮箱等信息。
# 3. 自动安装官方 acme.sh 工具。
# 4. 智能配置防火墙，仅放行 80 端口用于验证。
# 5. 申请、颁发，并将证书和私钥安装到规范、安全的目录。
# 6. 自动设置 Cron 定时任务，实现证书自动续期。
#
# =================================================================================

### === 导入证书管理脚本 === ###
source "$ROOT_DIR/shell_scripts/advanced/setup-ssl.sh"

### === 证书申请交互函数 === ###
get_details_and_apply_ssl() {
    clear

    print_echo_line_1
    echo -e "${BOLD_YELLOW}SSL 证书申请向导${WHITE}"
    print_echo_line_1
    
    # --- 步骤 1: 收集基本信息 ---
    read -rp "${LIGHT_CYAN}请输入您的域名 (例如: example.com): ${WHITE}" domain
    if [[ -z "$domain" ]]; then
        echo "❌ 错误: 域名不能为空。" && sleep 2
        return
    fi
    
    read -rp "${LIGHT_CYAN}请输入您的电子邮件地址 (用于ACME账户): ${WHITE}" email
    if [[ -z "$email" ]]; then
        echo "❌ 错误: 邮箱不能为空。" && sleep 2
        return
    fi
    
    echo -e "${LIGHT_CYAN}请选择证书颁发机构 (CA):${WHITE}"
    echo -e "  ${LIGHT_CYAN}1) ${LIGHT_GREEN}Let's Encrypt (推荐)"
    echo -e "  ${LIGHT_CYAN}2) ${WHITE}Buypass"
    echo -e "  ${LIGHT_CYAN}3) ${WHITE}ZeroSSL"
    read -rp "${LIGHT_CYAN}输入选项 [1-3] (默认为1): ${WHITE}" ca_choice
    local ca_server
    case $ca_choice in
        2) ca_server="buypass" ;;
        3) ca_server="zerossl" ;;
        *) ca_server="letsencrypt" ;;
    esac

    clear

    # --- 步骤 2: 防火墙嵌套逻辑 ---
    print_echo_line_1
    echo -e "${LIGHT_CYAN}防火墙配置${WHITE}"
    print_echo_line_1
    echo -e "${LIGHT_YELLOW}证书申请需要通过公网HTTP(80端口)验证，请配置防火墙。\n${WHITE}"
    
    read -rp "${LIGHT_CYAN}1. ${WHITE}是否要完全关闭防火墙? ${LIGHT_GREEN}节点 推荐) ${LIGHT_RED}[y/N]: ${WHITE}" choice_disable
    if [[ "$choice_disable" =~ ^[yY](es)?$ ]]; then
        echo
        disable_firewall
        print_echo_line_1
        echo -e "${LIGHT_RED}防火墙已关闭${WHITE}"
    else
        read -rp "${LIGHT_CYAN}2. ${WHITE}是否自动放行 80 端口用于验证? ${LIGHT_RED}[Y/n]: ${WHITE}" choice_80
        if [[ ! "$choice_80" =~ ^[nN]$ ]]; then # 默认为 Yes
            allow_port_80
            print_echo_line_1
            echo -e "${LIGHT_GREEN}防火墙已放行 80 端口${WHITE}"
        else
            read -rp "${LIGHT_CYAN}3. ${WHITE}是否需要放行一个其他特定端口? ${LIGHT_RED}[y/N]: ${WHITE}" choice_specific
            if [[ "$choice_specific" =~ ^[yY](es)?$ ]]; then
                echo
                read -rp "${LIGHT_YELLOW}请输入要放行的端口号: ${WHITE}" port_to_open
                if [[ -n "$port_to_open" ]]; then
                    allow_specific_port "$port_to_open"
                    print_echo_line_1 "front_line"
                    echo -e "${LIGHT_CYAN}防火墙已放行 ${LIGHT_GREEN}$port_to_open ${LIGHT_CYAN}端口"
                    print_echo_line_1 "back_line"
                else
                    echo -e "\n${LIGHT_RED}⚠️ 未输入端口号，跳过防火墙配置。${WHITE}"
                fi
            else
                print_echo_line_1 "front_line"
                echo -e "${LIGHT_YELLOW}您已选择不进行任何自动防火墙配置。请务必手动确保验证端口可被公网访问。${WHITE}"
                print_echo_line_1 "back_line"
            fi
        fi
    fi

    # --- 步骤 3: 确认并执行 ---
    print_echo_line_1
    echo -e "${LIGHT_CYAN}请确认申请信息：${WHITE}"
    echo -e "  - ${LIGHT_CYAN}域名:${WHITE}   $domain"
    echo -e "  - ${LIGHT_CYAN}邮箱:${WHITE}   $email"
    echo -e "  - ${LIGHT_CYAN}CA:${WHITE}     $ca_server"
    echo -e "  - ${LIGHT_CYAN}防火墙:${WHITE} 已根据您的选择进行配置。"
    print_echo_line_1
    
    read -rp "${LIGHT_YELLOW}确认无误并开始申请吗? ${LIGHT_RED}[y/N]: ${WHITE}" start_apply
    if [[ "$start_apply" =~ ^[yY](es)?$ ]]; then
        apply_ssl_certificate "$domain" "$email" "$ca_server"
    else
        echo -e "${LIGHT_RED}🚫 操作已取消。${WHITE}"
    fi

    break_end
}


### === 证书管理 主菜单 === ###
advanced_manage_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  系统管理面板"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}SSL 证书管理${WHITE}"
        echo -e "${LIGHT_CYAN}1.  ${WHITE}申请 SSL 证书"
        echo -e "${LIGHT_CYAN}2.  ${WHITE}吊销/重置域名的 SSL 证书"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}防火墙管理${WHITE}"
        echo -e "${LIGHT_CYAN}3.  ${WHITE}放行指定端口 (推荐)"
        echo -e "${LIGHT_CYAN}4.  ${WHITE}关闭防火墙 (高风险)"
        echo -e "${LIGHT_CYAN}5.  ${WHITE}查看已申请的域名"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " MAIN_OPTION

        case $MAIN_OPTION in
            1)
                get_details_and_apply_ssl
                ;;
            2)
                clear
                # 优化后的逻辑：先列表，再操作
                if list_issued_domains; then
                    # 如果列表成功显示（非空），则提示用户输入
                    read -rp "👉 请从上方列表中，输入您要重置的全域名: " domain_to_reset
                    if [[ -n "$domain_to_reset" ]]; then
                        read -p "⚠️ 您确定要移除 '$domain_to_reset' 的证书和续期配置吗? [y/N]: " confirm_reset
                        if [[ "$confirm_reset" =~ ^[yY](es)?$ ]]; then
                            reset_ssl_environment "$domain_to_reset"
                        else
                            echo "🚫 操作已取消。"
                        fi
                    else
                        echo "🚫 操作取消，未输入域名。"
                    fi
                fi # 如果 list_issued_domains 失败或列表为空，则直接跳过
                echo -e "\n按 Enter 键返回..." && read -p ""
                ;;
            3)
                read -rp "请输入要放行的 TCP 端口号: " port_to_open
                if [[ -n "$port_to_open" ]]; then
                    allow_specific_port "$port_to_open"
                else
                    echo "❌ 未输入端口号。" && sleep 2
                fi
                echo -e "\n按 Enter 键返回..." && read -p ""
                ;;
            4)
                disable_firewall
                echo -e "\n按 Enter 键返回..." && read -p ""
                ;;
            5)
                list_issued_domains
                echo -e "\n按 Enter 键返回..." && read -p ""
                ;;
            0)
                break
                ;;
            *)
                echo "❌ 无效选项，请重新输入。" && sleep 1
                ;;
        esac
    done
}
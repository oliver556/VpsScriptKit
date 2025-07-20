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

### === 证书管理 主菜单 === ###
advanced_manage_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  SSL 证书管理面板"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}申请 SSL 证书"
        echo -e "${LIGHT_CYAN}2.  ${WHITE}查看已申请的域名"
        echo -e "${LIGHT_CYAN}3.  ${WHITE}重置环境（清除申请记录并重新部署）"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " MAIN_OPTION

        case $MAIN_OPTION in
            1)
                get_ssl_interaction
                ;;
            2)
                _list_issued_domains
                ;;
            3)
                _reset_environment
                ;;
            # 返回主菜单
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
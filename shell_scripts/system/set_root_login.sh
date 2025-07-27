#! /bin/bash

### =================================================================================
# @名称:         set_root_login.sh
# @功能描述:     设置 root 用户密码
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-26
# @修改日期:     2025-07-26
### =================================================================================

# 设置 root 用户密码
#
# @描述
#   本函数用于设置 root 用户密码。
#
# @示例
#   set_root_login
###
set_root_login() {
    clear

    is_user_root || return
    
    echo -e "${BOLD_YELLOW}接下来将为您设置 root 用户密码，请根据提示操作。${LIGHT_WHITE}"
    if ! passwd root; then
        echo -e "${BOLD_RED}密码设置失败，已取消操作。${LIGHT_WHITE}"
        return 1
    fi
    echo -e "${BOLD_GREEN}Root 密码设置成功。${LIGHT_WHITE}"
    
    echo "正在配置 SSH..."
    sed -i 's/^\s*#\?\s*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sed -i 's/^\s*#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -i 's|^Include /etc/ssh/sshd_config.d/\*.conf|#&|' /etc/ssh/sshd_config
    
    if command -v systemctl &> /dev/null; then
        systemctl restart sshd
    else
        service sshd restart
    fi
    
    case "$choice" in
      [Yy])
        echo "正在重启 SSH 服务..."
        if command -v systemctl &> /dev/null; then
            systemctl restart sshd
        else
            service sshd restart
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${BOLD_GREEN}SSH 服务重启成功，新设置已生效。${LIGHT_WHITE}"
        else
            echo -e "${BOLD_RED}SSH 服务重启失败，请手动检查配置并重启服务: systemctl restart sshd${LIGHT_WHITE}"
        fi
        ;;
      [Nn])
        echo -e "${BOLD_YELLOW}已取消重启。请注意，新设置将在您下次手动重启 SSH 服务后生效。${LIGHT_WHITE}"
        echo "您可以随时运行 ${BOLD_GREEN}sudo systemctl restart sshd${LIGHT_WHITE} 来应用更改。"
        ;;
      *)
        echo "无效的选择。未执行重启操作。"
        echo "您可以随时运行 ${BOLD_GREEN}sudo systemctl restart sshd${LIGHT_WHITE} 来应用更改。"
        ;;
    esac
}

#! /bin/bash

### =================================================================================
# @名称:         general.sh
# @功能描述:     系统通用工具
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-15
# @修改日期:     2025-07-20
#
# @许可证:       MIT
### =================================================================================

### === 创建 sudo 用户并禁用 root 密码登录 === ###
#
# @描述
#   本函数用于创建 sudo 用户并禁用 root 密码登录。
#
# @示例
#   create_sudo_user_and_disable_root
###
create_sudo_user_and_disable_root() {
    # 1. 检查和准备环境
    if ! is_user_root; then
        return 1
    fi

    clear

    
    echo -e "${YELLOW}此脚本将创建一个新的 sudo 用户，并禁用 root 用户的密码登录。${LIGHT_WHITE}"
    
    # 检查并确保 sudo 已安装
    if ! command -v sudo &> /dev/null; then
        echo "检测到 sudo 未安装，正在尝试安装..."
        # 兼容不同的包管理器
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y sudo
        elif command -v yum &> /dev/null; then
            yum install -y sudo
        else
            echo -e "${LIGHT_RED}无法自动安装 sudo，请手动安装后再运行此脚本。${LIGHT_WHITE}"
            exit 1
        fi
    fi

    # 2. 获取并验证用户名
    local new_username
    while true; do
        read -e -p "请输入新用户名 (只允许小写字母和数字, 输入 '0' 退出): " new_username
        if [ "$new_username" == "0" ]; then
            echo "操作已取消。"
            return
        fi
        
        # 验证用户名是否已存在
        if id "$new_username" &>/dev/null; then
            echo -e "${LIGHT_RED}错误: 用户 '$new_username' 已存在，请换一个用户名。${LIGHT_WHITE}"
            continue
        # 验证用户名格式是否合规
        elif ! [[ "$new_username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            echo -e "${LIGHT_RED}错误: 用户名格式不正确。应以小写字母开头，只包含小写字母、数字、下划线或连字符。${LIGHT_WHITE}"
            continue
        else
            break
        fi
    done

    # 3. 执行核心操作
    echo -e "${LIGHT_YELLOW}正在创建用户 '$new_username'..."
    if ! useradd -m -s /bin/bash "$new_username"; then
        echo -e "${LIGHT_RED}创建用户失败，请检查系统日志。${LIGHT_WHITE}"
        return 1
    fi

    echo -e "${LIGHT_YELLOW}请为新用户 '$new_username' 设置密码:"
    if ! passwd "$new_username"; then
        echo -e "${LIGHT_RED}为用户 '$new_username' 设置密码失败。${LIGHT_WHITE}"
        # 清理掉刚才创建的用户，保持系统干净
        userdel -r "$new_username" &>/dev/null
        return 1
    fi
    
    # 4. 赋予 Sudo 权限 (采用最佳实践)
    # 不直接修改 /etc/sudoers，而是在 /etc/sudoers.d/ 目录下创建用户专属的配置文件
    echo -e "${LIGHT_YELLOW}正在为用户 '$new_username' 配置 sudo 权限..."
    echo "$new_username ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/$new_username"
    # 设置正确的文件权限
    chmod 0440 "/etc/sudoers.d/$new_username"

    # 5. 禁用/锁定 root 用户密码登录
    echo -e "${LIGHT_YELLOW}正在锁定 root 用户的密码登录..."
    if passwd -l root; then
        echo -e "${LIGHT_GREEN}root 用户已成功锁定。${LIGHT_WHITE}"
    else
        echo -e "${LIGHT_RED}锁定 root 用户失败。${LIGHT_WHITE}"
    fi

    echo ""
    echo -e "${LIGHT_GREEN}操作成功完成！${LIGHT_WHITE}"
    print_echo_line_1
    echo -e "新用户 ${LIGHT_YELLOW}'$new_username'${LIGHT_WHITE} 已创建并赋予 sudo 权限。"
    echo -e "root 用户的密码登录已被禁用。"
    echo -e "为了安全，请重新登录并使用新用户进行操作: ${LIGHT_YELLOW}ssh ${new_username}@<your_server_ip>${LIGHT_WHITE}"
    print_echo_line_1
}

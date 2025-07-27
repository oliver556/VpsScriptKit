#!/bin/bash

### =================================================================================
# @名称:         bbrv3.sh
# @功能描述:     BBRv3的脚本。
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-28
# @修改日期:     2025-07-28
#
# @许可证:       MIT
### =================================================================================

### === 辅助函数：安装 XanMod 内核 === ###
#
# @描述
#   本函数用于安装 XanMod 内核。
#
# @示例
#   install_xanmod_kernel
###
_install_xanmod() {
    local version
    local key_url="${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/archive.key"
    local check_script_url="${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/check_x86-64_psabi.sh"
    local repo_list_file="/etc/apt/sources.list.d/xanmod-release.list"

    echo "--> 步骤1: 安装依赖..."
    install wget gnupg
    if ! command -v wget >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
        echo "错误：依赖安装失败 (wget, gnupg)。"
        return 1
    fi

    echo "--> 步骤2: 添加 XanMod GPG 密钥..."
    if ! wget -qO - "$key_url" | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes; then
        echo "错误：无法下载或添加 XanMod 的 GPG 密钥。"
        return 1
    fi

    echo "--> 步骤3: 添加 XanMod 软件源..."
    echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee "$repo_list_file" > /dev/null

    echo "--> 步骤4: 检测合适的内核版本..."
    if ! wget -q "$check_script_url" -O "check_x86-64_psabi.sh"; then
        echo "错误：无法下载内核版本检测脚本。"
        rm -f "$repo_list_file" # 清理
        return 1
    fi
    chmod +x check_x86-64_psabi.sh
    version=$(./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
    if [ -z "$version" ]; then
        echo "错误：无法自动检测到合适的内核版本 (v1, v2, v3, or v4)。"
        rm -f "$repo_list_file" check_x86-64_psabi.sh # 清理
        return 1
    fi
    echo "检测到您的CPU支持版本: x64v$version"
    
    echo "--> 步骤5: 更新软件列表并安装内核..."
    apt update -y
    if ! apt install -y "linux-xanmod-x64v$version"; then
        echo "错误：安装 XanMod 内核失败。"
        rm -f "$repo_list_file" check_x86-64_psabi.sh # 清理
        return 1
    fi
    
    echo "--> 清理临时文件..."
    rm -f "$repo_list_file" check_x86-64_psabi.sh*
    return 0
}

### === 辅助函数：卸载 XanMod 内核 === ###
#
# @描述
#   本函数用于卸载 XanMod 内核。
#
# @示例
#   uninstall_xanmod_kernel
###
_uninstall_xanmod() {
    echo "--> 正在卸载所有 xanmod 内核..."
    if ! apt purge -y 'linux-*xanmod*'; then
        echo "错误：卸载内核时遇到问题。"
        return 1
    fi
    echo "--> 更新 grub 引导..."
    update-grub
    echo "XanMod 内核已卸载。"
    return 0
}

### === BBRv3 主函数 === ###
#
# @描述
#   本函数用于安装 BBRv3。
#
# @示例
#   bbrv3
###
system_set_bbrv3() {
    is_user_root || return
    
    # 处理 aarch64 (ARM) 架构
    if [ "$(uname -m)" = "aarch64" ]; then
        echo "检测到 ARM64 架构，将执行专用脚本..."
        sleep 2
        bash <(curl -sL jhb.ovh/jb/bbrv3arm.sh)
        return
    fi

    local os_type
    os_type=$(get_os_type)

    if [ "$os_type" != "debian_like" ]; then
        echo_error "当前脚本仅支持 Debian 和 Ubuntu 系统。"
        return
    else
        echo_error "无法确定操作系统类型"
    fi

    # --- 主逻辑：根据是否已安装来决定下一步 ---
    if dpkg -l | grep -q 'linux-xanmod'; then
        # --- 场景1: 已安装 XanMod，显示管理菜单 ---
        while true; do
            clear
            echo -e "${LIGHT_GREEN}您已安装 XanMod BBRv3 内核。${LIGHT_WHITE}"
            echo -e "${LIGHT_CYAN}当前内核版本: ${LIGHT_WHITE}$(uname -r)"
            print_echo_line_1
            echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}更新 XanMod 内核"
            echo -e "${LIGHT_CYAN}2.  ${LIGHT_WHITE}卸载 XanMod 内核"
            print_echo_line_3
            echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回"
            print_echo_line_3
            read -rp "请输入你的选择: " sub_choice
            case "$sub_choice" in
                1) # 更新 = 先卸载 + 再安装
                    _uninstall_xanmod && _install_xanmod
                    if [ $? -eq 0 ]; then
                        echo -e "${LIGHT_GREEN}内核更新成功，需要重启生效。${LIGHT_WHITE}"
                        server_reboot
                    else
                        echo -e "${LIGHT_RED}内核更新失败。${LIGHT_WHITE}"
                        read -p "按任意键返回..."
                    fi
                    ;;
                2) # 卸载
                    if _uninstall_xanmod; then
                        echo -e "${LIGHT_GREEN}内核卸载成功，需要重启生效。${LIGHT_WHITE}"
                        server_reboot
                    else
                        echo -e "${LIGHT_RED}内核卸载失败。${LIGHT_WHITE}"
                        read -p "按任意键返回..."
                    fi
                    ;;
                0) 
                    break ;;
                *) 
                    echo "无效选择，请重试。" && sleep 1 ;;
            esac
        done
    else
        # --- 场景2: 未安装 XanMod，显示首次安装提示 ---
        clear
        echo "BBRv3 加速安装向导 (XanMod 内核)"
        echo "------------------------------------------------"
        echo "本操作将替换您当前的Linux内核以开启BBRv3，请务必做好数据备份。"
        echo "如果您的VPS内存小于512M，请提前添加SWAP虚拟内存，否则可能失联。"
        echo "------------------------------------------------"
        read -p "确定要开始安装吗？ (y/n): " choice

        if [[ "$choice" =~ ^[Yy]$ ]]; then
            check_disk_space 3
            check_swap
            if _install_xanmod; then
                bbr_on # 启用 BBRv3 的 sysctl 配置
                echo -e "${LIGHT_GREEN}XanMod 内核安装并启用 BBRv3 成功，需要重启生效。${LIGHT_WHITE}"
                server_reboot
            else
                echo -e "${LIGHT_RED}安装过程遇到错误，操作已中止。${LIGHT_WHITE}"
            fi
        else
            echo -e "${LIGHT_RED}操作已取消。${LIGHT_WHITE}"
        fi
    fi
}
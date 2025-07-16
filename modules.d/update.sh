#!/bin/bash

### === 脚本描述 === ###
# 名称： update.sh
# 功能： 更新脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

### === 函数定义 === ###
# 函数：退出脚本并显示错误信息
error_exit() {
    echo -e "${BOLD_RED}错误: $1${BOLD_WHITE}" >&2
    exit 1
}

## === 函数：下载并解压指定的 URL === ###
# @param $1: 要下载的压缩包 URL
download_and_extract() {
    local TARBALL_URL="$1"
    echo -e "${BOLD_BLUE}--> 正在下载更新包...${WHITE}" >&2
    
    local TMP_TARBALL
    TMP_TARBALL=$(mktemp)

    curl -L "$TARBALL_URL" -o "$TMP_TARBALL" || error_exit "下载发行版压缩包失败！"
    echo -e "${BOLD_BLUE}--> 正在覆盖安装文件...${WHITE}" >&2
    
    tar -xzf "$TMP_TARBALL" -C "$INSTALL_DIR" || error_exit "解压文件失败！"
    
    rm -f "$TMP_TARBALL"
}

### === 函数：获取版本对比 === ###
get_latest_version_tag() {
    local LATEST_RELEASE_JSON
    LATEST_RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/$REPO/releases/latest")

    # 如果 API 请求失败或返回为空，则退出
    if [ -z "$LATEST_RELEASE_JSON" ]; then
        error_exit "无法从 GitHub API 获取信息，请检查网络或仓库状态。"
    fi
    
    echo "$LATEST_RELEASE_JSON" | grep '"tag_name":' | cut -d '"' -f 4
}

### === 函数：获取下载链接 === ###
get_latest_release_url() {
    # 获取完整的最新版本信息
    echo -e "${BOLD_BLUE}--> 正在获取下载链接...${WHITE}"
    local LATEST_RELEASE_JSON
    LATEST_RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/$REPO/releases/latest")

    if [ -z "$LATEST_RELEASE_JSON" ]; then
        error_exit "无法从 GitHub API 获取信息，请检查网络或仓库状态。"
    fi
    
    #  从 JSON 中解析出下载链接
    local LATEST_URL
    LATEST_URL=$(echo "$LATEST_RELEASE_JSON" | grep "browser_download_url" | grep "\.tar\.gz" | cut -d '"' -f 4)
    
    if [ -z "$LATEST_URL" ]; then
        error_exit "未能找到 .tar.gz 下载链接。"
    fi
    
    echo -e "--> 准备从以下链接下载:\n    $LATEST_URL"
    download_and_extract "$LATEST_URL"
}

### ===核心更新功能 === ###

## === 函数：更新脚本 === ###
update_now() {
    clear
    echo -e "${BOLD_GREEN}🚀 发现新版本，准备开始更新...${WHITE}"
    sleep 1

    get_latest_release_url

    # 3. 设置权限和链接
    echo -e "${BOLD_BLUE}--> 正在设置文件权限...${WHITE}"
    find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} +

    echo -e "${BOLD_BLUE}--> 正在刷新快速启动命令...${WHITE}"
    if [ -f "$INSTALL_DIR/vps_script_kit.sh" ]; then
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/v
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/vsk
    fi

    echo ""
    echo -e "${BOLD_GREEN}✅ 更新完成！脚本即将自动重启...${WHITE}"
    sleep 2

    # 4. 重启脚本
    # exec bash "$INSTALL_DIR/vps_script_kit.sh"
    vskit
}

# 函数：开启自动更新
enable_auto_update() {
    clear
    echo -e "${BOLD_BLUE}⚙️  正在配置自动更新...${WHITE}"

    # 检查 crontab 中是否已有任务
    if crontab -l | grep -q "$CRON_COMMENT"; then
        echo -e "${BOLD_YELLOW}自动更新任务已经存在，无需重复添加。${WHITE}"
        sleep 2
        return
    fi

    # 创建更新命令，这里直接调用主脚本的更新参数
    local update_script_path="$INSTALL_DIR/vps_script_kit.sh"
    local cron_job="0 3 * * * /bin/bash $update_script_path --update > /dev/null 2>&1 # $CRON_COMMENT"

    # 将新任务添加到 crontab
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    
    echo -e "${BOLD_GREEN}✅ 自动更新已开启！${WHITE}"
    echo -e "${BOLD_GREEN}   系统将在每天凌晨 3 点自动检查并更新。${WHITE}"
    sleep 3
}

# 函数：关闭自动更新
disable_auto_update() {
    clear
    echo -e "${BOLD_BLUE}⚙️  正在关闭自动更新...${WHITE}"

    # 检查 crontab 中是否已有任务
    if ! crontab -l | grep -q "$CRON_COMMENT"; then
        echo -e "${BOLD_YELLOW}未找到自动更新任务，无需操作。${WHITE}"
        sleep 2
        return
    fi

    # 从 crontab 中移除任务
    crontab -l | grep -v "$CRON_COMMENT" | crontab -

    echo -e "${BOLD_GREEN}✅ 自动更新已成功关闭！${WHITE}"
    sleep 2
}

### === 更新脚本 主菜单 === ###
update_menu() {
    clear

    while true; do
        clear
        title="🖥️  更新脚本"
        printf "${LIGHT_CYAN}"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        printf "| %-${width_48}s |\n" "$title"
        printf "+%${width_40}s+\n" "" | tr ' ' '-'
        
        # 获取最新版本号
        local LATEST_SCRIPT_VERSION
        LATEST_SCRIPT_VERSION=$(get_latest_version_tag)

        if [[ "${SCRIPT_VERSION}" == "${LATEST_SCRIPT_VERSION}" ]]; then
            echo -e "${BOLD_GREEN}✅ 您当前已是最新版本 ${SCRIPT_VERSION}。${WHITE}"
        else 
            echo -e "${BOLD_GREEN}🚀  发现新版本！"
            echo -e "${LIGHT_CYAN}当前版本：${SCRIPT_VERSION}       最新版本：${YELLOW}${LATEST_SCRIPT_VERSION}${WHITE}"
        fi

        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}1. ${WHITE}现在更新            ${LIGHT_CYAN}2. ${WHITE}开启自动更新            ${LIGHT_CYAN}3. ${WHITE}关闭自动更新"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo -e "${LIGHT_CYAN}0. ${WHITE}返回主菜单"
        echo -e "${LIGHT_CYAN}------------------------------------------${WHITE}"
        echo ""
        read -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                update_now
                break_end no_wait ;;
            2)
                enable_auto_update ;;
            3)
                disable_auto_update ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
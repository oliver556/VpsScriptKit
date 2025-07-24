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
vsk_update_download_and_extract() {
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
vsk_update_get_latest_version_tag() {
    local LATEST_RELEASE_JSON
    LATEST_RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/$REPO/releases/latest")

    # 如果 API 请求失败或返回为空，则退出
    if [ -z "$LATEST_RELEASE_JSON" ]; then
        error_exit "无法从 GitHub API 获取信息，请检查网络或仓库状态。"
    fi

    echo "$LATEST_RELEASE_JSON" | grep '"tag_name":' | cut -d '"' -f 4
}

### === 函数：获取下载链接 === ###
vsk_update_get_latest_release_url() {
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
    vsk_update_download_and_extract "$LATEST_URL"
}

### ===核心更新功能 === ###

## === 函数：更新脚本 === ###
vsk_update_now() {
    clear
    echo -e "${BOLD_GREEN}🚀 发现新版本，准备开始更新...${WHITE}"
    sleep 1

    vsk_update_get_latest_release_url

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
    VSK_RESTART_FLAG=1
}

# 函数：开启自动更新
vsk_update_enable_auto_update() {
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
vsk_update_disable_auto_update() {
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

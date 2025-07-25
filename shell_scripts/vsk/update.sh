#!/bin/bash

### =================================================================================
# @名称:         update.sh
# @功能描述:     更新脚本
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 退出脚本并显示错误信息 === ###
#
# @描述
#   本函数用于退出脚本并显示错误信息。
#
# @示例
#   error_exit
###
error_exit() {
    echo -e "${BOLD_RED}错误: $1${BOLD_WHITE}" >&2
    exit 1
}

### === 下载并解压指定的 URL === ###
#
# @描述
#   本函数用于下载并解压指定的 URL。
#
# @参数 $1: 要下载的压缩包 URL
#
# @示例
#   vsk_update_download_and_extract "https://xxx.tar.gz"
###
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

### === 获取版本对比 === ###
#
# @描述
#   本函数用于获取版本对比。
#
# @示例
#   vsk_update_get_latest_version_tag
###
vsk_update_get_latest_version_tag() {
    local LATEST_RELEASE_JSON
    LATEST_RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/$REPO/releases/latest")

    # 如果 API 请求失败或返回为空，则退出
    if [ -z "$LATEST_RELEASE_JSON" ]; then
        error_exit "无法从 GitHub API 获取信息，请检查网络或仓库状态。"
    fi

    echo "$LATEST_RELEASE_JSON" | grep '"tag_name":' | cut -d '"' -f 4
}

### === 获取下载链接 === ###
#
# @描述
#   本函数用于获取下载链接。
#
# @示例
#   vsk_update_get_latest_release_url
###
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

### === 更新脚本 === ###
#
# @描述
#   本函数用于更新脚本。
#
# @示例
#   vsk_update_now
###
vsk_update_now() {
    local LATEST_SCRIPT_VERSION="$1"

    clear
    echo_info "🔎 正在检查最新版本信息..."

    if [[ -z "$LATEST_SCRIPT_VERSION" ]]; then
        echo_error "获取远程版本号失败，请检查网络。"
        sleep 2
        return 1
    fi

    # 1. 比较本地版本和远程版本
    if [[ "$SCRIPT_VERSION" == "$LATEST_SCRIPT_VERSION" ]]; then
        # 如果版本号一致，给出提示并返回
        echo_success "✅ 您当前已是最新版本 (${SCRIPT_VERSION})，无需更新。"
        break_end
    else
        # 如果版本号不一致，执行更新流程
        echo_info "🚀 发现新版本 (${LATEST_SCRIPT_VERSION})，准备开始更新..."
        sleep 1

        vsk_update_get_latest_release_url

        # 2. 设置权限和链接
        echo -e "${BOLD_BLUE}--> 正在设置文件权限...${WHITE}"
        find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} +

        echo -e "${BOLD_BLUE}--> 正在刷新快速启动命令...${WHITE}"
        if [ -f "$INSTALL_DIR/vps_script_kit.sh" ]; then
            ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/v
            ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/vsk
        fi

        # 3. 在所有操作成功后，创建重启标志
        echo
        echo -e "${BOLD_GREEN}✅ 更新完成！脚本即将自动重启...${WHITE}"
        sleep 1

        # 在所有操作成功后，才创建重启标志
        echo
        echo_success "✅ 更新完成！准备设置重启标志..."
        sleep 1

        # 4. 重启脚本
        touch /tmp/vsk_restart_flag
        return 10
    fi
}

### === 开启自动更新 === ###
#
# @描述
#   本函数用于开启自动更新。
#
# @示例
#   vsk_update_enable_auto_update
###
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

### === 关闭自动更新 === ###
#
# @描述
#   本函数用于关闭自动更新。
#
# @示例
#   vsk_update_disable_auto_update
###
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

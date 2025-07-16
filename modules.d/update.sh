#!/bin/bash

### === 脚本描述 === ###
# 名称： update.sh
# 功能： 更新脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

### === 配置 === ###
# 安装目录
INSTALL_DIR="/opt/VpsScriptKit"
# 仓库地址
REPO="oliver556/VpsScriptKit"
# 自动更新的 Cron 任务标识
CRON_COMMENT="VpsScriptKit-AutoUpdate"

### === 函数定义 === ###
# 函数：退出脚本并显示错误信息
error_exit() {
    echo -e "${BOLD_RED}错误: $1${BOLD_WHITE}" >&2
    exit 1
}

# 函数：获取最新发行版的下载链接
# TODO 需要优化，如果版本一直，则提醒，无需更新，如果版本不一致，则更新
get_latest_release_url() {
    echo -e "${BOLD_BLUE}--> 正在查询最新版本...${WHITE}" >&2
    
    local LATEST_RELEASE_JSON
    LATEST_RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/$REPO/releases/latest")
    
    local TARBALL_URL
    TARBALL_URL=$(echo "$LATEST_RELEASE_JSON" | grep "browser_download_url" | grep "\.tar\.gz" | cut -d '"' -f 4)

    if [ -z "$TARBALL_URL" ]; then
        error_exit "无法找到最新的发行版下载链接！请检查仓库 Release 页面。"
    fi
    
    echo "$TARBALL_URL"
}

# 函数：下载并解压指定的 URL
download_and_extract() {
    local tarball_url="$1"

    echo -e "${BOLD_BLUE}--> 正在下载并解压文件...${WHITE}" >&2
    
    local TMP_TARBALL
    TMP_TARBALL=$(mktemp)

    curl -L "$tarball_url" -o "$TMP_TARBALL" || error_exit "下载发行版压缩包失败！"
    
    # 清理旧文件，准备更新
    echo -e "${BOLD_BLUE}--> 正在清理旧版本文件...${WHITE}"
    # 删除除了日志等特定文件外的所有内容
    find "$INSTALL_DIR" -mindepth 1 -maxdepth 1 ! -name 'logs' -exec rm -rf {} +

    echo -e "${BOLD_BLUE}--> 正在解压新版本...${WHITE}"
    tar -xzf "$TMP_TARBALL" -C "$INSTALL_DIR" --strip-components=1 || error_exit "解压文件失败！"
    
    rm -f "$TMP_TARBALL"
}

### ===核心更新功能 === ###

# 函数：更新脚本
# 函数：更新脚本（带版本对比）
# 函数：更新脚本（优化版）
update_now() {
    clear
    echo -e "${BOLD_GREEN}🚀 正在检查更新...${WHITE}"
    sleep 1

    # 1. 直接从 GitHub API 获取最新发布信息
    echo -e "${BOLD_BLUE}--> 正在查询最新版本信息...${WHITE}"
    local LATEST_RELEASE_JSON
    LATEST_RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/$REPO/releases/latest")

    # 如果 API 请求失败或返回为空，则退出
    if [ -z "$LATEST_RELEASE_JSON" ]; then
        error_exit "无法从 GitHub API 获取信息，请检查网络或仓库状态。"
    fi

    # 2. 从 JSON 中解析出最新的版本号 (tag_name)
    local latest_version
    latest_version=$(echo "$LATEST_RELEASE_JSON" | grep '"tag_name":' | cut -d '"' -f 4)
    
    # 打印当前版本和最新版本以供比较
    # SCRIPT_VERSION 变量由 init_lib.sh 提供
    echo -e "--> ${LIGHT_CYAN}当前版本: ${WHITE}${SCRIPT_VERSION}"
    echo -e "--> ${LIGHT_CYAN}最新版本: ${WHITE}${latest_version}"
    echo ""

    # 3. 比较版本，如果完全相等，则无需更新
    if [[ "${SCRIPT_VERSION}" == "${latest_version}" ]]; then
        echo -e "${BOLD_GREEN}✅ 您当前已是最新版本，无需更新。${WHITE}"
        sleep 2
        return
    fi

    # 4. 如果版本不一致，则准备更新
    echo -e "${BOLD_YELLOW}发现新版本，准备开始更新...${WHITE}"

    # 从 JSON 中解析出 .tar.gz 文件的下载链接
    local latest_url
    latest_url=$(echo "$LATEST_RELEASE_JSON" | grep "browser_download_url" | grep "\.tar\.gz" | cut -d '"' -f 4)
    
    # 再次检查 URL 是否获取成功
    if [ -z "$latest_url" ]; then
        error_exit "成功获取版本号，但未能找到 .tar.gz 下载链接。"
    fi
    
    echo -e "--> 准备从以下链接下载:\n    $latest_url"

    # 5. 下载并解压替换文件 (调用已有的函数)
    download_and_extract "$latest_url"

    # 6. 设置权限
    echo -e "${BOLD_BLUE}--> 正在设置文件权限...${WHITE}"
    find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} +

    # 7. 重新创建快速启动命令
    echo -e "${BOLD_BLUE}--> 正在刷新快速启动命令...${WHITE}"
    if [ -f "$INSTALL_DIR/vps_script_kit.sh" ]; then
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/v
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/vsk
    else
        echo -e "${BOLD_YELLOW}警告: vps_script_kit.sh 未找到，跳过创建快捷命令。${WHITE}"
    fi

    echo ""
    # 更新完成后，可以从 API 获取的最新版本号来显示
    echo -e "${BOLD_GREEN}✅ 更新完成！现在版本为 ${latest_version}${WHITE}"
    sleep 3
    clear
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

#!/bin/bash

# 当任何命令失败时立即退出脚本
set -e

### === 脚本描述 === ###
# 名称： install.sh
# 功能： 安装 VpsScriptKit 脚本
# 作者： YourName
# 创建日期：2025-07-15
# 许可证：MIT

# --- 配置 ---
INSTALL_DIR="/opt/VpsScriptKit"
REPO="oliver556/VpsScriptKit"

# --- 颜色定义 ---
RESET="\033[0m"
RED_BOLD="\033[1;31m"
GREEN_BOLD="\033[1;32m"
YELLOW_BOLD="\033[1;33m"
BLUE_BOLD="\033[1;34m"

# --- 函数定义 ---
error_exit() {
    echo -e "${RED_BOLD}错误: $1${RESET}" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函数：获取最新发行版的下载链接
# 通过 echo 将结果输出，以便被调用者捕获
get_latest_release_url() {
    # ✅ 将状态信息输出到标准错误流(stderr)，这样它就不会被命令替换捕获
    echo -e "${BLUE_BOLD}--> 正在查询最新版本...${RESET}" >&2
    
    # 调用 GitHub API 获取最新 Release 的信息
    local LATEST_RELEASE_JSON
    LATEST_RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/$REPO/releases/latest")
    
    # 从返回的 JSON 中解析出 .tar.gz 文件的下载链接
    local TARBALL_URL
    TARBALL_URL=$(echo "$LATEST_RELEASE_JSON" | grep "browser_download_url" | grep "\.tar\.gz" | cut -d '"' -f 4)

    # 检查是否成功获取到 URL
    if [ -z "$TARBALL_URL" ]; then
        error_exit "无法找到最新的发行版下载链接！请检查仓库 Release 页面。"
    fi
    
    # 将找到的 URL 作为函数的唯一标准输出
    echo "$TARBALL_URL"
}

# 函数：下载并解压指定的 URL
# @param $1: 要下载的压缩包 URL
download_and_extract() {
    local tarball_url="$1"

    echo -e "${BLUE_BOLD}--> 正在下载并解压文件...${RESET}" >&2
    
    # 创建一个临时文件来存放下载的压缩包
    local TMP_TARBALL
    TMP_TARBALL=$(mktemp)

    # 使用传入的 URL 进行下载
    curl -L "$tarball_url" -o "$TMP_TARBALL" || error_exit "下载发行版压缩包失败！"
    
    # 创建安装目录
    mkdir -p "$INSTALL_DIR" || error_exit "创建安装目录 $INSTALL_DIR 失败！"
    
    # 解压到目标目录 (注意：没有 --strip-components=1)
    tar -xzf "$TMP_TARBALL" -C "$INSTALL_DIR" || error_exit "解压文件失败！"
    
    # 清理临时文件
    rm -f "$TMP_TARBALL"
}


# --- 主安装函数 ---
install_main() {
    clear
    # 1. 清理旧版本
    echo -e "${CYAN}🧹 正在清理旧版本...${RESET}"
    rm -rf "$INSTALL_DIR"
    rm -rf "/usr/local/bin/vsk"
    rm -rf "/usr/local/bin/v"
    sleep 1
    echo ""
    echo -e "${CYAN}✅ 脚本已清理，即将覆盖安装！${RESET}"
    sleep 2
    clear

    echo -e "${GREEN_BOLD}正在安装 VpsScriptKit...${RESET}"

    # 2. 调用函数获取最新发行版的下载链接
    local latest_url
    latest_url=$(get_latest_release_url)
    echo -e "--> 找到最新版本，准备从以下链接下载:\n    $latest_url"

    # 3. 调用函数下载并解压文件
    download_and_extract "$latest_url"

    # 4. 设置权限
    echo -e "${BLUE_BOLD}--> 正在设置文件权限...${RESET}"
    find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} +

    # 5. 创建快速启动命令
    echo -e "${BLUE_BOLD}--> 正在创建快速启动命令...${RESET}"
    if [ -f "$INSTALL_DIR/vps_script_kit.sh" ]; then
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/v
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/vsk
    else
        echo -e "${YELLOW_BOLD}警告: 未在仓库根目录找到 vps_script_kit.sh，跳过创建快捷命令。${RESET}"
    fi

    # 6. 显示成功信息
    echo "
    +----------------------------------------------------------------------------------------------------+
    |  ██╗     ██╗█████████╗███████╗  ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗  ██╗  ██╗██╗████████╗ |
    |  ██╗     ██║██╔════██║██╔════╝  ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝  ██║ ██╔╝██║╚══██╔══╝ |
    |   ██╗   ██╗ █████████║███████╗  ███████╗██║     ██████╔╝██║██████╔╝   ██║     █████╔╝ ██║   ██║    |
    |    ██╗ ██╗  ██╔══════╝╚════██║  ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║     ██╔═██╗ ██║   ██║    |
    |     ████╗  ║██║       ███████║  ███████║╚██████╗██║  ██║██║██║        ██║     ██║  ██╗██║   ██║    |
    |     ╚═══╝  ╚══╝       ╚══════╝  ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝     ╚═╝  ╚═╝╚═╝   ╚═╝    |
    +----------------------------------------------------------------------------------------------------+
    "
    echo -e "${GREEN_BOLD}✅ 安装完成！${RESET} "
    echo -e "${GREEN_BOLD}   现在你可以通过输入 ${YELLOW_BOLD}v${GREEN_BOLD} 或 ${YELLOW_BOLD}vsk${GREEN_BOLD} 命令来唤出管理菜单。${RESET}"
    echo ""
}

# --- 脚本执行入口 ---

# 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
    error_exit "此脚本需要以 root 权限运行。请使用 'sudo bash $0' 再次尝试。"
fi

# 检查依赖 (只需要 curl)
if ! command_exists "curl"; then
    error_exit "此脚本需要 'curl' 命令，但它未被安装。请先安装它。"
fi

# 调用主函数
install_main

#!/bin/bash

# 当任何命令失败时立即退出脚本
set -e

### === 脚本描述 === ###
# 名称： install.sh
# 功能： 安装 VpsScriptKit 脚本
# 作者： YourName
# 创建日期：2025-07-15
# 许可证：MIT

### === 配置 === ###
# 安装目录
INSTALL_DIR="/opt/VpsScriptKit"
# 仓库地址
REPO="oliver556/VpsScriptKit"
# 用户许可协议同意
AGREEMENT_ACCEPTED="false"

### === 颜色定义 === ###
BOLD_WHITE=$(tput bold)$(tput setaf 7)    # 加粗白色
BOLD_RED=$(tput bold)$(tput setaf 1)      # 加粗红色
BOLD_GREEN=$(tput bold)$(tput setaf 2)    # 加粗绿色
BOLD_YELLOW=$(tput bold)$(tput setaf 3)   # 加粗黄色
BOLD_BLUE=$(tput bold)$(tput setaf 4)     # 加粗蓝色

### === 函数定义 === ###
# 函数：退出脚本并显示错误信息
error_exit() {
    echo -e "${BOLD_RED}错误: $1${BOLD_WHITE}" >&2
    exit 1
}

# 函数：检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函数：获取最新发行版的下载链接
# 通过 echo 将结果输出，以便被调用者捕获
get_latest_release_url() {
    echo -e "${BOLD_BLUE}--> 正在查询最新版本...${BOLD_WHITE}" >&2
    
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

    echo -e "${BOLD_BLUE}--> 正在下载并解压文件...${BOLD_WHITE}" >&2
    
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

    # 询问用户是否同意协议
    confirm_agreement

    # ✅ 如果用户不同意 (变量仍为 "false")，则退出安装
    if [[ "$AGREEMENT_ACCEPTED" != "true" ]]; then
        echo
        echo -e "${BOLD_RED}您已拒绝用户协议，安装已取消。${BOLD_WHITE}"
        rm -rf "$INSTALL_DIR"
        rm -rf "/usr/local/bin/vsk"
        rm -rf "/usr/local/bin/v"
        sleep 1
        clear
        exit 1
    fi

    echo
    # 1. 清理旧版本
    # 如果存在旧版本，则清理
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${CYAN}🧹 正在清理旧版本...${BOLD_WHITE}"
        rm -rf "$INSTALL_DIR"
        rm -rf "/usr/local/bin/vsk"
        rm -rf "/usr/local/bin/v"
        sleep 1
        echo
        echo -e "${CYAN}✅ 脚本已清理，即将覆盖安装！${BOLD_WHITE}"
        sleep 2
        clear
    fi

    echo -e "${BOLD_GREEN}正在安装 VpsScriptKit...${BOLD_WHITE}"

    # 2. 调用函数获取最新发行版的下载链接
    local latest_url
    latest_url=$(get_latest_release_url)
    echo -e "--> 找到最新版本，准备从以下链接下载:\n    $latest_url"

    # 3. 调用函数下载并解压文件
    download_and_extract "$latest_url"

    # 4. 设置权限
    echo -e "${BOLD_BLUE}--> 正在设置文件权限...${BOLD_WHITE}"
    find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} +

    # 5. 创建快速启动命令
    echo -e "${BOLD_BLUE}--> 正在创建快速启动命令...${BOLD_WHITE}"
    if [ -f "$INSTALL_DIR/vps_script_kit.sh" ]; then
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/v
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/vsk
    else
        echo -e "${BOLD_YELLOW}警告: 未在仓库根目录找到 vps_script_kit.sh，跳过创建快捷命令。${BOLD_WHITE}"
    fi

    # 6. 显示成功信息
    clear
    
    cat <<-EOF
+----------------------------------------------------------------------------------------------------+
|  ██╗     ██╗█████████╗███████╗  ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗  ██╗  ██╗██╗████████╗ |
|  ██╗     ██║██╔════██║██╔════╝  ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝  ██║ ██╔╝██║╚══██╔══╝ |
|   ██╗   ██╗ █████████║███████╗  ███████╗██║     ██████╔╝██║██████╔╝   ██║     █████╔╝ ██║   ██║    |
|    ██╗ ██╗  ██╔══════╝╚════██║  ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║     ██╔═██╗ ██║   ██║    |
|     ████╗  ║██║       ███████║  ███████║╚██████╗██║  ██║██║██║        ██║     ██║  ██╗██║   ██║    |
|     ╚═══╝  ╚══╝       ╚══════╝  ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝     ╚═╝  ╚═╝╚═╝   ╚═╝    |
+----------------------------------------------------------------------------------------------------+
EOF
    echo -e "${BOLD_GREEN}✅ 安装完成！${BOLD_WHITE} "
    echo -e "${BOLD_GREEN}   现在你可以通过输入 ${BOLD_YELLOW}v${BOLD_GREEN} 或 ${BOLD_YELLOW}vsk${BOLD_GREEN} 命令来唤出管理菜单。${BOLD_WHITE}"
    echo ""
}

# ✅ 显示并确认用户协议。只负责询问并设置全局变量，不负责退出
confirm_agreement() {
    clear
    echo -e "${BLUE}欢迎使用 VpsScriptKit 脚本工具箱${BOLD_WHITE}"
    echo -e "${BOLD_YELLOW}在继续安装之前，请先阅读并同意用户协议。${BOLD_WHITE}"
    echo "─────────────────────────────────────────────────────"
    # 您可以在这里替换成您的真实用户协议文本
	echo "用户许可协议: https://"
    echo "─────────────────────────────────────────────────────"
    
    # 读取用户输入
    local choice
    read -r -p "您是否同意以上条款？(y/n): " choice
    echo

    # 将输入转换为小写以便比较
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    # 如果用户同意，将全局变量设置为 "true"
    if [[ "$choice" == "y" ]]; then
        # 如果用户同意，将全局变量设置为 "true"
        AGREEMENT_ACCEPTED="true"
        echo -e "${BOLD_GREEN}您已同意用户协议，安装将继续...${BOLD_WHITE}"
    fi
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

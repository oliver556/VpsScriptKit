#!/bin/bash

### === 脚本描述 === ###
# 名称： install.sh
# 功能： 安装脚本
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

# 安装目录
INSTALL_DIR="/opt/VpsScriptKit"
# 仓库地址
REPO="oliver556/VpsScriptKit"
# 仓库分支
BRANCH="main"
# 构造 Tarball 下载链接
TARBALL_URL="https://github.com/$REPO/releases/latest/download/release.tar.gz"

### === 颜色定义 === ###
RESET="\033[0m"
RED_BOLD="\033[1;31m"
GREEN_BOLD="\033[1;32m"
YELLOW_BOLD="\033[1;33m"
BLUE_BOLD="\033[1;34m"

# 打印错误信息并退出
error_exit() {
    echo -e "${RED_BOLD}错误: $1${RESET}" >&2
    exit 1
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

download_files() {
    # 创建一个临时文件来存放下载的压缩包
    TMP_TARBALL=$(mktemp)

    # 1. 使用 curl 下载压缩包
    curl -L "$TARBALL_URL" -o "$TMP_TARBALL" || error_exit "下载仓库压缩包失败！"

    echo -e "${BLUE_BOLD}下载完成，正在解压...${RESET}"
    
    # 2. 创建安装目录
    mkdir -p "$INSTALL_DIR" || error_exit "创建安装目录 $INSTALL_DIR 失败！"
    
    # 3. 解压到目标目录
    # -x: 提取
    # -z: 处理 gzip 压缩
    # -f: 指定文件
    # --strip-components=1: 忽略压缩包内的第一层目录结构
    tar -xzf "$TMP_TARBALL" --strip-components=1 -C "$INSTALL_DIR" || error_exit "解压文件失败！"
    
    # 4. 清理临时文件
    rm -f "$TMP_TARBALL"

    echo -e "${BLUE_BOLD}--- 安装文件准备就绪 ---${RESET}"
}

install_main() {
    # 检查是否已安装
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${RED_BOLD}❌ 脚本已安装！${RESET}"
        exit 1
    fi

    echo -e "${GREEN_BOLD}正在安装 VpsScriptKit 到 $INSTALL_DIR 中，请稍后...${RESET}"

    # ✅ 创建安装目录和模块子目录
    mkdir -p "$INSTALL_DIR/modules.d" || error_exit "无法创建安装目录 $INSTALL_DIR。"

    # ✅ 下载主脚本
    echo "📄 下载主脚本"
    curl -fSL "https://raw.githubusercontent.com/$REPO/$BRANCH/vps_script_kit.sh" -o "$INSTALL_DIR/vps_script_kit.sh" || error_exit "下载主脚本失败！"

    # # ✅ 获取 modules.d 下所有文件名
    # module_files=$(curl -sSL "https://api.github.com/repos/$REPO/contents/modules.d" | grep '"name":' | cut -d '"' -f4)

    # # ✅ 下载所有模块文件
    # for file in $module_files; do
    #     echo "📄 下载模块：$file"
    #     curl -sSL "https://raw.githubusercontent.com/$REPO/main/modules.d/$file" -o "$INSTALL_DIR/modules.d/$file"
    # done

    download_files

    echo -e "${BLUE_BOLD}--- 所有下载任务处理完成 ---${RESET}"

    echo -e "${BLUE_BOLD}正在设置文件权限...${RESET}"
    # ✅ 设置主脚本权限
    chmod +x "$INSTALL_DIR/vps_script_kit.sh"
    # ✅ 使用 find 命令为所有子目录中的 .sh 文件设置执行权限，更通用
    find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} +

    # ✅ 创建快速启动命令，vsk 以及 v
    echo -e "${BLUE_BOLD}正在创建快速启动命令...${RESET}"
    if [ -f "$INSTALL_DIR/vps_script_kit.sh" ]; then
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/v
        ln -sf "$INSTALL_DIR/vps_script_kit.sh" /usr/local/bin/vsk
    else
        echo -e "${YELLOW_BOLD}警告: 未在仓库根目录找到 vps_script_kit.sh，跳过创建快捷命令。${RESET}"
    fi

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

# 1. 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
    error_exit "此脚本需要以 root 权限运行。请使用 'sudo bash $0' 再次尝试。"
fi

# 2. 检查依赖
for cmd in curl jq; do
    if ! command_exists "$cmd"; then
        error_exit "此脚本需要 '$cmd' 命令，但它未被安装。请先安装它。"
    fi
done

install_main

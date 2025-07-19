#!/bin/bash

# ==============================================================================
# == 公共初始化脚本 (Common Initializer)
# ==
# == 功能：
# == 1. 自动计算并导出项目的所有核心目录路径作为全局变量。
# == 2. 导入所有模块都需要的公共配置文件和函数库。
# ==============================================================================

### === 函数：通过向上查找 vps_script_kit.sh 文件来定位项目根目录 === ###
find_root() {
    # 从当前脚本所在的目录开始查找
    local dir
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # 循环向上遍历，直到根目录 /vps_script_kit 为止
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/vps_script_kit.sh" ]]; then
            # 如果在当前目录找到了标志性文件，就打印这个目录路径并成功返回
            echo "$dir"
            return 0
        fi
        # 否则，移动到上一级目录
        dir="$(dirname "$dir")"
    done
    # 如果一直找到 / 都没找到，则返回失败
    return 1
}

### === 使用函数找到根目录 === ###
ROOT_DIR="$(find_root)"

### === 检查是否成功找到根目录 === ###
if [[ -z "$ROOT_DIR" ]]; then
    echo "错误: 无法定位项目根目录 (vps_script_kit.sh 未找到)！" >&2
    exit 1
fi

### === 导出所有核心路径变量，使其在调用此脚本的 Shell 中也可用 === ###
export ROOT_DIR
export CONFIG_DIR="$ROOT_DIR/config"
export LIB_DIR="$ROOT_DIR/lib"
export MODULE_DIR="$ROOT_DIR/modules.d"
export LOG_DIR="$ROOT_DIR/logs"
export SHELL_SCRIPTS_DIR="$ROOT_DIR/shell_scripts"

### === 读取并导出脚本版本号 === ###
# 初始化一个默认版本号，防止 .version 文件不存在或读取失败
SCRIPT_VERSION="N/A"
VERSION_FILE="$ROOT_DIR/.version"

# 检查 .version 文件是否存在且可读
if [[ -r "$VERSION_FILE" ]]; then
    # 读取文件内容并赋值给 SCRIPT_VERSION 变量
    read -r SCRIPT_VERSION < "$VERSION_FILE"
fi

### === 导出版本号变量，使其在所有子脚本中都可用 === ###
export SCRIPT_VERSION

### === 导入所有公共依赖项 === ###
# 任何 source 了 init_lib.sh 的脚本，都将自动获得这些文件中的变量和函数
source "$CONFIG_DIR/color.sh"
source "$CONFIG_DIR/constant.sh"
source "$LIB_DIR/public/public_lib.sh"


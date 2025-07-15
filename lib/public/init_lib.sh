#!/bin/bash

# ==============================================================================
# == 公共初始化脚本 (Common Initializer)
# ==
# == 功能：
# == 1. 定义项目根目录变量 (PROJECT_ROOT)。
# == 2. 导入所有模块都需要的公共配置文件和函数库。
# == 
# == 创建日期: 2025-07-15
# == 许可证: MIT
# ==============================================================================

# 定义项目根目录。
# 此脚本位于 lib/ 目录下，因此项目根目录是其上两级目录。
PROJECT_ROOT=$(dirname -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")")

# 导出 PROJECT_ROOT 变量，使其在调用此脚本的 Shell 中也可用
export PROJECT_ROOT

# 导入所有公共依赖项
source "$PROJECT_ROOT/config/color.sh"          # 颜色定义库
source "$PROJECT_ROOT/config/constant.sh"       # 常量库
source "$PROJECT_ROOT/lib/public/public_lib.sh" # 公共函数库

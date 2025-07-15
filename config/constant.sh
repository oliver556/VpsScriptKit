#!/bin/bash

### === 脚本描述 === ###
# 名称: constant.sh
# 功能: 常量库
# 作者: 
# 创建日期: 2025-07-15
# 许可证: MIT


### === 版本信息 === ###
SCRIPT_VERSION="0.0.5"
SCRIPT_NAME="vps_script_kit.sh"

### === 退出状态码 === ###
EXIT_SUCCESS=0
EXIT_ERROR=1
EXIT_INTERRUPT=130

# 项目根目录
PROJECT_ROOT_DIR=$(cd $(dirname $0); pwd)

# 模块目录
MODULES_DIR=${PROJECT_ROOT_DIR}/modules

# 分割线宽度
width_70=70
width_60=60
width_40=40
width_20=20
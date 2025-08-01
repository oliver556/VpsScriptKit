#!/bin/bash

### =================================================================================
# @名称:         constant.sh
# @功能描述:     常量库
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 全局地址代理 === ###
GH_PROXY="https://github.viplee.top/"

### === 版本信息 === ###
SCRIPT_NAME="vps_script_kit.sh"

### === 日志文件 === ###
LOG_FILE="$LOG_DIR/vps_script_kit.log"

### === 退出状态码 === ###
EXIT_SUCCESS=0
EXIT_ERROR=1
EXIT_INTERRUPT=130

### === 脚本安装目录 === ###
INSTALL_DIR="/opt/VpsScriptKit"

### === 仓库地址 === ###
REPO="oliver556/VpsScriptKit"

### === 自动更新的 Cron 任务标识 === ###
CRON_COMMENT="VpsScriptKit-AutoUpdate"

### === 证书安装目录 === ###
CERT_INSTALL_DIR="/etc/ssl/acme"

### === 分割线宽度 === ###
width_70=70
width_71=71
width_68=68
width_67=67
width_66=66
width_65=65
width_64=64
width_63=63
width_62=62
width_61=61
width_60=60
width_50=50
width_49=49
width_48=48
width_47=47
width_46=46
width_45=45
width_44=44
width_43=43
width_44=44
width_42=42
width_41=41
width_40=40
width_30=30
width_28=28
width_20=20
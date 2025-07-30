#!/bin/bash

### =================================================================================
# @名称:         update_source.sh
# @功能描述:     切换系统更新源的脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-30
# @修改日期:     2025-07-30
#
# @许可证:       MIT
### =================================================================================

### === 辅助函数：备份当前的 sources.list 文件 === ###
#
# @描述
#   本函数用于备份当前的 sources.list 文件
#
# @示例
#   _backup_sources
_backup_sources() {
    local backup_file="/etc/apt/sources.list.bak_$(date +%Y%m%d_%H%M%S)"
    echo "--> 正在备份当前源到: $backup_file"
    if ! cp /etc/apt/sources.list "$backup_file"; then
        echo_error "备份失败！操作中止。"
        return 1
    fi
    return 0
}

### === 核心函数：根据传入的参数切换源 === ###
#
# @描述
#   本函数用于根据传入的参数切换源
#
# @示例
#   _change_sources
_change_sources() {
    local source_type=$1
    local os_id os_version_codename

    # 1. 检测操作系统和版本
    if [ -f /etc/os-release ]; then
        # 从 /etc/os-release 文件加载系统信息
        . /etc/os-release
        os_id=$ID
        os_version_codename=$VERSION_CODENAME
    else
        echo_error "无法检测到操作系统信息。"
        return 1
    fi

    # 2. 检查是否支持当前系统 (Debian/Ubuntu)
    if [[ "$os_id" != "debian" && "$os_id" != "ubuntu" ]]; then
        echo_error "此功能目前仅支持 Debian 和 Ubuntu 系统。"
        return 1
    fi

    # 3. 备份原始源文件，如果备份失败则中止
    if ! _backup_sources; then
        return 1
    fi

    # 4. 根据操作系统、版本和用户选择，生成新的 sources.list 内容
    echo "--> 正在为 $os_id $os_version_codename 生成新的源列表..."
    
    # 使用 Here Document (<<EOF) 的方式来写入文件，非常清晰
    case "$source_type" in
        "official") # 海外地区 - 官方源
            if [ "$os_id" = "ubuntu" ]; then
                cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
EOF
            elif [ "$os_id" = "debian" ]; then
                cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian/ ${os_version_codename} main contrib non-free
deb-src http://deb.debian.org/debian/ ${os_version_codename} main contrib non-free
deb http://deb.debian.org/debian/ ${os_version_codename}-updates main contrib non-free
deb-src http://deb.debian.org/debian/ ${os_version_codename}-updates main contrib non-free
deb http://deb.debian.org/debian-security/ ${os_version_codename}-security main contrib non-free
deb-src http://deb.debian.org/debian-security/ ${os_version_codename}-security main contrib non-free
EOF
            fi
            ;;
        "aliyun") # 中国大陆 - 阿里源
             if [ "$os_id" = "ubuntu" ]; then
                cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
EOF
            elif [ "$os_id" = "debian" ]; then
                cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ ${os_version_codename} main contrib non-free
deb-src http://mirrors.aliyun.com/debian/ ${os_version_codename} main contrib non-free
deb http://mirrors.aliyun.com/debian/ ${os_version_codename}-updates main contrib non-free
deb-src http://mirrors.aliyun.com/debian/ ${os_version_codename}-updates main contrib non-free
deb http://mirrors.aliyun.com/debian-security/ ${os_version_codename}-security main contrib non-free
deb-src http://mirrors.aliyun.com/debian-security/ ${os_version_codename}-security main contrib non-free
EOF
            fi
            ;;
        "edu") # 中国大陆 - 教育网 (清华 TUNA)
             if [ "$os_id" = "ubuntu" ]; then
                cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
EOF
            elif [ "$os_id" = "debian" ]; then
                cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${os_version_codename} main contrib non-free
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${os_version_codename} main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${os_version_codename}-updates main contrib non-free
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${os_version_codename}-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security/ ${os_version_codename}-security main contrib non-free
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security/ ${os_version_codename}-security main contrib non-free
EOF
            fi
            ;;
        "linuxmirrors") # 中国大陆 - LinuxMirrors 源
             if [ "$os_id" = "ubuntu" ]; then
                cat > /etc/apt/sources.list <<EOF
deb https://mirrors.nekoneko.cloud/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb-src https://mirrors.nekoneko.cloud/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb https://mirrors.nekoneko.cloud/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb-src https://mirrors.nekoneko.cloud/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb https://mirrors.nekoneko.cloud/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb-src https://mirrors.nekoneko.cloud/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb https://mirrors.nekoneko.cloud/ubuntu-security/ ${os_version_codename}-security main restricted universe multiverse
deb-src https://mirrors.nekoneko.cloud/ubuntu-security/ ${os_version_codename}-security main restricted universe multiverse
EOF
            elif [ "$os_id" = "debian" ]; then
                cat > /etc/apt/sources.list <<EOF
deb https://mirrors.nekoneko.cloud/debian/ ${os_version_codename} main contrib non-free
deb-src https://mirrors.nekoneko.cloud/debian/ ${os_version_codename} main contrib non-free
deb https://mirrors.nekoneko.cloud/debian/ ${os_version_codename}-updates main contrib non-free
deb-src https://mirrors.nekoneko.cloud/debian/ ${os_version_codename}-updates main contrib non-free
deb https://mirrors.nekoneko.cloud/debian-security/ ${os_version_codename}-security main contrib non-free
deb-src https://mirrors.nekoneko.cloud/debian-security/ ${os_version_codename}-security main contrib non-free
EOF
            fi
            ;;
        *) # 默认 (中国大陆 - 中科大 USTC 源)
             if [ "$os_id" = "ubuntu" ]; then
                cat > /etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename} main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename}-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename}-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ ${os_version_codename}-security main restricted universe multiverse
EOF
            elif [ "$os_id" = "debian" ]; then
                cat > /etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/debian/ ${os_version_codename} main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ ${os_version_codename} main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ ${os_version_codename}-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ ${os_version_codename}-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian-security/ ${os_version_codename}-security main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ ${os_version_codename}-security main contrib non-free
EOF
            fi
            ;;
    esac

    # 5. 提示用户更新缓存
    echo_success "更新源已成功切换！"
    echo_warning "建议立即运行一次系统更新来刷新本地缓存。"
    read -p "是否立即执行 'apt update'? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        apt update
    fi
}

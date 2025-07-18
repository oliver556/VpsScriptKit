#!/bin/bash

### === 脚本描述 === ###
# 名称： system_clean.sh
# 功能： 系统清理
# 作者：
# 创建日期：
# 许可证：MIT

### === 系统清理 === ###
system_clean_utils() {
    clear
    echo -e "${BOLD_YELLOW}正在系统清理...${WHITE}"
    echo -e "${LIGHT_CYAN}--------------------------------${WHITE}"
    # Fedora, CentOS 8+, RHEL 8+
    if command -v dnf &>/dev/null; then
        rpm --rebuilddb                # 重建 RPM 数据库
        dnf autoremove -y              # 自动删除不再需要的依赖包
        dnf clean all                  # 清理所有 dnf 缓存
        dnf makecache                  # 重新生成 dnf 缓存
        journalctl --rotate            # 轮转 systemd 日志文件
        journalctl --vacuum-time=1s    # 删除1秒前的日志
        journalctl --vacuum-size=500M  # 日志总大小超过500M时进行清理
    # CentOS ≤7, RHEL ≤7, Amazon Linux
    elif command -v yum &>/dev/null; then
        rpm --rebuilddb
        yum autoremove -y
        yum clean all
        yum makecache
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=500M
    # Debian, Ubuntu, Mint, Kali 等
    elif command -v apt &>/dev/null; then
        fix_dpkg
        apt autoremove --purge -y      # 删除不再需要的包及其配置文件
        apt clean -y                   # 清理下载的软件包缓存
        apt autoclean -y               # 清理过期的软件包缓存
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=500M
    # Alpine Linux
    elif command -v apk &>/dev/null; then
        echo "清理包管理器缓存..."
        apk cache clean                # 清理 apk 包管理器缓存
        echo "删除系统日志..."
        rm -rf /var/log/*              # 删除所有系统日志
        echo "删除APK缓存..."
        rm -rf /var/cache/apk/*        # 删除 apk 的缓存目录
        echo "删除临时文件..."
        rm -rf /tmp/*                  # 删除临时文件
    # Arch Linux, Manjaro 等
    elif command -v pacman &>/dev/null; then
        pacman -Rns $(pacman -Qdtq) --noconfirm  # 删除孤立依赖包
        pacman -Scc --noconfirm                  # 清理所有缓存
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=500M
    # openSUSE, SUSE Linux Enterprise
    elif command -v zypper &>/dev/null; then
        zypper clean --all             # 清理所有 zypper 缓存
        zypper refresh                 # 刷新仓库元数据
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=500M
    # OpenWrt, LEDE, 嵌入式 Linux
    elif command -v opkg &>/dev/null; then
        echo "删除系统日志..."
        rm -rf /var/log/*              # 删除所有日志
        echo "删除临时文件..."
        rm -rf /tmp/*                  # 删除临时文件
    # FreeBSD/部分类Unix
    elif command -v pkg &>/dev/null; then
        echo "清理未使用的依赖..."
        pkg autoremove -y
        echo "清理包管理器缓存..."
        pkg clean -y
        echo "删除系统日志..."
        rm -rf /var/log/*
        echo "删除临时文件..."
        rm -rf /tmp/*
    else
        echo "未知的包管理器!"
        return
    fi
    return
}

### === 主函数 === ###
system_clean_main() {
    system_clean_utils
}

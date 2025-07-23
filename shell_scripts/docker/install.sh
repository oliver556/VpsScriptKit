#!/bin/bash

### =================================================================================
# @名称:         install.sh
# @功能描述:      docker 安装
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-23
# @修改日期:     2025-07-23
#
# @许可证:       MIT
### =================================================================================

### === 安装 Docker === ###
#
# @描述
#   在 Debian/Ubuntu 系统上安装 Docker
###
install_docker_debian() {
    echo_info "--- 正在为 Debian/Ubuntu 安装 Docker ---${RESET}"

    # 1. 更新 apt 包索引并安装依赖
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl

    # 2. 添加 Docker 的官方 GPG 密钥
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # 3. 设置 Docker 的 apt 仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 4. 安装 Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo -e "${LIGHT_GREEN}Debian/Ubuntu 上的 Docker 安装完成。${RESET}"
}

### === 安装 Docker === ###
#
# @描述
#   在 CentOS/RHEL/Fedora 系统上安装 Docker
###
install_docker_rhel() {
    echo_info "--- 正在为 RHEL/CentOS/Fedora 安装 Docker ---${RESET}"

    PKG_MANAGER="yum"
    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    fi

    # 1. 安装依赖
    sudo $PKG_MANAGER install -y ${PKG_MANAGER}-utils

    # 2. 设置 Docker 的仓库
    sudo $PKG_MANAGER config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # 3. 安装 Docker Engine
    sudo $PKG_MANAGER install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo -e "${LIGHT_GREEN}RHEL/CentOS/Fedora 上的 Docker 安装完成。${RESET}"
}


### === 启动 Docker === ###
#
# @描述
#   本启动 Docker 并设置开机自启
###
start_and_enable_docker() {
    echo -e "${LIGHT_BLUE}--- 启动并启用 Docker 服务 ---${RESET}"
    if sudo systemctl start docker && sudo systemctl enable docker; then
        echo -e "${LIGHT_GREEN}Docker 已成功启动并设置为开机自启。${RESET}"
    else
        echo -e "${LIGHT_RED}启动或启用 Docker 服务失败。${RESET}"
    fi
}

### === 安装 Docker 主函数 === ###
#
# @描述
#   判断是否 root 用户
#   判断系统类型并调用对应系统类型安装 Docker
###
docker_install_main() {
    if ! is_user_root; then
        break_end
    fi

    local os_type
    os_type=$(get_os_type)

    # 判断系统类型
    case $os_type in
        "debian_like")
            install_docker_debian
            start_and_enable_docker
            ;;
        "rhel_like")
            install_docker_rhel
            start_and_enable_docker
            ;;
        *)
            echo -e "${C_RED}抱歉，您的操作系统 (${os_type}) 不在自动支持范围内。${RESET}"
            echo "请参考 Docker 官方文档进行手动安装。"
            ;;
    esac
}

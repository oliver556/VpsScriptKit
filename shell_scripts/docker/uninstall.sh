#!/bin/bash
### =================================================================================
# @名称:         uninstall.sh
# @功能描述:      docker 卸载
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-23
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 卸载 Docker 在 Debian/Ubuntu 系统上 === ###
#
# @描述
#   在 Debian/Ubuntu 系统上彻底卸载 Docker。
#
# @示例
#   uninstall_docker_debian
###
uninstall_docker_debian() {
    echo -e "${LIGHT_YELLOW}--- 正在从 Debian/Ubuntu 卸载 Docker ---${RESET}"

    # 1. 停止并禁用 Docker 服务
    echo -e "${LIGHT_BLUE}--> 停止 Docker 服务...${RESET}"
    sudo systemctl stop docker
    sudo systemctl disable docker

    # 2. 卸载所有 Docker 相关的软件包
    echo -e "${LIGHT_BLUE}--> 卸载 Docker 软件包...${RESET}"
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

    # 3. 删除所有 Docker 数据 (这是一个危险操作!)
    echo -e "${C_RED}--> 警告: 即将删除所有 Docker 数据，包括镜像、容器和卷...${RESET}"
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd

    # 4. 删除 Docker 的 apt 仓库配置和 GPG 密钥
    echo -e "${LIGHT_BLUE}--> 清理软件仓库配置...${RESET}"
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo rm -f /etc/apt/keyrings/docker.asc

    # 5. 清理不再需要的依赖包并更新
    echo -e "${LIGHT_BLUE}--> 清理系统依赖...${RESET}"
    sudo apt-get autoremove -y
    sudo apt-get update

    echo_success "Docker 已在 Debian/Ubuntu 上被彻底卸载。"
}

### === 卸载 Docker 在 CentOS/RHEL/Fedora 系统上 === ###
#
# @描述
#   在 CentOS/RHEL/Fedora 系统上彻底卸载 Docker。
#
# @示例
#   uninstall_docker_rhel
###
uninstall_docker_rhel() {
    echo -e "${C_YELLOW}--- 正在从 RHEL/CentOS/Fedora 卸载 Docker ---${RESET}"

    PKG_MANAGER="yum"
    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    fi

    # 1. 停止并禁用 Docker 服务
    echo -e "${LIGHT_BLUE}--> 停止 Docker 服务...${RESET}"
    sudo systemctl stop docker
    sudo systemctl disable docker

    # 2. 卸载所有 Docker 相关的软件包
    echo -e "${LIGHT_BLUE}--> 卸载 Docker 软件包...${RESET}"
    sudo $PKG_MANAGER remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 3. 删除所有 Docker 数据 (这是一个危险操作!)
    echo -e "${C_RED}--> 警告: 即将删除所有 Docker 数据，包括镜像、容器和卷...${RESET}"
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd

    # 4. 删除 Docker 的 yum 仓库配置文件
    echo -e "${LIGHT_BLUE}--> 清理软件仓库配置...${RESET}"
    sudo rm -f /etc/yum.repos.d/docker-ce.repo

    # 5. 清理不再需要的依赖包
    echo -e "${LIGHT_BLUE}--> 清理系统依赖...${RESET}"
    sudo $PKG_MANAGER autoremove -y

    echo -e "${C_GREEN}Docker 已在 RHEL/CentOS/Fedora 上被彻底卸载。${RESET}"
}

### === 卸载 Docker 判断 === ###
#
# @描述
#   判断系统类型并调用对应系统类型安装 Docker。
#
# @示例
#   docker_uninstall_utils
###
docker_uninstall_utils() {

    local os_type
    os_type=$(get_os_type)
    echo -e "${LIGHT_RED}警告: 这个操作将彻底删除 Docker 及其所有数据 (镜像, 容器, 卷)。${RESET}"
    read -rp "您确定要继续吗? (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        case "$os_type" in
            "debian_like")
                uninstall_docker_debian
                ;;
            "rhel_like")
                uninstall_docker_rhel
                ;;
            *)
                echo -e "${LIGHT_RED}抱歉，您的操作系统 (${os_type}) 不在自动支持范围内。${RESET}"
                ;;
        esac
    else
        echo "已取消卸载操作。"
    fi
}

### === 卸载 Docker 主函数 === ###
#
# @描述
#   本函数用于判断是否 root 用户
#   判断系统类型并调用对应系统类型安装 Docker。
#
# @示例
#   docker_uninstall_main
###
docker_uninstall_main() {
    if ! is_user_root; then
        break_end
    fi
    docker_uninstall_utils
}


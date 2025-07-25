#!/bin/bash
### =================================================================================
# @名称:         global_status.sh
# @功能描述:      docker 查看全局状态
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-23
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 查看 Docker 全局状态 === ###
#
# @描述
#   本函数用于查看 Docker 全局状态。
#
# @示例
#   docker_global_status
###
docker_global_status() {
    clear
    sub_menu_title "Docker 全局状态"

    # 1. 检查 Docker 是否安装
    if ! command -v docker &> /dev/null; then
        echo -e "\nDocker 环境: ${C_RED}未安装${C_RESET}"
        return
    fi

    # --- 如果程序能走到这里，说明 Docker 已安装 ---

    # 2. 安全地获取 Docker 版本信息
    echo -n -e "Docker 版本: ${LIGHT_GREEN}"
    docker -v

    # 3. 安全地获取 Docker Compose 版本信息 (增加对 compose 插件是否存在的判断)
    echo -n -e "Compose 版本: ${LIGHT_GREEN}"
    if docker compose version &> /dev/null; then
        # 如果 compose 插件存在，则显示版本
        docker compose version
    else
        # 如果 compose 插件不存在，则显示提示
        echo "未安装 (或版本过旧)"
    fi

    # 4. 安全地获取并显示所有统计信息
    local container_count=$(docker ps -a -q | wc -l)
    local image_count=$(docker images -q | wc -l)
    local network_count=$(docker network ls -q | wc -l)
    local volume_count=$(docker volume ls -q | wc -l)

    echo
    gran_menu_title "Docker 镜像: ${LIGHT_GREEN}$image_count${RESET} "
    docker image ls

    echo
    gran_menu_title "Docker 容器: ${LIGHT_GREEN}$container_count${RESET}"
    docker ps -a

    echo
    gran_menu_title "Docker 卷: ${LIGHT_GREEN}$volume_count${RESET}"
    docker volume ls

    echo
    gran_menu_title "Docker 网络: ${LIGHT_GREEN}$network_count${RESET}"
    docker network ls
}

### === 查看 Docker 全局状态 主函数 === ###
#
# @描述
#   本函数用于查看 Docker 全局状态主函数。
#
# @示例
#   docker_global_status_main
###
docker_global_status_main() {
    docker_global_status
}


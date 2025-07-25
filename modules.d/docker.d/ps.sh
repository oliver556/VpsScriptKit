#!/bin/bash

### =================================================================================
# @名称:         ps.sh
# @功能描述:     Docker 容器管理
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-23
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === Docker 容器管理 主菜单 === ###
#
# @描述
#   本函数用于显示 Docker 容器主菜单。
#
# @示例
#   docker_ps_menu
###
docker_ps_menu() {
    while true; do
        clear
        sub_menu_title "🖥️  Docker 容器"
        gran_menu_title "[A] 所有容器列表" "front_line"
        docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
        gran_menu_title "[B] 容器操作" "front_line"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}1.  ${WHITE}创建新容器"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}2.  ${WHITE}启动指定容器      ${LIGHT_CYAN}6.  ${WHITE}启动所有容器"
        echo -e "${LIGHT_CYAN}3.  ${WHITE}停止指定容器      ${LIGHT_CYAN}7.  ${WHITE}停止所有容器"
        echo -e "${LIGHT_CYAN}4.  ${WHITE}删除指定容器      ${LIGHT_CYAN}8.  ${WHITE}删除所有容器"
        echo -e "${LIGHT_CYAN}5.  ${WHITE}重启指定容器      ${LIGHT_CYAN}9.  ${WHITE}重启所有容器"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}11. ${WHITE}进入指定容器      ${LIGHT_CYAN}12. ${WHITE}查看容器日志"
        echo -e "${LIGHT_CYAN}13. ${WHITE}查看容器网络      ${LIGHT_CYAN}14. ${WHITE}查看容器占用"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单                                               ${LIGHT_CYAN}#"
        print_echo_line_3
        echo ""
        read -rp "👉 请输入你的选择: " MAIN_OPTION

        case $MAIN_OPTION in
            1)
                read -p "请输入创建命令: " docker_create_command
                $docker_create_command
                ;;
            2)
                read -p "请输入启动命令: " docker_start_command
                docker start $docker_start_command
                ;;
            3)
                read -p "请输入停止命令: " docker_stop_command
                docker stop $docker_stop_command
                ;;
            4)
                read -p "请输入删除命令: " docker_delete_command
                docker rm $docker_delete_command
                ;;
            5)
                read -p "请输入重启命令: " docker_restart_command
                docker restart $docker_restart_command
                ;;
            6)
                docker start $(docker ps -a -q)
                ;;
            7)
                docker stop $(docker ps -q)
                ;;
            8)
                read -p "确定删除所有容器吗？(Y/N): " choice
                    case "$choice" in
                        [Yy])
                            docker rm -f $(docker ps -a -q)
                            ;;
                        [Nn])
                            ;;
                        *)
                            echo "无效的选择，请输入 Y 或 N。"
                            ;;
                    esac
                ;;
            9)
                docker restart $(docker ps -q)
                ;;
            11)
                read -p "请输入容器名: " docker_enter_command
                docker exec -it $docker_enter_command /bin/bash
                break_end
                ;;
            12)
                read -p "请输入容器名: " docker_log_command
                docker logs -f $docker_log_command
                break_end
                ;;
            13)
                echo ""
                container_ids=$(docker ps -q)

                echo "------------------------------------------------------------"
                printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"

                for container_id in $container_ids; do
                    container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

                    container_name=$(echo "$container_info" | awk '{print $1}')
                    network_info=$(echo "$container_info" | cut -d' ' -f2-)

                    while IFS= read -r line; do
                        network_name=$(echo "$line" | awk '{print $1}')
                        ip_address=$(echo "$line" | awk '{print $2}')

                        printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
                    done <<< "$network_info"
                done
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

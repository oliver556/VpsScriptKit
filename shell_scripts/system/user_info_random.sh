#!/bin/bash

### =================================================================================
# @名称:         user_info_random.sh
# @功能描述:     用户信息随机生成脚本。
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-27
# @修改日期:     2025-07-27
#
# @许可证:       MIT
### =================================================================================

### === 用户信息随机生成 主菜单 === ###
#
# @描述
#   本函数用于显示用户信息随机生成主菜单。
#
# @示例
#   system_user_info_random_menu
###
get_user_info_random() {
    clear
    sub_menu_title "⚙️  用户信息随机生成"

    gran_menu_title "[A] 随机用户名"

    for i in {1..5}; do
        username="user$(< /dev/urandom tr -dc _a-z0-9 | head -c6)"
        echo -e "${LIGHT_CYAN}随机用户名 $i: ${LIGHT_WHITE}$username"
    done

    gran_menu_title "[B] 随机姓名" "front_line"
    local first_names=("John" "Jane" "Michael" "Emily" "David" "Sophia" "William" "Olivia" "James" "Emma" "Ava" "Liam" "Mia" "Noah" "Isabella")
    local last_names=("Smith" "Johnson" "Brown" "Davis" "Wilson" "Miller" "Jones" "Garcia" "Martinez" "Williams" "Lee" "Gonzalez" "Rodriguez" "Hernandez")

    # 生成5个随机用户姓名
    for i in {1..5}; do
        local first_name_index=$((RANDOM % ${#first_names[@]}))
        local last_name_index=$((RANDOM % ${#last_names[@]}))
        local user_name="${first_names[$first_name_index]} ${last_names[$last_name_index]}"
        echo -e "${LIGHT_CYAN}随机用户姓名 $i: ${LIGHT_WHITE}$user_name"
    done

    gran_menu_title "随机UUID"
    for i in {1..5}; do
        uuid=$(cat /proc/sys/kernel/random/uuid)
        echo -e "${LIGHT_CYAN}随机UUID $i: ${LIGHT_WHITE}$uuid"
    done

    gran_menu_title "16位随机密码"
    for i in {1..5}; do
        local password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
        echo -e "${LIGHT_CYAN}随机密码 $i: ${LIGHT_WHITE}$password"
    done

    gran_menu_title "32位随机密码"
    for i in {1..5}; do
        local password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
        echo -e "${LIGHT_CYAN}随机密码 $i: ${LIGHT_WHITE}$password"
    done
}

#!/bin/bash

### =================================================================================
# @名称:         timing_tasks.sh
# @功能描述:     定时任务管理。
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-27
# @修改日期:     2025-07-27
#
# @许可证:       MIT
### =================================================================================



### === 定时任务管理 主菜单 === ###
#
# @描述
#   本函数用于显示定时任务管理主菜单。
#
# @示例
#   system_timing_tasks_menu
###
system_timing_tasks_menu() {
    
    while true; do
        clear
        sub_menu_title "⚙️  切换优先ipv4/ipv6"
        echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}添加定时任务            ${LIGHT_CYAN}2.  ${LIGHT_WHITE}删除定时任务            ${LIGHT_CYAN}3.  ${LIGHT_WHITE}编辑定时任务"
        print_echo_line_3
        echo -e "${LIGHT_CYAN}0.  ${LIGHT_WHITE}返回上一级菜单"
        print_echo_line_3
        echo ""
        read -r -p "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            1)
                clear
                read -e -p "请输入新任务的执行命令: " newquest
                print_echo_line_1
                echo -e "${LIGHT_CYAN}1.  ${LIGHT_WHITE}每月任务                 ${LIGHT_CYAN}2.  ${LIGHT_WHITE}每周任务"
                echo -e "${LIGHT_CYAN}3.  ${LIGHT_WHITE}每天任务                 ${LIGHT_CYAN}4.  ${LIGHT_WHITE}每小时任务"
                print_echo_line_1
                read -e -p "请输入你的选择: " dingshi

                case $dingshi in
                    1)
                        read -e -p "选择每月的几号执行任务？ (1-30): " day
                        (crontab -l ; echo "0 0 $day * * $newquest") | crontab - > /dev/null 2>&1
                        echo -e "${LIGHT_GREEN}已添加每月任务${LIGHT_WHITE}"
                        break_end
                        ;;
                    2)
                        read -e -p "选择周几执行任务？ (0-6, 0代表星期日): " weekday
                        (crontab -l ; echo "0 0 * * $weekday $newquest") | crontab - > /dev/null 2>&1
                        echo -e "${LIGHT_GREEN}已添加每周任务${LIGHT_WHITE}"
                        break_end
                        ;;
                    3)
                        read -e -p "选择每天几点执行任务？ (小时, 0-23) : " hour
                        (crontab -l ; echo "0 $hour * * * $newquest") | crontab - > /dev/null 2>&1
                        echo -e "${LIGHT_GREEN}已添加每天任务${LIGHT_WHITE}"
                        break_end
                        ;;
                    4)
                        read -e -p "输入每小时的第几分钟执行任务? (分钟, 0-60) : " minute
                        (crontab -l ; echo "$minute * * * * $newquest") | crontab - > /dev/null 2>&1
                        echo -e "${LIGHT_GREEN}已添加每小时任务${LIGHT_WHITE}"
                        break_end
                        ;;
                    *)
                        break
                        ;;
                esac
                ;;
            2)
                clear
                read -e -p "请输入需要删除任务的关键字: " kquest
                crontab -l | grep -v "$kquest" | crontab -
                echo -e "${LIGHT_GREEN}已删除任务${LIGHT_WHITE}"
                break_end
                ;;
            3)
                clear
                crontab -e
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}

#!/bin/bash

### =================================================================================
# @名称:         test.sh
# @功能描述:     测试工具
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-15
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === 导入测试工具 脚本 === ###
source "$ROOT_DIR/shell_scripts/test/tool.sh"

### === 测试工具 主菜单 === ###
#
# @描述
#   本函数用于显示测试工具主菜单。
#
# @示例
#   test_menu
###
test_menu() {
    while true; do
        clear
        sub_menu_title "🧪  测试脚本合集"
        # main_menu_title "🧪  测试脚本合集"

	    # echo -e "${LIGHT_CYAN}常用检测"${WHITE}
        gran_menu_title "[A] 网络检测"
        echo -e "${LIGHT_CYAN}1.  ${WHITE}IP 质量测试"
        echo -e "${LIGHT_CYAN}2.  ${WHITE}网络质量测试"
        echo -e "${LIGHT_CYAN}3.  ${WHITE}回程路由"
        # echo -e "${LIGHT_CYAN}2. ${WHITE}ChatGPT 解锁检测"
        # echo -e "${LIGHT_CYAN}3. ${WHITE}Region 解锁检测"
        # echo -e "${LIGHT_CYAN}4. ${WHITE}yeahwu 流媒体解锁检测"
        # print_echo_line_1
        # echo -e "${CYAN}网络线路测试"${WHITE}
        # echo -e "${LIGHT_CYAN}18. ${WHITE}NetQuality 网络质量检测 ${YELLOW}★${WHITE}"
        # print_echo_line_1
        gran_menu_title "[B] 性能检测"
        echo -e "${LIGHT_CYAN}31. ${WHITE}bench 性能测试"
        echo -e "${LIGHT_CYAN}32. ${WHITE}spiritysdx 融合怪测评"
        print_echo_line_1
        echo -e "${LIGHT_CYAN}0.  ${WHITE}返回主菜单"
        print_echo_line_1
        echo ""
        read -rp "👉 请输入你的选择: " sys_choice

        case "$sys_choice" in
            # IP 质量检测
            1)
                clear
                echo "🚀 正在运行 IP 质量检测..."
                bash <(curl -sL Check.Place) -I
                ;;
            # 网络质量检测
            2)
                clear
                echo "🚀 正在运行 NetQuality 网络质量检测..."
                bash <(curl -sL Check.Place) -N
                ;;
            
            # # ChatGPT 解锁检测
            # 2)
            #     clear
            #     echo "🚀 正在运行 ChatGPT 解锁检测..."
            #     bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
            #     ;;
            # # Region 解锁检测
            # 3)
            #     clear
            #     echo "🚀 正在运行 Region 解锁检测..."
            #     bash <(curl -L -s check.unlock.media)
            #     ;;
            # # yeahwu 流媒体解锁检测
            # 4)
            #     clear
            #     install wget
            #     echo "🚀 正在运行 yeahwu 流媒体解锁检测..."
			#     wget -qO- ${gh_proxy}github.com/yeahwu/check/raw/main/check.sh | bash
            #     ;;
            # NetQuality 网络质量体检脚本
            # 18)
            #     clear
            #     echo "🚀 正在运行 NetQuality 网络质量检测..."
            #     bash <(curl -sL Check.Place) -N
            #     ;;
            # bench 性能测试
            31)
                clear
                echo "🚀 正在运行 bench 性能测试..."
                curl -Lso- bench.sh | bash
                ;;
            # spiritysdx 融合怪测评
            32)
                clear
                echo "🚀 正在运行 spiritysdx 融合怪测评..."
                curl -L https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
                ;;
            0) break ;;
            *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
        esac
    done
}
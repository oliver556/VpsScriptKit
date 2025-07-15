#!/bin/bash

### === 脚本描述 === ###
# 名称： test.sh
# 功能： 测试工具
# 作者：
# 创建日期：2025-07-15
# 许可证：MIT

source "$ROOT_DIR/shell_scripts/test/test.tool.sh"

test_menu() {
    while true; do
        clear
        title="🧪  常用测试脚本合集"
        printf "${BLUE}+%${width_40}s+${RESET}\n" | tr ' ' '-'
        printf "${BLUE}| %-${width_48}s |${RESET}\n" "$title"
        printf "${BLUE}+%${width_40}s+${RESET}\n" | tr ' ' '-'
	    echo -e "${CYAN}IP及解锁状态检测"${RESET}
        echo -e "${BLUE}1. ${RESET}IP 质量测试"
        echo -e "${BLUE}2. ${RESET}ChatGPT 解锁检测"
        echo -e "${BLUE}3. ${RESET}Region 解锁检测"
        echo -e "${BLUE}4. ${RESET}yeahwu 流媒体解锁检测"
        echo -e "${CYAN}网络线路测试"${RESET}
        echo -e "${BLUE}18. ${RESET}NetQuality 网络质量检测 ${YELLOW}★${RESET}"
        echo -e "${CYAN}综合测试"${RESET}
        echo -e "${BLUE}31. ${RESET}bench 性能测试"
        echo -e "${BLUE}32. ${RESET}spiritysdx 融合怪测评"
        echo -e "${BLUE}------------------------------------------${RESET}"
        echo "0. 返回主菜单"
        echo -e "${BLUE}------------------------------------------${RESET}"
        echo ""
        read -p "👉 请输入操作编号: " sys_choice

        case "$sys_choice" in
            1)
                clear
                echo "🚀 正在运行 IP 质量检测..."
                bash <(curl -Ls Check.Place) -I
                ;;
            # ChatGPT 解锁检测
            2)
                clear
                echo "🚀 正在运行 ChatGPT 解锁检测..."
                bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
                ;;
            # Region 解锁检测
            3)
                clear
                echo "🚀 正在运行 Region 解锁检测..."
                bash <(curl -L -s check.unlock.media)
                ;;
            # yeahwu 流媒体解锁检测
            4)
                clear
                install wget
                echo "🚀 正在运行 yeahwu 流媒体解锁检测..."
			    wget -qO- ${gh_proxy}github.com/yeahwu/check/raw/main/check.sh | bash
                ;;
            # NetQuality 网络质量体检脚本
            18)
                clear
                echo "🚀 正在运行 NetQuality 网络质量检测..."
                bash <(curl -sL Check.Place) -N
                ;;
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
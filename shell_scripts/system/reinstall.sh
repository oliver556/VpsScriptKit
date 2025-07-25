#!/bin/bash

### =================================================================================
# @名称:         reinstall.sh
# @功能描述:     一键重装系统
# @作者:         oliver556
# @版本:         0.1.0
# @创建日期:     2025-07-25
# @修改日期:     2025-07-25
#
# @许可证:       MIT
### =================================================================================

### === MollyLau 脚本 === ###
#
# @描述
#   本函数用于安装 MollyLau 脚本。
#
# @参数 $1: 脚本执行后缀补充 (e.g., "debian 12")
#
# @返回值
#   成功返回 0。
#
# @GitHub 地址：https://github.com/leitbogioro/Tools
#
# @示例
#   system_reinstall_MollyLau "debian 12"
###
system_reinstall_MollyLau() {
    log_action "[system.sh]" "一键重装系统"
    local system_param="$1"
    wget --no-check-certificate -qO InstallNET.sh "${GH_PROXY}raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh" && chmod a+x InstallNET.sh
    bash InstallNET.sh -"${system_param}"
}

### === bin456789 脚本 === ###
#
# @描述
#   本函数用于安装 MollyLau 脚本。
#
# @参数 $1: 脚本执行后缀补充 (e.g., "rocky")
#
# @返回值
#   成功返回 0。
#
# @GitHub 地址：https://github.com/bin456789/reinstall
#
# @示例
#   system_reinstall_MollyLau "debian 12"
###
system_reinstall_bin456789() {
    log_action "[system.sh]" "一键重装系统"
    local system_param="$1"
    curl -O "${GH_PROXY}"raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
    bash reinstall.sh "${system_param}"
}

### === 安装完成，提示重启 === ###
#
# @描述
#   本函数用于提示用户重启系统。
#
# @示例
#   hint_reboot
###
hint_reboot() {
    echo -e "${LIGHT_CYAN}安装完成！系统 3 秒后自动重启...${WHITE}"

    for i in {3..1}; do
        echo -e "${LIGHT_CYAN}${i}...${WHITE}"
        sleep 1
    done

    echo -e "${LIGHT_CYAN}重启中...${WHITE}"

    sleep 1

    reboot

    exit
}

### === MollyLau 脚本安装逻辑 ① === ###
#
# @描述
#   本函数用于安装 MollyLau 脚本。
#
# @参数 $1: 系统版本全名 (e.g., "Debian 12")
# @参数 $2: 脚本执行后缀补充 (e.g., "debian 12")
#
# @示例
#   run_mollylau_install "Debian 12" "debian 12"
###
run_mollylau_install() {
    local system_version_name="$1"
    local system_param="$2"

    echo -e "正在检查系统是否安装有必要环境..."
    sleep 2

    if ! command -v wget &> /dev/null; then
        echo "wget 未安装，正在安装..."
        apt-get update
        apt-get install -y wget
    fi

    echo "正在为您准备 [MollyLau] DD 脚本..."
    echo "目标系统: ${system_version_name}"
    print_echo_line_1
    sleep 2

    # 执行脚本
    system_reinstall_MollyLau "${system_param}"

    sleep 2

    hint_reboot
}

### === bin456789 脚本安装逻辑 ② === ###
#
# @描述
#   本函数用于安装 bin456789 脚本。
#
# @参数 $1: 系统版本全名 (e.g., "Debian 12")
# @参数 $2: 脚本执行后缀补充 (e.g., "debian 12")
#
# @示例
#   run_bin456789_install "Debian 12" "debian 12"
###
run_bin456789_install() {
    local system_version_name="$1"
    local system_param="$2"
    echo "system_version_name is: $system_version_name"
    echo "system_param is: $system_param"

    sleep 2

    print_echo_line_1
    echo "正在为您准备 [bin456789] DD 脚本..."
    echo "目标系统: ${system_version_name}"
    print_echo_line_1
    sleep 2

    # 执行脚本
    system_reinstall_bin456789 "${system_param}"

    sleep 2

    hint_reboot
}

### === 通用流程函数 === ###
#
# @描述
#   此函数负责与用户交互，并在确认后调用指定的安装函数。
#
# @参数 $1: 系统版本全名 (e.g., "Debian 12")
# @参数 $2: 初始用户名
# @参数 $3: 初始密码
# @参数 $4: 初始端口
# @参数 $5: 需要调用的安装函数名 (e.g., "run_mollylau_install")
# @参数 $6: 脚本执行后缀补充 (e.g., "debian 12")
#
# @示例
#   start_reinstall_process "Debian 12" "root" "123456" "22" "run_mollylau_install" "debian 12"
###
start_reinstall_process() {
    local system_version_name="$1"
    local user="$2"
    local pass="$3"
    local port="$4"
    local install_function_name="$5"
    local system_param="$6"

    # 显示最终确认信息
    echo -e "${LIGHT_CYAN}请最后确认您的安装选项:${WHITE}"
    print_echo_line_1
    echo -e "${LIGHT_CYAN}- 系统版本:${WHITE} ${BOLD_RED}${system_version_name}${WHITE}"
    echo -e "${LIGHT_CYAN}- 初始用户:${WHITE} ${YELLOW}${user}${WHITE}"
    echo -e "${LIGHT_CYAN}- 初始密码:${WHITE} ${YELLOW}${pass}${WHITE}"
    echo -e "${LIGHT_CYAN}- 初始端口:${WHITE} ${YELLOW}${port}${WHITE}"
    print_echo_line_1
    echo
    echo -e "${BOLD_RED}警告：这将清除目标服务器上的所有数据！请先复制好您的初始用户名、密码、端口，以免重装后无法连接。${WHITE}"

    if ! ask_to_continue; then
        return
    fi

    echo

    # 根据用户的选择执行操作
    echo "确认完毕，安装流程启动！"

    clear

    print_echo_line_1
    echo -e "${LIGHT_CYAN}马上开始重装系统${WHITE}"
    print_echo_line_1

    # 动态调用传入的安装函数名，并将系统名称作为参数传递给它
    ${install_function_name} "${system_version_name}" "${system_param}"
}

### === 选择系统 === ###
#
# @描述
#   本函数用于选择系统。
#
# @参数 $1: 系统全名 (e.g., "debian 12")
#
# @示例
system_reinstall_selection() {
    clear

    local system_selection="$1"

    local user_name_1="root"
    local pass_1="LeitboGi0ro"
    local port_1="22"
    local func_1="run_mollylau_install"

    local user_name_2="Administrator"
    local pass_2="Teddysun.com"
    local port_2="3389"
    local func_2="run_mollylau_install"

    local user_name_3="root"
    local pass_3="123@@@"
    local port_3="22"
    local func_3="run_bin456789_install"

    case "$system_selection" in
        "Debian 12")
            start_reinstall_process "Debian 12" "${user_name_1}" "${pass_1}" "${port_1}" "${func_1}" "debian 12"
            ;;

        "Debian 11")
            start_reinstall_process "Debian 11" "${user_name_1}" "${pass_1}" "${port_1}" "${func_1}" "debian 11"
            ;;

        "Debian 10")
            start_reinstall_process "Debian 10" "${user_name_1}" "${pass_1}" "${port_1}" "${func_1}" "debian 10"
            ;;

        "Debian 9")
            start_reinstall_process "Debian 9" "${user_name_1}" "${pass_1}" "${port_1}" "${func_1}" "debian 9"
            ;;

        "Ubuntu 24.04")
            start_reinstall_process "Ubuntu 24.04" "ubuntu" "${pass_1}" "${port_1}" "${func_1}" "ubuntu 24.04"
            ;;

        "Ubuntu 22.04")
            start_reinstall_process "Ubuntu ${port_1}.04" "ubuntu" "${pass_1}" "22" "${func_1}" "ubuntu 22.04"
            ;;

        "Ubuntu 20.04")
            start_reinstall_process "Ubuntu 20.04" "ubuntu" "${pass_1}" "${port_1}" "${func_1}" "ubuntu 20.04"
            ;;

        "Ubuntu 18.04")
            start_reinstall_process "Ubuntu 18.04" "ubuntu" "${pass_1}" "${port_1}" "${func_1}" "ubuntu 18.04"
            ;;

        "CentOS 10")
            start_reinstall_process "CentOS 10" "${user_name_3}" "${pass_3}" "${port_3}" "${func_3}" "centos 10"
            ;;

        "CentOS 9")
            start_reinstall_process "CentOS 9" "${user_name_3}" "${pass_3}" "${port_3}" "${func_3}" "centos 9"
            ;;

        "Alpine Linux")
            start_reinstall_process "Alpine Linux" "${user_name_1}" "${pass_1}" "${port_1}" "${func_1}" "alpine"
            ;;

        "Windows 11")
            start_reinstall_process "Windows 11" "${user_name_2}" "${pass_2}" "${port_2}" "${func_2}" 'windows 11 -lang "cn"'
            ;;

        "Windows 10")
            start_reinstall_process "Windows 10" "${user_name_2}" "${pass_2}" "${port_2}" "${func_2}" 'windows 10 -lang "cn"'
            ;;

        "Windows 7")
            ;;

        "Windows Server 2022")
            start_reinstall_process "Windows Server 2022" "${user_name_2}" "${pass_2}" "${port_2}" "${func_2}" 'windows 2022 -lang "cn"'
            ;;

        "Windows Server 2019")
            start_reinstall_process "Windows Server 2019" "${user_name_2}" "${pass_2}" "${port_2}" "${func_2}" 'windows 2019 -lang "cn"'
            ;;

        "Windows Server 2016")
            start_reinstall_process "Windows Server 2016" "${user_name_2}" "${pass_2}" "${port_2}" "${func_2}" 'windows 2016 -lang "cn"'
            ;;

        *)
            echo -e "${BOLD_RED}错误: 暂不支持您选择的系统: '${system_selection}'${WHITE}"
            break_end no_wait
            ;;
    esac
}

### === 一键重装系统 主函数 === ###
#
# @描述
#   本函数用于一键重装系统。
#
# @参数 $1: 系统全名 (e.g., "debian 12")
#
# @示例
#   system_reinstall_main "debian 12"
###
system_reinstall_main() {
    local system_selection_iput="$1"
    system_reinstall_selection "$system_selection_iput"
}

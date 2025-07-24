#!/bin/bash

### =================================================================================
# @名称:         public_lib.sh
# @功能描述:     公共函数库
# @作者:         Vskit (vskit@vskit.com)
# @版本:         0.0.1
# @创建日期:     2025-07-15
# @修改日期:     2025-07-20
#
# @许可证:       MIT
### =================================================================================

### === 函数 === ###
# 提示用户按任意键继续
#
# @描述
#   提示用户按任意键继续
#
# @示例
#   break_end
###
break_end() {
    echo ""
    echo -e "${GREEN}操作完成${WHITE}"
    if [[ "$1" != "no_wait" ]]; then
        echo "按任意键继续..."
        read -n 1 -s -rp ""
        echo ""
    fi
    clear
}

# 函数: 询问用户是否继续
# 返回值:
#   0 - 用户选择 Y/y (继续)
#   1 - 用户选择其他任意键 (取消)
ask_to_continue() {
    echo
    echo -e "按 ${BOLD_RED}(Y/y)${WHITE} 键确认操作，按其它任意键返回。"
    echo
    read -rp "$(echo -e "${LIGHT_CYAN}👉 请输入你的选择: ${WHITE}")" user_choice

    case "$user_choice" in
      y|Y)
        return 0  # 返回 0, 代表“成功/继续”
        ;;
      *)
        echo -e "\n${BOLD_YELLOW}操作已取消，正在返回...${WHITE}"
        sleep 1
        return 1  # 返回 1, 代表“失败/取消”
        ;;
    esac
}

# 快速启动脚本
vskit() {
    clear
	cd ~
	bash v
}

# 判断当前用户是否为 root 用户
# 修改成返回 true 或 false
is_user_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${BOLD_RED}提示: 该功能需要使用 root 用户才能运行此脚本${WHITE}"
        echo
        echo -e  "${BOLD_YELLOW}请切换到 'root' 用户来执行。${WHITE}"
		return 1
		# break_end
		# vskit
        # exit "$EXIT_ERROR"
	fi
}

# 功能：检测主流 Linux 发行版类型
# 返回：通过标准输出(echo)返回系统ID (ubuntu, centos等)
#      如果无法识别，则返回空字符串，并在标准错误输出提示信息。
check_system_type() {
    local OS=""
    if [ -f /etc/os-release ]; then
        # 在子 shell 中执行 source，避免污染当前环境
        OS=$(. /etc/os-release && echo "$ID")
    fi

    case "$OS" in
        ubuntu|debian|centos)
            # 将识别出的系统类型输出到标准输出
            echo "$OS"
            ;;
        *)
            # 将错误信息输出到标准错误，这样不会被命令替换捕获
            echo "无法识别的系统: $OS" >&2
            # 返回一个空字符串，表示未识别
            echo ""
            ;;
    esac
}

#
# 函数: get_os_type
# 功能: 检测当前 Linux 发行版类型。
# 输出:
#   - "debian_like" (适用于 Ubuntu, Debian)
#   - "rhel_like"   (适用于 CentOS, RHEL, Fedora)
#   - "unsupported" (适用于其他不支持的系统)
#
get_os_type() {
    # 检查 /etc/os-release 文件是否存在
    if [ -f /etc/os-release ]; then
        # 加载文件中的变量 (如 ID, ID_LIKE)
        . /etc/os-release

        case "$ID" in
            ubuntu|debian)
                echo "debian_like"
                ;;
            centos|rhel|fedora)
                echo "rhel_like"
                ;;
            *)
                # 如果主 ID 不匹配，可以检查 ID_LIKE 字段
                case "$ID_LIKE" in
                    debian)
                        echo "debian_like"
                        ;;
                    rhel|fedora)
                        echo "rhel_like"
                        ;;
                    *)
                        echo "unsupported"
                        ;;
                esac
                ;;
        esac
    else
        # 如果 /etc/os-release 文件不存在，则无法确定系统
        echo "unknown"
    fi
}


# 主菜单标题函数
main_menu_title() {
    local title="$1"
    _title="$title"
    # # 🔷 ASCII 标题框
    printf "${LIGHT_CYAN}"
    printf "+%${width_60}s+\n" "" | tr ' ' '='
    printf "# %-${width_71}s #\n" "${_title}"
    printf "+%${width_60}s+\n" "" | tr ' ' '='
}

# 子菜单标题函数
sub_menu_title() {
    local title="$1"
    _title="$title"
    printf "${LIGHT_CYAN}"
    printf "+%${width_60}s+\n" "" | tr ' ' '-'
    printf "# %-${width_68}s \n" "${_title}"
    printf "+%${width_60}s+\n" "" | tr ' ' '-'
}

gran_menu_title() {
    local title="$1"
    _title="$title"
    # printf "${LIGHT_MAGENTA}"
    # printf "%${width_20}s\n" "" | tr ' ' '-'
    # printf "| %-${width_20}s \n" "$_title"
    # printf "%${width_20}s\n" "" | tr ' ' '-'
    if [[ "$2" == "front_line" ]]; then
        echo -e "\n${BOLD_YELLOW}──────────────────────────────────────────────────────────────${WHITE}"
    elif [[ "$2" == "back_line" ]]; then
        echo -e "${BOLD_YELLOW}──────────────────────────────────────────────────────────────${WHITE} \n"
    else
        echo -e "${BOLD_YELLOW}──────────────────────────────────────────────────────────────${WHITE}"
    fi
    echo -e "${BOLD_YELLOW}${_title}${NC}"
}

# 打印 echo 分割线
# @param $1 前边换行符
print_echo_line_1() {
    if [[ "$1" == "front_line" ]]; then
        echo -e "\n${LIGHT_CYAN}──────────────────────────────────────────────────────────────${WHITE}"
    elif [[ "$1" == "back_line" ]]; then
        echo -e "${LIGHT_CYAN}──────────────────────────────────────────────────────────────${WHITE} \n"
    else
        echo -e "${LIGHT_CYAN}──────────────────────────────────────────────────────────────${WHITE}"
    fi
}

# 打印 echo 分割线
print_echo_line_2() {
    echo -e "${LIGHT_CYAN}--------------------------------------------------------------${WHITE}"
}


# 打印信息函数
# 用法: log_info "这是一条信息"
log_info() {
    echo -e "${BOLD_BLUE}INFO: $1${WHITE}"
}

# 打印错误函数
# 用法: log_error "这是一个错误"
log_error() {
    echo -e "${BOLD_RED}ERROR: $1${WHITE}" >&2
}

# 打印警告函数
# 用法: log_warning "这是一个警告"
log_warning() {
    echo -e "${BOLD_YELLOW}WARNING: $1${WHITE}" >&2
}

# 打印信息函数
echo_info() {
    echo -e "${BOLD_BLUE}$1${WHITE}"
}

# 打印错误函数
echo_error() {
    echo -e "${BOLD_RED}$1${WHITE}" >&2
}

# 打印警告函数
echo_warning() {
    echo -e "${BOLD_YELLOW}$1${WHITE}" >&2
}

# 打印成功函数
echo_success() {
    echo -e "${BOLD_GREEN}$1${WHITE}"
}

# 通用日志函数
# 用法1: log "普通消息"
# 用法2: log "[模块名]" "来自该模块的消息"
log_action() {
  local tag=""
  local message

  # 如果第一个参数是 [tag] 格式，就把它作为标签
  if [[ "$1" =~ ^\[.*\]$ ]]; then
    tag=" $1" # 加个前导空格
    shift    # 移除第一个参数（标签），剩下的就是消息
  fi

  message="$*" # 将剩下的所有参数作为消息
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  # 写入日志
  echo "[$timestamp]${tag} $message" >> "$LOG_FILE"
}

export -f log_action

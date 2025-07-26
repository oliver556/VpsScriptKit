#!/bin/bash

### =================================================================================
# @名称:         public_lib.sh
# @功能描述:     公共函数库
# @作者:         oliver556
# @版本:         0.0.1
# @创建日期:     2025-07-15
# @修改日期:     2025-07-20
#
# @许可证:       MIT
### =================================================================================

### === 提示用户按任意键继续 === ###
#
# @描述
#   提示用户按任意键继续
#
# @示例
#   break_end
###
break_end() {
    echo ""
    echo -e "${GREEN}操作完成${LIGHT_WHITE}"
    if [[ "$1" != "no_wait" ]]; then
        echo "按任意键继续..."
        read -n 1 -s -rp ""
        echo ""
    fi
    clear
}

### === 询问用户是否继续 === ###
#
# @描述
#   本函数用于询问用户是否继续。
#
# @返回值
#   成功返回 0。
#   0 - 用户选择 Y/y (继续)
#   1 - 用户选择其他任意键 (取消)
#
# @示例
#   _compress_file "/tmp/db_backup.sql"
###
ask_to_continue() {
    local title="$1"
    echo
    # 如果 title 不为空，则显示 title
    if [ -n "$title" ]; then
        echo -e "按 ${BOLD_RED}(Y/y)${LIGHT_WHITE} 键确认执行 ${LIGHT_CYAN}${title}${LIGHT_WHITE}，按其它任意键返回。"
    else
        echo -e "按 ${BOLD_RED}(Y/y)${LIGHT_WHITE} 键确认，按其它任意键返回。"
    fi
    echo
    read -rp "$(echo -e "${LIGHT_CYAN}👉 请输入你的选择: ${LIGHT_WHITE}")" user_choice

    case "$user_choice" in
      y|Y)
        return 0  # 返回 0, 代表“成功/继续”
        ;;
      *)
        echo -e "\n${BOLD_YELLOW}操作已取消，正在返回...${LIGHT_WHITE}"
        sleep 1
        return 1  # 返回 1, 代表“失败/取消”
        ;;
    esac
}

### === 快速启动脚本 === ###
#
# @描述
#   本函数用于快速启动脚本。
#
# @示例
#   vskit
vskit() {
    clear
	cd ~
	bash v
}

### === 判断当前用户是否为 root 用户 === ###
#
# @描述
#   本函数用于判断当前用户是否为 root 用户。
#
# @示例
#   
is_user_root() {
    if [ "$EUID" -ne 0 ]; then
        clear
        echo -e "${BOLD_RED}提示: 该功能需要使用 root 用户才能运行此脚本${LIGHT_WHITE}"
        echo
        echo -e  "${BOLD_YELLOW}请切换到 'root' 用户来执行。${LIGHT_WHITE}"
		return 1
	fi
}

### === 检测当前 Linux 发行版类型 === ###
#
# @描述
#   本函数用于检测当前 Linux 发行版类型。
#
# @返回值
#   - "debian_like" (适用于 Ubuntu, Debian)
#   - "rhel_like"   (适用于 CentOS, RHEL, Fedora)
#   - "unsupported" (适用于其他不支持的系统)
#
# @示例
#   get_os_type
###
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


### === 主菜单标题函数 === ###
#
# @描述
#   本函数用于打印主菜单标题。
#
# @示例
#   main_menu_title
main_menu_title() {
    local title="$1"
    _title="$title"
    # # 🔷 ASCII 标题框
    printf "${LIGHT_CYAN}"
    printf "+%${width_60}s+\n" "" | tr ' ' '='
    printf "# %-${width_71}s #\n" "${_title}"
    printf "+%${width_60}s+\n" "" | tr ' ' '='
}

### === 子菜单标题函数 === ###
#
# @描述
#   本函数用于打印子菜单标题。
#
# @示例
#   sub_menu_title
sub_menu_title() {
    local title="$1"
    _title="$title"
    printf "${LIGHT_CYAN}"
    printf "+%${width_60}s+\n" "" | tr ' ' '='
    printf "# %-${width_68}s \n" "${_title}"
    printf "+%${width_60}s+\n" "" | tr ' ' '='
}

### === 分割线标题函数 === ###
#
# @描述
#   本函数用于打印分割线标题。
#
# @示例
#   gran_menu_title
gran_menu_title() {
    local title="$1"
    _title="$title"
    # printf "${LIGHT_MAGENTA}"
    # printf "%${width_20}s\n" "" | tr ' ' '-'
    # printf "| %-${width_20}s \n" "$_title"
    # printf "%${width_20}s\n" "" | tr ' ' '-'
    if [[ "$2" == "front_line" ]]; then
        echo -e "\n${BOLD_YELLOW}──────────────────────────────────────────────────────────────${LIGHT_WHITE}"
    elif [[ "$2" == "back_line" ]]; then
        echo -e "${BOLD_YELLOW}──────────────────────────────────────────────────────────────${LIGHT_WHITE} \n"
    else
        echo -e "${BOLD_YELLOW}──────────────────────────────────────────────────────────────${LIGHT_WHITE}"
    fi
    echo -e "${BOLD_YELLOW}${_title}${NC}"
}

### === echo 分割线 1=== ###
#
# @描述
#   本函数用于打印 echo 分割线。
#
# @参数 $1: 前边换行符
#
# @示例
#   print_echo_line_1
###
print_echo_line_1() {
    if [[ "$1" == "front_line" ]]; then
        echo -e "\n${LIGHT_CYAN}──────────────────────────────────────────────────────────────${LIGHT_WHITE}"
    elif [[ "$1" == "back_line" ]]; then
        echo -e "${LIGHT_CYAN}──────────────────────────────────────────────────────────────${LIGHT_WHITE} \n"
    else
        echo -e "${LIGHT_CYAN}──────────────────────────────────────────────────────────────${LIGHT_WHITE}"
    fi
}

### === echo 分割线 2=== ###
#
# @描述
#   本函数用于打印 echo 分割线。
#
# @示例
#   print_echo_line_2
###
print_echo_line_2() {
    echo -e "${LIGHT_CYAN}--------------------------------------------------------------${LIGHT_WHITE}"
}

### === echo 分割线 3=== ###
#
# @描述
#   本函数用于打印 echo 分割线。
#
# @示例
#   print_echo_line_3
###
print_echo_line_3() {
    echo -e "${LIGHT_CYAN}==============================================================${LIGHT_WHITE}"
}

### === 打印信息函数 === ###
#
# @描述
#   本函数用于打印信息。
#
# @示例
#   log_info
###
log_info() {
    echo -e "${BOLD_BLUE}INFO: $1${LIGHT_WHITE}"
}

### === 打印错误函数 === ###
#
# @描述
#   本函数用于打印错误。
#
# @示例
#   log_error
###
log_error() {
    echo -e "${BOLD_RED}ERROR: $1${LIGHT_WHITE}" >&2
}

### === 打印警告函数 === ###
#
# @描述
#   本函数用于打印警告。
#
# @示例
#   log_warning
###
log_warning() {
    echo -e "${BOLD_YELLOW}WARNING: $1${LIGHT_WHITE}" >&2
}

### === 打印信息函数 === ###
#
# @描述
#   本函数用于打印信息。
#
# @示例
#   echo_info
###
echo_info() {
    echo -e "${BOLD_BLUE}$1${LIGHT_WHITE}"
}

### === 打印信息函数 === ###
#
# @描述
#   本函数用于打印信息，使用浅蓝色。
#
# @示例
#   echo_info
###
echo_info_light() {
    echo -e "${LIGHT_CYAN}$1${LIGHT_WHITE}"
}

### === 打印错误函数 === ###
#
# @描述
#   本函数用于打印错误。
#
# @示例
#   echo_error
###
echo_error() {
    echo -e "${BOLD_RED}$1${LIGHT_WHITE}" >&2
}

### === 打印警告函数 === ###
#
# @描述
#   本函数用于打印警告。
#
# @示例
#   echo_warning
###
echo_warning() {
    echo -e "${BOLD_YELLOW}$1${LIGHT_WHITE}" >&2
}

### === 打印成功函数 === ###
#
# @描述
#   本函数用于打印成功。
#
# @示例
#   echo_success
###
echo_success() {
    echo -e "${BOLD_GREEN}$1${LIGHT_WHITE}"
}

### === 通用日志函数 === ###
#
# @描述
#   本函数接收一个文件路径作为输入，检查文件是否存在，然后使用 gzip
#   进行压缩。成功压缩后，源文件将被删除。
#
# @参数 $1: 标签
# @参数 $2: 消息
#
# @用法
#   - 用法1: log "普通消息"
#   - 用法2: log "[模块名]" "来自该模块的消息"
#
# @示例
#   log_action "模块名" "来自该模块的消息"
###
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

### === 执行一个函数，并检查是否需要传递重启信号（支持任意参数） === ###
#
# @描述
#   本函数安全地执行一个指定的函数名，并将所有后续参数原封不动地
#   传递给它。在其返回码为 10 时，自己也返回 10，从而将重启信号
#   向上传递。
#
# @参数 $1: 字符串 - 需要被执行的函数名。
# @参数 $2...: (可选) - 要传递给目标函数的所有参数。
#
# @示例
#   execute_and_propagate_restart "函数名" "参数1" "参数2" ...
###
execute_and_propagate_restart() {
    # 1. 要调用的函数名
    local function_to_call="$1"

    # 2. 检查函数是否存在
    if ! declare -F "$function_to_call" >/dev/null; then
        echo_error "内部错误: 尝试调用一个不存在的函数 '$function_to_call'"
        return 1
    fi

    # 3. 使用 shift 命令，将第一个参数（函数名）从参数列表中“移走”
    shift

    # 4. $@ 变量里包含的就是所有“剩下”的原始参数
    "$function_to_call" "$@"

    # 5. 检查目标函数的退出码，看是否需要传递重启信号
    if [[ $? -eq 10 ]]; then
        return 10
    fi
}

### === 提示该功能还在开发阶段 === ###
#
# @描述
#   本函数用于提示该功能还在开发阶段。
#
# @示例
#   echo_warning "该功能还在开发阶段"
###
print_dev() {
    clear
    echo -e "${BOLD_YELLOW}该功能还在开发阶段，敬请期待...${LIGHT_WHITE}"
}

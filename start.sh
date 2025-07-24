#!/bin/bash

source "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/lib/public/init_lib.sh"
MAIN_SCRIPT="$ROOT_DIR/vps_script_kit.sh"

# 检查主脚本是否存在
if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "错误：主脚本 vps_script_kit.sh 未找到！"
    exit 1
fi

while true; do
    # 启动主脚本，并将所有命令行参数传递给它
    "$MAIN_SCRIPT" "$@"

    # 检查主脚本的退出码
    exit_code=$?

    # 约定：只有当退出码是 10 时，我们才重启脚本
    if [[ $exit_code -eq 10 ]]; then
        echo "收到重启信号，准备重新启动..."
        sleep 1
    else
        # 对于任何其他退出码 (例如正常退出的 0)，监督者也退出
        break
    fi
done

# VpsScriptKit

VpsScriptKit（简称 vsk）是一个社区驱动、可自由扩展的服务器命令脚本管理工具。它集成了常用的系统管理、测试、信息查询等脚本，支持交互式菜单，极大节省你查找和编写脚本的时间。

---

## ✨ 主要特性

- **交互式菜单**：一键唤出，操作直观
- **模块化设计**：支持自定义扩展和订阅
- **多系统兼容**：支持 Debian / Ubuntu / CentOS / Alpine / Arch / openSUSE / OpenWrt 等主流发行版
- **常用脚本合集**：系统信息、网络测试、流媒体检测、性能测试等一应俱全
- **社区驱动**：欢迎 PR 和自定义模块

---

## 📁 目录结构

```
VpsScriptKit/
├── vps_script_kit.sh           # 主入口脚本
├── install.sh                  # 一键安装脚本
├── update.sh                   # 脚本自更新
├── README.md                   # 项目说明
├── config/                     # 配置文件（如颜色、常量等）
├── lib/                        # 公共函数库
│   ├── public/
│   ├── system/
│   └── test/
├── modules.d/                  # 功能模块（菜单项）
│   ├── system.sh
│   └── test.sh
├── shell_scripts/              # 具体功能脚本
│   ├── system/
│   └── test/
└── logs/
    └── vps_script_kit.log      # 日志文件
```

---

## 🚀 安装与启动

1. **一键安装**
   ```bash
   bash <(curl -sSL install.viplee.cc)
   ```

2. **启动脚本**
   ```bash
   v
   # 或者
   vsk
   ```

---

## 🛠️ 快速使用

- 启动后，按数字选择对应功能模块
- 支持系统工具、测试脚本、流媒体检测、性能测试等
- 支持自定义扩展模块，详见下方扩展说明

---

## 🧩 扩展与自定义

- 所有菜单模块放在 `modules.d/` 目录下，每个 `.sh` 文件对应一个菜单项
- 新增模块只需添加脚本并在主菜单数组中注册即可
- 公共函数可放在 `lib/public/`，便于复用

---

## 🤝 贡献

欢迎提交 PR、Issue 或自定义你的专属脚本模块！

---

## 📄 License

MIT


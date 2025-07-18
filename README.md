

# 介绍

VpsScriptKit（简称 vsk）是一个社区驱动、可自由扩展的服务器命令脚本管理工具。它集成了常用的系统管理、测试、信息查询等脚本，支持交互式菜单，极大节省你查找和编写脚本的时间。

---

## 🌐 支持系统 (Supported Systems)

<p align="left">
  <a href="#">
    <img src="https://img.shields.io/badge/Ubuntu-FFB6C1?style=for-the-badge&logo=ubuntu&logoColor=black" alt="Ubuntu" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Debian-AFEEEE?style=for-the-badge&logo=debian&logoColor=black" alt="Debian" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/CentOS-98FB98?style=for-the-badge&logo=centos&logoColor=black" alt="CentOS" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/alpinelinux-ADD8E6?style=for-the-badge&logo=alpinelinux&logoColor=black" alt="alpinelinux" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Kali-D3D3D3?style=for-the-badge&logo=kali-linux&logoColor=black" alt="Kali" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Arch-FFFFE0?style=for-the-badge&logo=archlinux&logoColor=black" alt="Arch" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/RedHat-FFE4E1?style=for-the-badge&logo=redhat&logoColor=black" alt="RedHat" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Fedora-FFD700?style=for-the-badge&logo=fedora&logoColor=black" alt="Fedora" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/almalinux-FFEFD5?style=for-the-badge&logo=almalinux&logoColor=black" alt="almalinux" style="margin: 5px;">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Rocky-FFFACD?style=for-the-badge&logo=rocky-linux&logoColor=black" alt="Rocky" style="margin: 5px;">
  </a>
</p>

---

## 更新系统

```bash
apt update -y  && apt install -y curl
```

---

## 🚀 一键安装 (One-Click Installation)

```bash
bash <(curl -sL install.viplee.cc)
```

## 📦 核心功能 (Core Features)

- **系统信息概览**：快速展示 CPU、内存、磁盘、带宽等运行状态  

- **网络测试工具**：集成测速、回程、延迟、丢包检测等  

- **Docker 容器管理**：独家容器可视化 + 容器控制增强命令  

- **网站防御与优化**：防CC、防爬虫，自动配置防火墙与性能优化  

- **备份与迁移**：站点与数据库一键备份/恢复/远程迁移  

- **BBR 加速优化**：内核加速、网络拥塞控制智能切换  

- **应用市场集成**：内置主流工具与面板，支持一键安装常用服务  

- **自动更新机制**：定时检测脚本版本，保持最新最稳定  

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


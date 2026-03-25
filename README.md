# dotfiles

My personal GitHub dotfiles repository. See [About-the-special-github-dotfiles-repo.md](docs/source/About-the-special-github-dotfiles-repo.md).

## Bootstrap 新电脑

给新电脑配置开发环境的步骤：

### **安装 Starship** - 跨 shell 的提示符工具

```bash
curl -sS https://starship.rs/install.sh | sh
```

官网：https://starship.rs/

### **安装 mise-en-place** - 多语言版本管理和任务运行器

```bash
curl https://mise.run | sh
```

官网：https://mise.jdx.dev/

## 配置文件说明

```
dotfiles/
├── .bash_profile        # Bash 登录 shell 配置（自动加载 .bashrc）
├── .bashrc              # Bash shell 配置
├── .zshrc               # Zsh shell 配置
├── .config/
│   └── starship.toml    # Starship 提示符配置
├── install.sh           # 安装脚本
└── README.md
```

## GitHub Codespaces 使用

在 Codespaces 中，dotfiles 会自动被克隆和执行。

### 为什么需要 .bash_profile？

- **登录 shell**（Codespaces 默认）→ 读取 `.bash_profile`
- **交互式 shell**（运行 `bash` 命令）→ 读取 `.bashrc`

`.bash_profile` 会自动加载 `.bashrc`，确保所有配置在两种情况下都生效。

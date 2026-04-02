# dotfiles

My personal GitHub dotfiles repository.

## 文档

- 📖 [GitHub Codespaces Dotfiles 配置指南](docs/source/GitHub-Codespaces-Dotfiles-Configuration-Guide.md) - 详细的 4 种使用场景说明
- 📚 [关于 GitHub dotfiles 特殊仓库](docs/source/About-the-special-github-dotfiles-repo.md)

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

### 快速参考

| 场景 | GitHub 全局设置 | 项目配置 | 解决方案 |
|------|----------------|---------|---------|
| **场景 1** | ❌ 不勾选 | ✅ 想用 | 使用 Dev Container Feature |
| **场景 2** | ❌ 不勾选 | ❌ 不用 | 默认行为 ✅ |
| **场景 3** | ✅ 勾选 | ✅ 想用 | 默认行为 ✅ |
| **场景 4** | ✅ 勾选 | ❌ 不用 | 创建 `.skip-dotfiles` 文件 |

📖 **详细配置说明**：请查看 [GitHub Codespaces Dotfiles 配置指南](docs/source/GitHub-Codespaces-Dotfiles-Configuration-Guide.md)

### 快速示例

#### 在特定项目启用 dotfiles（场景 1）

```json
// .devcontainer/devcontainer.json
{
    "features": {
        "ghcr.io/jpawlowski/devcontainer-features/codespaces-dotfiles:1": {
            "repository": "YOUR_USERNAME/dotfiles"
        }
    }
}
```

#### 在特定项目禁用 dotfiles（场景 4）

```bash
# 在项目根目录
touch .skip-dotfiles
git add .skip-dotfiles
git commit -m "Skip dotfiles"
```

### 为什么需要 .bash_profile？

- **登录 shell**（Codespaces 默认）→ 读取 `.bash_profile`
- **交互式 shell**（运行 `bash` 命令）→ 读取 `.bashrc`

`.bash_profile` 会自动加载 `.bashrc`，确保所有配置在两种情况下都生效。

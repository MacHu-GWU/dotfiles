# Using Dotfiles to Personalize GitHub Codespaces

## What is a dotfiles repository?

在 GitHub Codespaces 中，`dotfiles` 是一个**特殊用途的仓库**。每次创建新的 codespace，GitHub 会自动 clone 这个仓库并执行初始化 —— 让你的 shell 别名、工具链、编辑器配置在每一个云端 Linux 环境里保持一致。

官方定义：

> *"Dotfiles are files and folders on Unix-like systems starting with `.` that control
> the configuration of applications and shells on your system. You can store and manage
> your dotfiles in a repository on GitHub."*

你的 dotfiles 仓库通常包含：

- Shell 别名和偏好设置（`.bashrc`、`.zshrc`、`.bash_profile`）
- 开发工具配置（`.gitconfig`、`.vimrc`、`.editorconfig`）
- 每个环境都需要预装的工具
- 任何你希望自动应用的个人化配置

---

## How Codespaces initializes your environment

创建 codespace 时，GitHub 按顺序执行三步：

1. **Clone** —— 把你选定的 dotfiles 仓库 clone 到 codespace 内部
2. **Look for a setup script** —— 在仓库根目录查找下方列出的 8 个特殊文件
3. **Fallback: symlink** —— 如果没有找到任何特殊文件，自动把所有 `.` 开头的文件和目录 symlink 到 `$HOME`

官方原文：

> *"When you create a new codespace, GitHub clones your selected dotfiles repository
> to the codespace environment, and looks for one of the following files to set up
> the environment."*

---

## Special files recognized by Codespaces

以下 8 个路径被视为"特殊文件"，**第一个被找到的会被执行，其余忽略**。除此之外的所有文件，你可以自由命名、自由组织。

| 文件路径 | 说明 |
|---|---|
| `install.sh` | 最常用，推荐命名 |
| `install` | 同上，无扩展名 |
| `bootstrap.sh` | 备选命名 |
| `bootstrap` | 同上，无扩展名 |
| `script/bootstrap` | 放在 `script/` 子目录里 |
| `setup.sh` | 备选命名 |
| `setup` | 同上，无扩展名 |
| `script/setup` | 放在 `script/` 子目录里 |

---

## Fallback behavior: auto-symlink

**当仓库里不存在上面 8 个特殊文件中的任何一个时**，Codespaces 自动将仓库中所有以 `.` 开头的文件和目录 symlink 到 `$HOME`。

官方原文：

> *"If none of these files are found, then any files or folders in your selected
> dotfiles repository starting with `.` are symlinked to the codespace's `~`
> or `$HOME` directory."*

注意两个关键词：**files or folders** —— 文件和目录都包括在内。

假设你的仓库结构如下：

```
dotfiles/
├── README.md           ← 不是 . 开头，忽略
├── .bashrc             ← . 开头的文件 ✓
├── .zshrc              ← . 开头的文件 ✓
├── .gitconfig          ← . 开头的文件 ✓
└── .config/            ← . 开头的目录 ✓
    ├── starship.toml
    └── nvim/
        └── init.lua
```

Codespaces 自动创建的 symlink：

```
~/.bashrc      → .../dotfiles/.bashrc
~/.zshrc       → .../dotfiles/.zshrc
~/.gitconfig   → .../dotfiles/.gitconfig
~/.config/     → .../dotfiles/.config/        ← 整个目录作为一个 symlink
```

`.config/` 是目录，整个目录会作为一个 symlink 挂过去，所以 `~/.config/starship.toml` 和 `~/.config/nvim/init.lua` 都可以访问到。

### 关于 `.config/` 的潜在问题

`.config/` 整目录被 symlink 意味着：

- ⚠️ codespace 里其他程序想往 `~/.config/` 写东西，**实际上写进了你的 dotfiles 仓库目录**
- ⚠️ 如果 codespace 内已存在 `~/.config/`，symlink 会**失败**（目标已存在）

对于 `.config/` 这类共享目录，推荐改用 `install.sh` 做细粒度控制（见下一节）。

---

## Q&A: Will `.bashrc` and `.zshrc` be automatically copied?

**不是 copy，是 symlink（符号链接）**，两者的区别：

- **Symlink**：`~/.bashrc` 指向 dotfiles 仓库里的文件，磁盘上只有一份
- **Copy**：两个独立文件，修改一个不影响另一个

具体取决于你的仓库结构：

**Scenario A：仓库里没有任何 setup 脚本**

自动 symlink，`.bashrc` 和 `.zshrc` 直接出现在 `~/`，无需任何额外操作。

**Scenario B：仓库里有 `install.sh`**

自动 symlink 完全不发生，需要在脚本里手动处理：

```bash
#!/bin/bash
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shell 配置
ln -sf "$DOTFILES/.bashrc"    "$HOME/.bashrc"
ln -sf "$DOTFILES/.zshrc"     "$HOME/.zshrc"
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

# .config/ 下的文件建议逐个 symlink，避免整目录冲突
mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES/.config/nvim/init.lua"  "$HOME/.config/nvim/init.lua"
ln -sf "$DOTFILES/.config/starship.toml"  "$HOME/.config/starship.toml"

echo "Dotfiles linked!"
```

---

## Recommended directory structure

```
dotfiles/
├── install.sh              ← 特殊文件，Codespaces 自动执行
├── README.md               ← 说明文档（可选）
├── .bashrc
├── .zshrc
├── .gitconfig
├── .vimrc
└── .config/
    ├── starship.toml
    └── nvim/
        └── init.lua
```

最小可用结构（无脚本，走 auto-symlink）：

```
dotfiles/
├── .bashrc
├── .zshrc
└── .gitconfig
```

---

## Scenario comparison

| | Scenario A（无脚本） | Scenario B（有 install.sh） |
|---|---|---|
| 触发条件 | 仓库里没有 8 个特殊文件中的任何一个 | 找到任意一个特殊文件 |
| `.bashrc` / `.zshrc` | 自动 symlink 到 `~/` | 脚本手动 `ln -sf` |
| `.config/` 目录 | 整个目录 symlink（有冲突风险）| 脚本手动控制，更安全 |
| 非 `.` 开头的文件 | 忽略（`README.md`、`install.sh` 等不处理）| 忽略 |
| 额外工具安装 | 不支持 | 可在脚本里 `apt-get install` 等 |
| 推荐场景 | 配置简单、文件少 | 有工具安装需求，或有 `.config/` 等共享目录 |

---

## How to enable

1. 打开 [github.com/settings/codespaces](https://github.com/settings/codespaces)
2. 在 **"Dotfiles"** 区域，勾选 **"Automatically install dotfiles"**
3. 从下拉菜单选择你的 dotfiles 仓库

> ⚠️ **安全提示（原文）：**
> *"Dotfiles have the ability to run arbitrary scripts, which may contain unexpected
> or malicious code. Before installing a dotfiles repo, we recommend checking scripts
> to ensure they don't perform any unexpected actions."*

---

## Key caveats

- **只对新 codespace 生效** —— 已有的 codespace 不受影响，原文：*"Any changes to your selected dotfiles repository will apply only to each new codespace, and do not affect any existing codespace."*
- `.bashrc` / `.zshrc` 是 **symlink，不是 copy**
- Codespaces 目前**不支持**通过 dotfiles 仓库个性化 VS Code 的 User-scoped 设置，需要用 Settings Sync

---

## References

1. GitHub Docs — *Personalizing GitHub Codespaces for your account*
   <https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account>

2. *GitHub does dotfiles* (unofficial community guide)
   <https://dotfiles.github.io/>
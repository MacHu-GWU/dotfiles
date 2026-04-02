# GitHub Codespaces Dotfiles 配置指南

本文档详细说明如何在不同场景下配置和使用 dotfiles 与 GitHub Codespaces。

## 背景知识

### Dotfiles 在 Codespaces 中的工作原理

根据 [GitHub 官方文档](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles)，当创建新的 Codespace 时：

1. **克隆仓库**：GitHub 会将你指定的 dotfiles 仓库克隆到 Codespace 环境中
2. **查找安装脚本**（按优先级顺序）：
   - `install.sh`
   - `install`
   - `bootstrap.sh`
   - `bootstrap`
   - `script/bootstrap`
   - `setup.sh`
   - `setup`
   - `script/setup`
3. **执行脚本**：找到第一个存在的脚本并执行
4. **自动链接**：如果没有找到安装脚本，任何以 `.` 开头的文件会被符号链接到 `$HOME` 目录

> **官方文档引用**：
> "When you create a new codespace, GitHub clones your selected dotfiles repository to the codespace environment, and looks for one of the following files to set up the environment."
>
> 来源：[Personalizing GitHub Codespaces - Dotfiles](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles)

### 重要限制

⚠️ **项目级别的 dotfiles 配置不是官方支持的功能**

根据 [GitHub Community Discussion #134612](https://github.com/orgs/community/discussions/134612)：

- ❌ `customizations.codespaces.dotfiles` 不被 GitHub Codespaces 支持
- ❌ 在 `devcontainer.json` 中无法原生配置 dotfiles repository
- ✅ **唯一官方方式**：用户在 GitHub 账户设置中配置

> **社区讨论引用**：
> "Codespaces does not respect settings for regular Dev Containers in `customizations.vscode.settings.dotfiles.repository`, nor can one use a similar setting in the Codespaces namespace like `customizations.codespaces.dotfiles.repository`."
>
> 来源：[GitHub Community Discussion #134612](https://github.com/orgs/community/discussions/134612)

---

## 四种使用场景详解

### 场景 1：未勾选全局设置，但想在特定项目使用 dotfiles

#### 场景描述
- GitHub Settings 中**未勾选** "Automatically install dotfiles"
- 某个特定项目**需要**使用 dotfiles

#### 解决方案

##### 方案 A：使用 Dev Container Feature（推荐）

在项目的 `.devcontainer/devcontainer.json` 中添加：

```json
{
    "name": "my-project",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jpawlowski/devcontainer-features/codespaces-dotfiles:1": {
            "repository": "YOUR_USERNAME/dotfiles",
            "targetPath": "~/dotfiles",
            "installCommand": "~/dotfiles/install.sh"
        }
    }
}
```

**配置选项说明**：

| 选项 | 说明 | 类型 | 默认值 |
|------|------|------|--------|
| `repository` | dotfiles 仓库（格式：`owner/repo` 或完整 URL） | string | 必填 |
| `targetPath` | 克隆到的目标路径 | string | `~/dotfiles` |
| `installCommand` | 安装脚本命令 | string | 自动检测 |
| `installFallbackMethod` | 降级方案 | string | `symlink` |

> **Feature 文档引用**：
> "This feature allows you to install your dotfiles repository in GitHub Codespaces via devcontainer.json. The feature only works in GitHub Codespaces and will not interfere with your Dev Container setup."
>
> 来源：[jpawlowski/devcontainer-features - codespaces-dotfiles](https://github.com/jpawlowski/devcontainer-features/tree/main/src/codespaces-dotfiles)

##### 方案 B：使用 postCreateCommand

```json
{
    "name": "my-project",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "postCreateCommand": "git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh"
}
```

> **官方文档引用**：
> "`postCreateCommand` - A command string or list of command arguments to run after the container is created."
>
> 来源：[Dev Container metadata reference](https://containers.dev/implementors/json_reference/)

**对比**：

| 方案 | 优点 | 缺点 |
|------|------|------|
| Dev Container Feature | ✅ 专门设计用于 dotfiles<br>✅ 不影响本地 Dev Container<br>✅ 支持 prebuilds | ❌ 依赖第三方 feature |
| postCreateCommand | ✅ 原生支持<br>✅ 更灵活 | ❌ 在本地 Dev Container 也会执行<br>❌ 需要手动写命令 |

---

### 场景 2：未勾选全局设置，不使用 dotfiles

#### 场景描述
- GitHub Settings 中**未勾选** "Automatically install dotfiles"
- 项目**不需要**使用 dotfiles

#### 解决方案

**什么都不做**

这是 GitHub Codespaces 的默认行为。

> **官方文档引用**：
> "You can personalize GitHub Codespaces by using a dotfiles repository... To use a dotfiles repository, you can enable it in your personal Codespaces settings."
>
> 来源：[Personalizing GitHub Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles)

未启用时，不会自动安装任何 dotfiles。

---

### 场景 3：勾选了全局设置，想使用 dotfiles

#### 场景描述
- GitHub Settings 中**已勾选** "Automatically install dotfiles"
- 项目**需要**使用 dotfiles

#### 解决方案

**什么都不做**

这是启用全局 dotfiles 的默认行为。所有新建的 Codespace 都会自动：
1. 克隆你指定的 dotfiles 仓库
2. 执行安装脚本

#### 配置位置

访问：**GitHub.com → Settings → Codespaces → Dotfiles**

![GitHub Codespaces Dotfiles Settings](https://docs.github.com/assets/cb-48899/mw-1440/images/help/codespaces/codespaces-dotfiles-settings.webp)

配置项：
- ✅ **Automatically install dotfiles**：勾选以启用
- 📦 **Repository**：选择你的 dotfiles 仓库（格式：`username/dotfiles`）

> **官方文档引用**：
> "If you enable the Automatically install dotfiles setting, GitHub Codespaces will clone your dotfiles repository into the codespace environment as soon as it's created."
>
> 来源：[Enabling your dotfiles repository for Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#enabling-your-dotfiles-repository-for-codespaces)

---

### 场景 4：勾选了全局设置，但不想在特定项目使用 dotfiles

#### 场景描述
- GitHub Settings 中**已勾选** "Automatically install dotfiles"
- 某个特定项目**不需要**使用 dotfiles（例如：测试干净环境）

#### 问题

**官方不支持项目级别禁用 dotfiles**

根据官方文档和社区讨论，devcontainer.json 中没有官方方法禁用 dotfiles。

> **社区讨论引用**：
> "I don't want users of my pre-defined Codespace template to enable dotfiles in their profile as a mandatory act... but there seems to be no way to define a dotfiles repository on the template level."
>
> 来源：[GitHub Community Discussion #134612](https://github.com/orgs/community/discussions/134612)

#### 解决方案：使用标记文件机制（本仓库实现）

##### 步骤 1：在项目中创建标记文件

在项目根目录创建 `.skip-dotfiles` 文件：

```bash
cd your-project
touch .skip-dotfiles
git add .skip-dotfiles
git commit -m "Skip dotfiles installation in this project"
git push
```

##### 步骤 2：dotfiles 仓库支持（已实现）

本 dotfiles 仓库的 `install.sh` 已经实现了检测逻辑：

```bash
#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

# 检查是否应该跳过 dotfiles 安装
# 如果项目根目录有 .skip-dotfiles 文件，则跳过
if [ -f "/workspaces/$(basename $PWD)/.skip-dotfiles" ] || [ -f "$HOME/workspace/.skip-dotfiles" ]; then
  echo "⏭️  Found .skip-dotfiles marker, skipping dotfiles installation"
  exit 0
fi

echo "🚀 Setting up dotfiles..."
# ... 继续安装
```

**工作原理**：

1. Codespaces 创建时自动克隆 dotfiles 仓库
2. 执行 `install.sh` 脚本
3. 脚本检测到 `.skip-dotfiles` 文件
4. 提前退出，跳过所有安装步骤

**示例：项目目录结构**

```
your-project/
├── .devcontainer/
│   └── devcontainer.json
├── .skip-dotfiles           # ← 添加这个文件
├── README.md
└── src/
```

##### 替代方案：临时禁用全局设置

如果只是偶尔需要干净环境：

1. 访问 GitHub Settings → Codespaces
2. 临时取消勾选 "Automatically install dotfiles"
3. 创建 Codespace
4. 测试完成后重新勾选

> **注意**：此方法会影响所有新建的 Codespace。

---

## 查看 Dotfiles 初始化日志

### 方法 1：VS Code Command Palette

1. 打开 Command Palette：`Cmd/Ctrl + Shift + P`
2. 搜索并选择：**"Codespaces: View Creation Log"**
3. 查看 dotfiles 安装过程的输出

### 方法 2：查看日志文件

在 Codespace 终端中运行：

```bash
# 查看创建日志（如果存在）
cat /workspaces/.codespaces/.persistedshare/creation.log 2>/dev/null

# 或者查看实时日志
tail -f /tmp/codespaces-*.log 2>/dev/null
```

> **注意**：日志文件的位置可能因 Codespaces 版本而异。

---

## 总结对比表

| 场景 | 全局设置 | 项目需求 | 配置方法 | 官方支持 |
|------|---------|---------|---------|---------|
| **场景 1** | ❌ 未勾选 | ✅ 需要 | Dev Container Feature 或 postCreateCommand | ✅ 是（Feature 为社区方案） |
| **场景 2** | ❌ 未勾选 | ❌ 不需要 | 无需配置 | ✅ 是 |
| **场景 3** | ✅ 已勾选 | ✅ 需要 | 无需配置 | ✅ 是 |
| **场景 4** | ✅ 已勾选 | ❌ 不需要 | `.skip-dotfiles` 标记文件 | ❌ 否（本仓库实现） |

---

## 常见问题 (FAQ)

### Q1: 为什么 `customizations.codespaces.dotfiles: false` 不起作用？

**A**: 这不是官方支持的配置项。根据 [GitHub Community Discussion #134612](https://github.com/orgs/community/discussions/134612) 和 [Dev Container Specification](https://containers.dev/implementors/spec/)，在 devcontainer.json 中无法原生配置或禁用 dotfiles。

### Q2: 如何在不影响其他项目的情况下测试干净环境？

**A**: 使用本仓库提供的 `.skip-dotfiles` 标记文件机制（场景 4）。

### Q3: Dev Container Feature 安全吗？

**A**: [jpawlowski/devcontainer-features](https://github.com/jpawlowski/devcontainer-features) 是社区维护的开源项目。使用前请：
1. 查看源代码
2. 检查 GitHub Stars 和使用情况
3. 阅读 issue 和讨论

### Q4: 为什么 install.sh 使用复制而不是符号链接？

**A**: 本仓库的 `install.sh` 使用 `cp` 而不是 `ln -s`，这样你可以在 Codespace 中直接修改配置文件，而不会影响原始的 dotfiles 仓库。

```bash
# 复制配置文件（可自由修改）
cp -f "$DOTFILES/.bashrc" "$HOME/.bashrc"

# vs 符号链接（修改会影响源仓库）
ln -sf "$DOTFILES/.bashrc" "$HOME/.bashrc"
```

---

## 参考文档

### 官方文档

1. **GitHub Codespaces - Personalizing with dotfiles**
   https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles

2. **Dev Container Specification**
   https://containers.dev/implementors/spec/

3. **devcontainer.json Reference**
   https://containers.dev/implementors/json_reference/

### 社区资源

4. **GitHub Community Discussion #134612** - Reference dotfiles repository in devcontainer.json
   https://github.com/orgs/community/discussions/134612

5. **jpawlowski/devcontainer-features** - codespaces-dotfiles Feature
   https://github.com/jpawlowski/devcontainer-features/tree/main/src/codespaces-dotfiles

6. **workoho/devcontainer-dotfiles** - 使用 chezmoi 的 dotfiles 示例
   https://github.com/workoho/devcontainer-dotfiles

---

## 版本历史

- **2026-03-25**: 初始版本，文档化 4 种使用场景
- 基于 GitHub Codespaces 和 Dev Container Specification 当前版本

---

**许可证**: MIT
**维护者**: [Your Name/Organization]
**问题反馈**: 请在本仓库创建 issue

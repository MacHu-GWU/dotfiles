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

# 复制配置文件到 home 目录（而不是软链接）
# 这样可以在 Codespaces 中直接修改，不会影响 dotfiles repo
echo "📋 Copying dotfiles to home directory..."

# 复制 shell 配置文件
for file in .bashrc .bash_profile .zshrc; do
  if [ -f "$DOTFILES/$file" ]; then
    cp -f "$DOTFILES/$file" "$HOME/$file"
    echo "  ✅ Copied $file"
  fi
done

# 复制 .config 目录
if [ -d "$DOTFILES/.config" ]; then
  mkdir -p "$HOME/.config"
  cp -rf "$DOTFILES/.config/"* "$HOME/.config/"
  echo "  ✅ Copied .config directory"
fi

if [ "$OS" = "Linux" ]; then
  echo ""
  echo "🔧 Installing tools for Linux..."

  # 安装 starship
  if ! command -v starship &>/dev/null; then
    echo "📦 Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  else
    echo "✅ starship already installed"
  fi

  # 安装 mise
  if ! command -v mise &>/dev/null; then
    echo "📦 Installing mise..."
    curl https://mise.run | sh
  else
    echo "✅ mise already installed"
  fi

  # 确保 PATH 包含安装路径
  export PATH="$HOME/.local/bin:$PATH"

  # 验证安装
  echo ""
  echo "✅ Verification:"
  command -v starship &>/dev/null && echo "  starship: $(starship --version)" || echo "  starship: ❌ not found"
  command -v mise &>/dev/null && echo "  mise: $(mise --version)" || echo "  mise: ❌ not found"
fi

echo ""
echo "🎉 Development environment setup complete!"
echo "💡 Tip: You can now freely modify config files in your home directory"

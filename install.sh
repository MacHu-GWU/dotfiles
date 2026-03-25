#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

if [ "$OS" = "Linux" ]; then
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

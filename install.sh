#!/bin/bash

echo "🚀 Setting up development environment..."

# 安装 uv
echo "📦 Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# 添加 uv 到 PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# 安装其他常用工具
echo "📦 Installing additional tools..."

# 验证安装
echo "✅ Verification:"
source ~/.bashrc
~/.local/bin/uv --version || echo "uv installation pending (will be available after restart)"

echo "🎉 Development environment setup complete!"
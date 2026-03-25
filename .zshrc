# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# starship.rs: https://starship.rs/
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# mise-en-place: https://mise.jdx.dev/
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

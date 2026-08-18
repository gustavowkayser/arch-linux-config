# PATH for zsh now lives in $ZDOTDIR/.zshenv (~/.config/zsh/.zshenv).
# Kept here so sh login shells still find the Rust toolchain.
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

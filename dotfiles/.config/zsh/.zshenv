#!/usr/bin/env zsh
# Environment for every zsh shell: login, interactive, and scripts alike.
# Sourced by ~/.zshenv, which is what points ZDOTDIR at this directory.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# PATH. `typeset -U` keeps it deduplicated, and the (N-/) glob qualifier drops
# entries that do not exist on this machine, so the same file works everywhere.
typeset -U path PATH
path=(
    "$HOME/.local/bin"(N-/)
    "$HOME/.cargo/bin"(N-/)
    "$XDG_DATA_HOME/JetBrains/Toolbox/scripts"(N-/)
    $path
)
export PATH

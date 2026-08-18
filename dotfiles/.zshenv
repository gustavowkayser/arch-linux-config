#!/usr/bin/env zsh
# Bootstrap only: point zsh at $ZDOTDIR and hand off. Everything else lives in
# $ZDOTDIR/.zshenv so it stays with the rest of the zsh config.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# Missing on a half-restored machine is not fatal — the shell should still come
# up. A file that exists but fails to load is worth complaining about.
if [[ -r "$ZDOTDIR/.zshenv" ]] && ! source "$ZDOTDIR/.zshenv"; then
    print -u2 "Error: could not source $ZDOTDIR/.zshenv"
fi

#!/usr/bin/env bash
# Reinstall everything listed in packages/ on a fresh Arch machine.
#
# Official repo packages go through pacman; AUR packages need an AUR helper
# (yay by default), which is bootstrapped from source if it is missing.
#
#   ./scripts/install-packages.sh            install repo + AUR packages
#   ./scripts/install-packages.sh --repo     repo packages only
#   ./scripts/install-packages.sh --aur      AUR packages only

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKGLIST="$REPO/packages/pkglist.txt"
AURLIST="$REPO/packages/aurlist.txt"
DO_REPO=1
DO_AUR=1

for arg in "$@"; do
    case "$arg" in
        --repo) DO_AUR=0 ;;
        --aur) DO_REPO=0 ;;
        -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
        *) printf 'unknown option: %s\n' "$arg" >&2; exit 2 ;;
    esac
done

[[ $EUID -eq 0 ]] && { printf 'run this as your normal user, not root\n' >&2; exit 1; }

if (( DO_REPO )); then
    [[ -f "$PKGLIST" ]] || { printf 'missing %s\n' "$PKGLIST" >&2; exit 1; }
    printf '==> installing %s repo packages\n' "$(wc -l < "$PKGLIST")"
    sudo pacman -Syu --needed --noconfirm - < "$PKGLIST"
fi

if (( DO_AUR )); then
    [[ -f "$AURLIST" ]] || { printf 'missing %s\n' "$AURLIST" >&2; exit 1; }

    helper=""
    for candidate in yay paru; do
        command -v "$candidate" >/dev/null && { helper="$candidate"; break; }
    done

    if [[ -z "$helper" ]]; then
        printf '==> no AUR helper found, building yay\n'
        sudo pacman -S --needed --noconfirm git base-devel
        build_dir="$(mktemp -d)"
        git clone https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
        (cd "$build_dir/yay-bin" && makepkg -si --noconfirm)
        rm -rf "$build_dir"
        helper="yay"
    fi

    printf '==> installing %s AUR packages with %s\n' "$(wc -l < "$AURLIST")" "$helper"
    "$helper" -S --needed --noconfirm - < "$AURLIST"
fi

printf '\ndone\n'

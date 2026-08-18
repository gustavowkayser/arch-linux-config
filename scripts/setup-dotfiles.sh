#!/usr/bin/env bash
# Restore the dotfiles in this repo onto a machine.
#
# By default every tracked file is symlinked into $HOME, so edits made later
# land back in the repo. Use --copy on machines where symlinks are awkward.
# Anything already present in $HOME is moved aside to <file>.bak.<timestamp>.
#
#   ./scripts/setup-dotfiles.sh            symlink into $HOME
#   ./scripts/setup-dotfiles.sh --copy     copy instead of symlink
#   ./scripts/setup-dotfiles.sh -n         dry run

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_ROOT="$REPO/dotfiles"
MODE="link"
DRY_RUN=0
STAMP="$(date +%Y%m%d%H%M%S)"

for arg in "$@"; do
    case "$arg" in
        --copy) MODE="copy" ;;
        -n|--dry-run) DRY_RUN=1 ;;
        -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
        *) printf 'unknown option: %s\n' "$arg" >&2; exit 2 ;;
    esac
done

[[ -d "$SRC_ROOT" ]] || { printf 'no dotfiles/ directory in %s\n' "$REPO" >&2; exit 1; }

linked=0 backed_up=0

while IFS= read -r -d '' src; do
    rel="${src#"$SRC_ROOT"/}"
    dst="$HOME/$rel"

    # Already pointing at this repo — nothing to do.
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        continue
    fi

    printf '%-6s %s\n' "$MODE" "$rel"
    if (( DRY_RUN )); then
        linked=$((linked + 1))
        continue
    fi

    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" || -L "$dst" ]]; then
        mv "$dst" "$dst.bak.$STAMP"
        backed_up=$((backed_up + 1))
    fi

    if [[ "$MODE" == "link" ]]; then
        ln -s "$src" "$dst"
    else
        cp --preserve=mode "$src" "$dst"
    fi
    linked=$((linked + 1))
done < <(find "$SRC_ROOT" -type f -print0)

printf '\n%d files %sed, %d existing files backed up as *.bak.%s\n' \
    "$linked" "$MODE" "$backed_up" "$STAMP"
if (( DRY_RUN )); then printf 'dry run — nothing was written\n'; fi

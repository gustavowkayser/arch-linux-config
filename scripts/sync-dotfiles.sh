#!/usr/bin/env bash
# Copy the dotfiles listed in dotfiles.manifest out of $HOME and into this repo.
# Run this after changing any config you care about, then commit.
#
#   ./scripts/sync-dotfiles.sh          sync everything in the manifest
#   ./scripts/sync-dotfiles.sh -n       dry run, just print what would happen

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO/dotfiles.manifest"
DEST_ROOT="$REPO/dotfiles"
DRY_RUN=0
[[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# Names that never belong in a config backup: VCS metadata, caches, compiled
# artifacts, shell history and other machine-local state.
EXCLUDES=(
    ".git" ".gitignore" "node_modules" "__pycache__"
    ".zcompdump*" "*.zwc" ".zsh_history" ".bash_history"
    "History" "globalStorage" "workspaceStorage" "logs" "Cache" "CachedData"
    "chatLanguageModels.json" "agent-sessions.code-workspace"
    "*.log" "*.tmp" "*.sock" "*.pid"
)

find_args=()
for pattern in "${EXCLUDES[@]}"; do
    find_args+=(-name "$pattern" -prune -o)
done

copied=0 missing=0

while IFS= read -r rel; do
    rel="${rel%%$'\r'}"
    [[ -z "$rel" || "$rel" == \#* ]] && continue

    src="$HOME/$rel"
    dst="$DEST_ROOT/$rel"

    if [[ ! -e "$src" ]]; then
        printf 'missing  %s\n' "$rel"
        missing=$((missing + 1))
        continue
    fi

    printf 'sync     %s\n' "$rel"
    (( DRY_RUN )) && { copied=$((copied + 1)); continue; }

    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -L --preserve=mode "$src" "$dst"
    else
        # Replace the tracked copy wholesale so deletions upstream propagate.
        rm -rf "$dst"
        mkdir -p "$dst"
        # Walk the source, skipping excluded names, and mirror what is left.
        (cd "$src" && find . "${find_args[@]}" -print0) |
            while IFS= read -r -d '' entry; do
                [[ "$entry" == "." ]] && continue
                if [[ -d "$src/$entry" && ! -L "$src/$entry" ]]; then
                    mkdir -p "$dst/$entry"
                elif [[ -f "$src/$entry" ]]; then
                    mkdir -p "$(dirname "$dst/$entry")"
                    cp -L --preserve=mode "$src/$entry" "$dst/$entry"
                fi
            done
        find "$dst" -type d -empty -delete
    fi
    copied=$((copied + 1))
done < "$MANIFEST"

printf '\n%d synced, %d missing\n' "$copied" "$missing"
if (( DRY_RUN )); then printf 'dry run — nothing was written\n'; fi

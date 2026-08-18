#!/usr/bin/env bash
# Refresh packages/pkglist.txt and packages/aurlist.txt from what is installed.
#
#   pkglist.txt  explicitly installed packages from the official repos
#   aurlist.txt  explicitly installed foreign (AUR) packages
#
# Debug packages are dropped — they are pulled in by the build, not chosen.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$REPO/packages"

pacman -Qqen | grep -v -- '-debug$' | sort > "$REPO/packages/pkglist.txt"
pacman -Qqem | grep -v -- '-debug$' | sort > "$REPO/packages/aurlist.txt"

printf 'pkglist.txt  %s packages\n' "$(wc -l < "$REPO/packages/pkglist.txt")"
printf 'aurlist.txt  %s packages\n' "$(wc -l < "$REPO/packages/aurlist.txt")"

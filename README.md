# arch-linux-config

Backup of my Arch Linux setup: dotfiles, package lists, and the scripts to put
them back on a new machine.

## What's here

| Path                 | Contents                                                        |
| -------------------- | --------------------------------------------------------------- |
| `dotfiles/`          | Config files, mirroring their paths relative to `$HOME`          |
| `dotfiles.manifest`  | The list of paths that get backed up — edit this to add more     |
| `packages/`          | `pkglist.txt` (repo packages) and `aurlist.txt` (AUR packages)   |
| `scripts/`           | Sync (machine → repo) and restore (repo → machine) scripts       |

## Restoring on a fresh install

```sh
git clone git@github.com:gustavowkayser/arch-linux-config.git
cd arch-linux-config

./scripts/install-packages.sh    # pacman + AUR (bootstraps yay if needed)
./scripts/setup-dotfiles.sh      # symlink dotfiles/ into $HOME
```

`setup-dotfiles.sh` symlinks each file so later edits flow back into the repo.
Pass `--copy` for plain copies, or `-n` to see what it would do first. Anything
it would overwrite is moved to `<file>.bak.<timestamp>` instead.

## Keeping the backup current

```sh
./scripts/sync-dotfiles.sh     # copy configs out of $HOME into dotfiles/
./scripts/sync-packages.sh     # regenerate packages/*.txt from pacman
git add -A && git commit -m "sync config"
```

To back up something new, add its `$HOME`-relative path to `dotfiles.manifest`
and re-run `sync-dotfiles.sh`. Directories are copied recursively; caches, VCS
metadata, history files, and editor state are filtered out (see `EXCLUDES` in
`scripts/sync-dotfiles.sh`).

## The setup being backed up

- **WM/desktop**: Hyprland, configured in Lua under `.config/hypr` on top of
  [caelestia](https://github.com/caelestia-dots) (shell, themes, qtengine)
- **Shell**: zsh with `ZDOTDIR=$HOME/.config/zsh` and oh-my-zsh; fish available
- **Terminals**: kitty, foot; starship prompt
- **Editors**: Neovim (NvChad), Zed, VSCodium, Code - OSS, micro
- **Theming**: GTK 3/4, Qt (`qtengine`), Bibata cursors, caelestia colors

## Notes

- zsh loads in three steps: `~/.zshenv` sets `ZDOTDIR` and hands off to
  `$ZDOTDIR/.zshenv` (XDG paths and other always-on environment), then
  `$ZDOTDIR/.zshrc` loads oh-my-zsh from `.config/zsh/ohmyzsh`.
- `~/.zshrc` and `~/.oh-my-zsh` are an unused leftover from an earlier install —
  the live rc file is `.config/zsh/.zshrc`. Both are backed up so nothing is
  lost, but only the `ZDOTDIR` one is read.
- Not tracked on purpose: SSH keys, GPG keys, browser profiles, Discord clients,
  JetBrains IDE state, and anything else holding credentials or session data.
  Restore those by hand.
- Fonts (`~/.local/share/fonts`, ~122 MB) and oh-my-zsh are excluded; reinstall
  them from packages instead.

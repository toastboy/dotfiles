# dotfiles

My shell, editor and git setup, managed with [chezmoi](https://www.chezmoi.io/). Carved out of the `common` role in
[an-baremetal](https://github.com/toastboy/an-baremetal) when that repo was retired (SYS-637): once dewey became a Talos
node, the only machines left needing this were Macs and the odd Ubuntu/WSL box.

## New machine

```bash
# macOS
brew install chezmoi
# Debian/Ubuntu
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

chezmoi init toastboy/dotfiles
chezmoi diff        # see what it would change first
chezmoi apply
```

## What's here

| Path | Notes |
|---|---|
| `dot_zshrc.tmpl` | Whole `.zshrc`; one macOS block is the only conditional |
| `.chezmoiexternal.toml` | Oh My Zsh and Powerlevel10k, pulled weekly |
| `dot_p10k.zsh`, `dot_emacs.d/` | Copied as-is |
| `dot_gitconfig.tmpl` | 1Password SSH commit signing on macOS only |
| `private_dot_ssh/modify_*` | Merge my GitHub keys into `authorized_keys`, GitHub's host keys into `known_hosts`; never remove anything |
| `Brewfile` | macOS packages, the same on every Mac, applied by `brew bundle` whenever it changes |
| `.chezmoiscripts/` | apt packages + HashiCorp and GitHub CLI repos on Debian, zsh as login shell, emacs daemon on systemd Linux |

There is deliberately no per-machine configuration: every Mac gets the whole Brewfile. The Debian package list is a
superset of the Mac's (`isync`, `nmap`, `packer`, `terraform` and others), which is fine, since Debian is only for
throwaway boxes. `entire` is installed as a binary only, on macOS only (Entire's Linux installer has no integrity check worth running
unattended); run `entire enable` in each repository that uses it.

Unlike the old Ansible run, nothing here upgrades packages on a schedule: use `brew upgrade` / `apt upgrade`.

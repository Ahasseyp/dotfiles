# Dotfiles Context

Shared language for this repository of cross-machine macOS configuration.

## Language

**Dotfiles repository**:
A version-controlled collection of configuration files and setup scripts used to recreate a consistent terminal environment on any supported Mac.
_Avoid_: config repo, settings backup.

**Managed tool**:
A command-line or terminal-facing program whose configuration lives in this repository and is deployed to `~` during install.
_Examples_: Zsh, Neovim, OpenSSH, iTerm2, OhMyZsh.

**Stow package**:
A top-level directory whose internal structure mirrors the home directory and is deployed with GNU Stow.
_Example_: a `zsh/` package contains `.zshrc` at its root so Stow maps it to `~/.zshrc`.

**Shared config**:
A configuration file committed to the repository that is identical on every machine.
_Example_: `.zshrc` that sources a local override.

**Local override**:
An untracked file on a specific machine that supplies values the shared config does not contain, such as git email or work aliases.
_Example_: `~/.zshrc.local`.

**Machine-specific values**:
Settings that differ between personal and work machines but do not change the structure of the config.
_Examples_: git user email, work-specific environment variables, private host aliases.

**Secrets**:
Private data such as SSH private keys, API tokens, or GPG keys that must not be committed to the repository.
_Resolution_: stored outside the repo (currently 1Password for SSH keys).

## Flagged ambiguities

**NeoBeam**: A typo for **Neovim**. Use only **Neovim** in documentation and filenames.

**Terminal**: Ambiguous. This user uses **iTerm2**, not Terminal.app. Use **iTerm2** unless Terminal.app is explicitly intended.

## Example dialogue

> Dev: I added a new alias to the shared `zsh` Stow package, but my work machine needs a different git email. Where does that go?
>
> Maintainer: Put the alias in `zsh/.zshrc` since it applies everywhere. Put the work git email in `~/.gitconfig.local` on the work machine; the shared `git/.gitconfig` sources it.
>
> Dev: What about my SSH keys?
>
> Maintainer: Those are secrets — keep them in 1Password. The repo only stores `ssh/.ssh/config` and public settings.

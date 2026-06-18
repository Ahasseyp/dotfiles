# Dotfiles

Cross-machine macOS terminal configuration managed with GNU Stow.

## Supported tools

- Zsh + OhMyZsh (with Powerlevel10k and zsh-autosuggestions)
- Neovim
- Git
- OpenSSH
- iTerm2 (Dynamic Profiles)
- Homebrew (Brewfile)

## Secrets policy

This repository never stores secrets. API tokens, SSH private keys, and other
machine-specific credentials belong in untracked `*.local` files. See the
`.local.example` files for the expected structure.

## Install

1. Clone this repo:

   ```sh
   git clone git@github.com:Ahasseyp/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Install dependencies:

   ```sh
   brew bundle
   ```

3. Run the bootstrap script:

   ```sh
   ./bootstrap.sh
   ```

4. Copy local overrides and fill in machine-specific values:

   ```sh
   cp ~/.zshrc.local.example ~/.zshrc.local
   cp ~/.zshenv.local.example ~/.zshenv.local
   cp ~/.gitconfig.local.example ~/.gitconfig.local
   cp ~/.ssh/config.local.example ~/.ssh/config.local
   ```

5. Configure iTerm2 to load Dynamic Profiles from the directory shown in
   **Preferences → Profiles → Other Actions... → Save Current Settings as a Folder**.
   The profile is copied to `~/.config/iterm2/AppSupport/DynamicProfiles/` during bootstrap.

## Update

Once installed, your symlinks point into `~/dotfiles`, so existing files update automatically when the repo is pulled.

To update to the latest release:

```sh
dotfiles-update
```

Flags:

- `dotfiles-update --check` — print local vs. remote version
- `dotfiles-update --force` — re-run bootstrap even if already up to date
- `dotfiles-update --verbose` — show full bootstrap output

When `dotfiles-update` detects uncommitted changes in `~/dotfiles`, it prompts you to stash, discard tracked changes, or abort.

A daily check runs when a new zsh shell starts. If a newer release exists, it prints:

```
dotfiles update available: 1.0.0 → 1.1.0. Run: dotfiles-update
```

## Releasing changes

This repo follows a release workflow similar to [gswitch](https://github.com/Ahasseyp/gswitch).

1. Create a feature branch from `main`:

   ```sh
   git checkout -b feat/my-change
   ```

2. Make your changes and commit them.
3. Bump the version in `VERSION` (e.g., `1.1.0`) and commit the bump.
4. Open a pull request to `main`.
5. Merge the pull request.
6. A GitHub Action reads `VERSION` from `main` and automatically creates a release at `v<X.Y.Z>`.

On each machine, the daily zsh check warns the user when a newer release exists, and they run `dotfiles-update` to apply it.

## Adding a new tool

1. Create a top-level directory that mirrors the home directory layout.
2. Add it to the `PACKAGES` array in `bootstrap.sh`.
3. Run `./bootstrap.sh` to stow it.

## Local overrides

This repo stores shared configs that are the same on every machine. Values that differ between personal and work machines (git email, aliases, private hosts) live in untracked local override files.

## Secrets

SSH private keys and other secrets are not committed. Store them in 1Password and configure `~/.ssh/config` to use the 1Password SSH agent.

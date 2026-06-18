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
   The profile is stowed to `~/.config/iterm2/AppSupport/DynamicProfiles/`.

## Adding a new tool

1. Create a top-level directory that mirrors the home directory layout.
2. Add it to the `PACKAGES` array in `bootstrap.sh`.
3. Run `./bootstrap.sh` to stow it.

## Local overrides

This repo stores shared configs that are the same on every machine. Values that differ between personal and work machines (git email, aliases, private hosts) live in untracked local override files.

## Secrets

SSH private keys and other secrets are not committed. Store them in 1Password and configure `~/.ssh/config` to use the 1Password SSH agent.

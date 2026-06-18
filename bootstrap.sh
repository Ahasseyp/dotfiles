#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh git ssh nvim iterm2 ohmyzsh)

CUSTOM_PLUGINS=(
  "https://github.com/zsh-users/zsh-autosuggestions"
)
CUSTOM_THEMES=(
  "https://github.com/romkatv/powerlevel10k"
)

cd "$DOTFILES_DIR"

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU Stow is required but not installed." >&2
  echo "Install it with: brew install stow" >&2
  exit 1
fi

echo "Checking for stow conflicts..."
for package in "${PACKAGES[@]}"; do
  if [[ ! -d "$package" ]]; then
    continue
  fi
  if ! stow --no --target="$HOME" "$package" >/dev/null 2>&1; then
    echo "Error: stow conflict detected for package '$package'." >&2
    echo "Resolve existing files or remove them before running this script." >&2
    exit 1
  fi
done

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing OhMyZsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "OhMyZsh already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

for repo in "${CUSTOM_PLUGINS[@]}"; do
  name="$(basename "$repo")"
  target="$ZSH_CUSTOM/plugins/$name"
  if [[ ! -d "$target" ]]; then
    echo "Installing custom plugin: $name"
    git clone --depth 1 "$repo" "$target"
  else
    echo "Custom plugin already installed: $name"
  fi
done

for repo in "${CUSTOM_THEMES[@]}"; do
  name="$(basename "$repo")"
  target="$ZSH_CUSTOM/themes/$name"
  if [[ ! -d "$target" ]]; then
    echo "Installing custom theme: $name"
    git clone --depth 1 "$repo" "$target"
  else
    echo "Custom theme already installed: $name"
  fi
done

echo "Stowing packages..."
for package in "${PACKAGES[@]}"; do
  if [[ -d "$package" ]]; then
    stow --target="$HOME" --restow "$package"
    echo "  - $package"
  fi
done

echo ""
echo "Done. Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Copy any needed local overrides:"
echo "     cp ~/.zshrc.local.example ~/.zshrc.local"
echo "     cp ~/.zshenv.local.example ~/.zshenv.local"
echo "     cp ~/.gitconfig.local.example ~/.gitconfig.local"
echo "     cp ~/.ssh/config.local.example ~/.ssh/config.local"

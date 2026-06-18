#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh git ssh nvim iterm2)
BIN_DIR="${HOME}/.local/bin"
SKIPPED_PACKAGES=()

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

find_conflicts() {
  local package="$1"

  find "$package" -mindepth 1 -print0 | while IFS= read -r -d '' source_path; do
    local relative="${source_path#$package/}"
    local target="$HOME/$relative"

    if [[ ! -e "$target" && ! -L "$target" ]]; then
      continue
    fi

    if [[ -L "$target" ]]; then
      local link_target
      link_target=$(readlink "$target") || true
      if [[ "$link_target" == "$DOTFILES_DIR/$source_path" ]]; then
        continue
      fi
    fi

    if [[ -d "$source_path" && -d "$target" ]]; then
      continue
    fi

    printf '%s\n' "$relative"
  done
}

find_stow_conflicts() {
  local package="$1"
  local output
  output=$(stow --no --target="$HOME" "$package" 2>&1) || true

  if [[ -z "$output" ]]; then
    return 0
  fi

  if [[ "$output" == *"existing target is not owned by stow"* ]]; then
    printf '%s\n' "existing target is not owned by stow"
  fi

  printf '%s\n' "$output"
}

backup_conflicts() {
  local package="$1"
  shift
  local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)/$package"

  mkdir -p "$backup_dir"

  for relative in "$@"; do
    local target="$HOME/$relative"
    local backup_path="$backup_dir/$relative"
    if [[ -e "$target" || -L "$target" ]]; then
      mkdir -p "$(dirname "$backup_path")"
      mv "$target" "$backup_path"
      echo "  backed up: ~/$relative"
    fi
  done

  echo "  backup location: $backup_dir"
}

override_conflicts() {
  shift

  for relative in "$@"; do
    local target="$HOME/$relative"
    if [[ -e "$target" || -L "$target" ]]; then
      rm -rf "$target"
      echo "  removed: ~/$relative"
    fi
  done
}

resolve_package_conflicts() {
  local package="$1"
  local conflicts=()

  while IFS= read -r line; do
    [[ -n "$line" ]] && conflicts+=("$line")
  done < <(find_conflicts "$package")

  local stow_output
  stow_output=$(find_stow_conflicts "$package")

  if [[ ${#conflicts[@]} -eq 0 && -z "$stow_output" ]]; then
    echo "Error: stow conflict detected for package '$package' but no specific conflicts could be identified." >&2
    echo "Resolve existing files manually or remove them before running this script." >&2
    exit 1
  fi

  echo ""
  echo "Conflicts detected for package '$package':"
  if [[ ${#conflicts[@]} -gt 0 ]]; then
    for conflict in "${conflicts[@]}"; do
      echo "  - $HOME/$conflict"
    done
  fi
  if [[ -n "$stow_output" ]]; then
    echo "$stow_output" | sed 's/^/  /'
  fi

  while true; do
    echo ""
    echo "Choose an action:"
    echo "  [B]ackup existing files, then stow"
    echo "  [O]verride (delete) existing files, then stow"
    echo "  [S]kip this package"
    echo "  [A]bort"
    read -rp "Choice [b/o/s/a]: " choice

    case "$choice" in
      [Bb])
        if [[ ${#conflicts[@]} -gt 0 ]]; then
          backup_conflicts "$package" "${conflicts[@]}"
        else
          echo "  No specific files to back up. Stow will handle the conflicting directory."
        fi
        return 0
        ;;
      [Oo])
        override_conflicts "$package" "${conflicts[@]}"
        return 0
        ;;
      [Ss])
        return 1
        ;;
      [Aa])
        echo "Aborted by user." >&2
        exit 1
        ;;
      *)
        echo "Invalid choice: $choice. Please enter b, o, s, or a." >&2
        ;;
    esac
  done
}

is_skipped() {
  local package="$1"
  if [[ ${#SKIPPED_PACKAGES[@]} -gt 0 ]]; then
    for skipped in "${SKIPPED_PACKAGES[@]}"; do
      if [[ "$skipped" == "$package" ]]; then
        return 0
      fi
    done
  fi
  return 1
}

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

echo ""
echo "Checking for stow conflicts..."
for package in "${PACKAGES[@]}"; do
  if [[ ! -d "$package" ]]; then
    continue
  fi

  if ! stow --no --target="$HOME" "$package" >/dev/null 2>&1; then
    if ! resolve_package_conflicts "$package"; then
      SKIPPED_PACKAGES+=("$package")
      echo "  Skipping package '$package'."
    fi
  fi
done

echo ""
echo "Stowing packages..."
for package in "${PACKAGES[@]}"; do
  if [[ -d "$package" ]] && ! is_skipped "$package"; then
    if ! stow --target="$HOME" --restow "$package"; then
      echo "Error: failed to stow package '$package'" >&2
      exit 1
    fi
    echo "  - $package"
  fi
done

if ! is_skipped "iterm2"; then
  ITERM2_DYNAMIC_PROFILES_DIR="$HOME/.config/iterm2/AppSupport/DynamicProfiles"
  ITERM2_SOURCE_PROFILE="$DOTFILES_DIR/iterm2/.config/iterm2/DynamicProfile-default.json"

  if [[ -f "$ITERM2_SOURCE_PROFILE" ]]; then
    echo "Installing iTerm2 dynamic profile..."
    mkdir -p "$ITERM2_DYNAMIC_PROFILES_DIR"
    cp -f "$ITERM2_SOURCE_PROFILE" "$ITERM2_DYNAMIC_PROFILES_DIR/default.json"
    echo "  - $ITERM2_DYNAMIC_PROFILES_DIR/default.json"
  fi
fi

echo ""
echo "Installing dotfiles-update..."
if [[ -f "${DOTFILES_DIR}/bin/dotfiles-update" ]]; then
  mkdir -p "$BIN_DIR"
  cp "${DOTFILES_DIR}/bin/dotfiles-update" "${BIN_DIR}/dotfiles-update"
  chmod +x "${BIN_DIR}/dotfiles-update"
  echo "  installed ${BIN_DIR}/dotfiles-update"
else
  echo "  Warning: dotfiles-update script not found at ${DOTFILES_DIR}/bin/dotfiles-update" >&2
fi

echo ""
echo "Done. Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Copy any needed local overrides:"
echo "     cp ~/.zshrc.local.example ~/.zshrc.local"
echo "     cp ~/.zshenv.local.example ~/.zshenv.local"
echo "     cp ~/.gitconfig.local.example ~/.gitconfig.local"
echo "     cp ~/.ssh/config.local.example ~/.ssh/config.local"

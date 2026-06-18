# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  vi-mode
  sudo
  npm
  zsh-autosuggestions
  brew
  yarn
)

source $ZSH/oh-my-zsh.sh
source $HOME/.zshalias
source $HOME/.zshenv

bindkey '^ ' autosuggest-accept

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"

# Load nvm from a manual install or from Homebrew
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
elif [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  \. "/opt/homebrew/opt/nvm/nvm.sh"
fi

if [ -s "$NVM_DIR/bash_completion" ]; then
  \. "$NVM_DIR/bash_completion"
elif [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
  \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# clean up docker
docker-clean() {
  $(docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null)
  $(docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null)
}

# clean docker, including volumes
docker-super-clean() {
  $(docker rm -f $(docker ps -a -q))
  $(docker system prune -a -f --volumes)
  $(docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null)
  $(docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null)
  $(docker volume rm $(docker volume ls -f dangling=true -q))
}

autoload -U add-zsh-hook
load-nvmrc() {
  if ! command -v nvm >/dev/null 2>&1; then
    return
  fi

  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
command -v nvm >/dev/null 2>&1 && load-nvmrc

export NODE_OPTIONS="--max-old-space-size=12000"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Daily dotfiles update check
_dotfiles_check_for_updates() {
  local dotfiles_dir="$HOME/dotfiles"
  local version_file="${dotfiles_dir}/VERSION"
  local last_check_file="${HOME}/.local/share/dotfiles/last_update_check"
  local api_url="https://api.github.com/repos/Ahasseyp/dotfiles/releases/latest"

  if [[ ! -f "$version_file" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$last_check_file")"

  local now
  now=$(date +%s)
  local last=0
  if [[ -f "$last_check_file" ]]; then
    last=$(cat "$last_check_file" 2>/dev/null || echo 0)
  fi

  if (( now - last < 86400 )); then
    return 0
  fi

  echo "$now" > "$last_check_file"

  (
    local local_version
    local_version=$(tr -d '[:space:]' < "$version_file" 2>/dev/null || echo "")
    local remote_version
    remote_version=$(curl -fsSL --max-time 3 "$api_url" 2>/dev/null \
      | grep '"tag_name"' | head -1 \
      | sed 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/' || true)

    if [[ -n "$local_version" && -n "$remote_version" && "$remote_version" != "$local_version" ]]; then
      echo "dotfiles update available: $local_version → $remote_version. Run: dotfiles-update"
    fi
  ) &!
}
_dotfiles_check_for_updates

# Load local overrides if present
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

export EDITOR=nvim
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

export PATH="$HOME/.local/bin:$PATH"

export AUTOSWITCH_DEFAULT_PYTHON="$HOME/.pyenv/shims/python"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Load local overrides if present
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

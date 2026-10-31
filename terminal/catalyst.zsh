# ✦ CATALYST — zsh setup
# Loaded from ~/.zshrc:  source ~/.config/catalyst/catalyst.zsh
# Tools that are not installed are skipped quietly.

export PATH="$HOME/.local/bin:$PATH"

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# --- Completion ---
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # case-insensitive
zstyle ':completion:*' menu select

# --- Tools ---
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[zoxide] ))   && eval "$(zoxide init zsh)"     # z <dir>  /  zi (interactive)
(( $+commands[fzf] ))      && source <(fzf --zsh)           # Ctrl+R history, Ctrl+T files, Alt+C dirs

# fzf: uses the terminal palette, accent is the district colour
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=sharp --prompt='✦ ' --pointer='▸' --marker='▮' \
  --color=16,hl:red,hl+:bright-red,pointer:red,marker:red,prompt:red,spinner:red,info:bright-black,border:bright-black,header:blue"

# File colours: directories are routes in the accent colour, executables yellow
export LS_COLORS="di=1;31:ln=36:ex=1;32:so=35:pi=33:bd=34:cd=34:*.md=97:*.json=33:*.yml=33:*.yaml=33:*.toml=33:*.sh=32:*.py=33:*.js=33:*.ts=34:*.zip=91:*.tar=91:*.gz=91:*.jpg=95:*.png=95:*.pdf=91"

# --- Aliases ---
if (( $+commands[lsd] )); then
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -la'
  alias lt='lsd --tree --depth 2'
fi
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
  export BAT_THEME="ansi"
fi

# --- ✦ Catalyst ---
# Unknown command: route blocked
command_not_found_handler() {
  print -u2 -- "\e[31m✦ ROUTE BLOCKED\e[0m \e[90m—\e[0m '$1' \e[90mnot found on the grid\e[0m"
  return 127
}

# Switch theme: theme <district> | random | glass  (districts: theme list)
theme() {
  [[ -z ${CATALYST_SLUGS} ]] && source ~/.config/catalyst/district.zsh
  local slug=$1 profile
  case $slug in
    list) for slug in $CATALYST_SLUGS; do print -- "  \e[38;2;${CATALYST_RGB[$slug]}m✦\e[0m $slug  \e[90m${CATALYST_TAG[$slug]}\e[0m"; done; return ;;
    ""|random) slug=${CATALYST_SLUGS[$(( RANDOM % ${#CATALYST_SLUGS} + 1 ))]} ;|
    glass) profile="City of Glass" ;;
  esac
  if [[ -z $profile ]]; then
    profile=${CATALYST_PROFILE[$slug]}
    [[ -z $profile ]] && { print "unknown district: $slug (see: theme list)"; return 1 }
    export CATALYST_DISTRICT=$slug
  fi
  catalyst_apply_profile "$profile" && print -- "\e[31m✦\e[0m $profile"
}

# New tab: random district + greeting (skipped in Claude Code's own shells)
if [[ -o interactive && -z $CLAUDECODE ]]; then
  source ~/.config/catalyst/district.zsh
  source ~/.config/catalyst/greeting.zsh
fi

# --- Plugins (syntax-highlighting must come last) ---
if [[ -r ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi
if [[ -r ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_STYLES[command]='fg=red,bold'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=red,bold'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=red,bold'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=bright-black,underline'
  ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=bright-red,italic'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=red'
fi

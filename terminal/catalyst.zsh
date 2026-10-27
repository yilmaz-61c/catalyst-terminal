# ◆ CATALYST — zsh ayarları
# ~/.zshrc içinden yüklenir:  source ~/.config/catalyst/catalyst.zsh
# Kurulu olmayan araçlar sessizce atlanır.

export PATH="$HOME/.local/bin:$PATH"

# --- Geçmiş ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# --- Tamamlama ---
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # büyük/küçük harf duyarsız
zstyle ':completion:*' menu select

# --- Araçlar ---
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[zoxide] ))   && eval "$(zoxide init zsh)"     # z <klasör>  /  zi (interaktif)
(( $+commands[fzf] ))      && source <(fzf --zsh)           # Ctrl+R geçmiş, Ctrl+T dosya, Alt+C klasör

# fzf: terminal paletini kullanır, vurgu rengi bölgenin rengi
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=sharp --prompt='◆ ' --pointer='▸' --marker='▮' \
  --color=16,hl:red,hl+:bright-red,pointer:red,marker:red,prompt:red,spinner:red,info:bright-black,border:bright-black,header:blue"

# Dosya renkleri: klasörler vurgu renginde rota, çalıştırılabilirler sarı
export LS_COLORS="di=1;31:ln=36:ex=1;32:so=35:pi=33:bd=34:cd=34:*.md=97:*.json=33:*.yml=33:*.yaml=33:*.toml=33:*.sh=32:*.py=33:*.js=33:*.ts=34:*.zip=91:*.tar=91:*.gz=91:*.jpg=95:*.png=95:*.pdf=91"

# --- Kısayollar ---
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

# --- ◆ Catalyst ---
# Bulunamayan komut: rota kapalı
command_not_found_handler() {
  print -u2 -- "\e[31m◆ ROUTE BLOCKED\e[0m \e[90m—\e[0m '$1' \e[90mgrid üzerinde bulunamadı\e[0m"
  return 127
}

# Tema değiştirme: theme <bölge> | random | glass  (bölgeler: theme list)
theme() {
  [[ -z ${CATALYST_SLUGS} ]] && source ~/.config/catalyst/district.zsh
  local slug=$1 profile
  case $slug in
    list) for slug in $CATALYST_SLUGS; do print -- "  \e[38;2;${CATALYST_RGB[$slug]}m◆\e[0m $slug  \e[90m${CATALYST_TAG[$slug]}\e[0m"; done; return ;;
    ""|random) slug=${CATALYST_SLUGS[$(( RANDOM % ${#CATALYST_SLUGS} + 1 ))]} ;|
    glass) profile="City of Glass" ;;
  esac
  if [[ -z $profile ]]; then
    profile=${CATALYST_PROFILE[$slug]}
    [[ -z $profile ]] && { print "bilinmeyen bölge: $slug (theme list)"; return 1 }
    export CATALYST_DISTRICT=$slug
  fi
  catalyst_apply_profile "$profile" && print -- "\e[31m◆\e[0m $profile"
}

# Yeni sekme: rastgele bölge + açılış ekranı (Claude'un kendi kabuklarında çalışmaz)
if [[ -o interactive && -z $CLAUDECODE ]]; then
  source ~/.config/catalyst/district.zsh
  source ~/.config/catalyst/greeting.zsh
fi

# --- Eklentiler (syntax-highlighting en sonda olmalı) ---
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

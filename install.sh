#!/bin/zsh
# ✦ CATALYST — installer
# Installs the Terminal.app profiles, zsh setup, Claude Code themes and the HUD.
# Existing files are backed up first (*.catalyst-backup).
set -e
cd "${0:A:h}"

R=$'\e[31m' D=$'\e[90m' X=$'\e[0m'
step() { print -- "${R}✦${X} $1" }
backup() { [[ -e $1 && ! -e $1.catalyst-backup ]] && cp -R "$1" "$1.catalyst-backup" || true }

# --- Requirements ---
missing=()
for c in jq starship lsd bat fzf zoxide; do (( $+commands[$c] )) || missing+=($c); done
if (( ${#missing} )); then
  print -- "${D}Missing tools (see the README for links): ${missing}${X}"
  (( $+commands[jq] )) || { print "jq is needed to merge the Claude Code settings. Install jq first."; exit 1 }
fi

# --- Terminal and shell files ---
step "Copying shell setup to ~/.config/catalyst"
mkdir -p ~/.config/catalyst/profiles ~/.config/lsd
cp terminal/{catalyst.zsh,district.zsh,greeting.zsh,districts.json,districts.tsv,build-districts.py,profile.swift} ~/.config/catalyst/
cp terminal/profiles/*.terminal ~/.config/catalyst/profiles/
backup ~/.config/starship.toml; cp terminal/starship.toml ~/.config/starship.toml
backup ~/.config/lsd/config.yaml; backup ~/.config/lsd/colors.yaml
cp terminal/lsd/*.yaml ~/.config/lsd/

if ! grep -q 'catalyst/catalyst.zsh' ~/.zshrc 2>/dev/null; then
  step "Adding the Catalyst line to ~/.zshrc"
  backup ~/.zshrc
  print -- '\n# ✦ Catalyst\nsource ~/.config/catalyst/catalyst.zsh' >> ~/.zshrc
fi

# --- zsh plugins ---
mkdir -p ~/.zsh
[[ -d ~/.zsh/zsh-autosuggestions ]] || git clone -q --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
[[ -d ~/.zsh/zsh-syntax-highlighting ]] || git clone -q --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

# --- Terminal.app profiles ---
if [[ $OSTYPE == darwin* ]]; then
  step "Importing Terminal.app profiles"
  before=$(osascript -e 'tell application "Terminal" to return id of every window')
  while IFS='|' read -r slug name title rgb tag; do
    osascript -e "tell application \"Terminal\" to return exists settings set \"$title\"" | grep -q true && continue
    open ~/.config/catalyst/profiles/$slug.terminal; sleep 0.8
    osascript -e "tell application \"Terminal\" to set name of settings set \"$slug\" to \"$title\"" >/dev/null 2>&1 || true
  done < ~/.config/catalyst/districts.tsv
  if ! osascript -e 'tell application "Terminal" to return exists settings set "City of Glass"' | grep -q true; then
    open ~/.config/catalyst/profiles/city-of-glass.terminal; sleep 0.8
    osascript -e 'tell application "Terminal" to set name of settings set "city-of-glass" to "City of Glass"' >/dev/null 2>&1 || true
  fi
  sleep 1
  # Close the windows the import opened (windows open before are left alone)
  osascript -e "set keep to {$before}
    tell application \"Terminal\"
      set extra to {}
      repeat with w in windows
        if keep does not contain (id of w) then set end of extra to (id of w)
      end repeat
      repeat with i in extra
        try
          close (first window whose id is i) saving no
        end try
      end repeat
      set s to settings set \"Catalyst · Downtown\"
      set default settings to s
      set startup settings to s
    end tell" >/dev/null 2>&1 || true
fi

# --- Claude Code ---
step "Installing Claude Code themes and the HUD"
mkdir -p ~/.claude/themes ~/.claude/catalyst
cp claude/themes/*.json ~/.claude/themes/
cp claude/statusline.sh ~/.claude/catalyst/statusline.sh && chmod +x ~/.claude/catalyst/statusline.sh
[[ -f ~/.claude/settings.json ]] || print '{}' > ~/.claude/settings.json
backup ~/.claude/settings.json
jq -s '.[0] * .[1]' ~/.claude/settings.json claude/settings.json > ~/.claude/settings.json.tmp
mv ~/.claude/settings.json.tmp ~/.claude/settings.json

print
step "Done. Open a new tab (⌘T)."
print -- "${D}  For the Claude Code mod, inside Claude:  /plugin install catalyst-runner --marketplace yilmaz-61c/catalyst-terminal${X}"

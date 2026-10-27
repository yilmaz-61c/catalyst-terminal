#!/bin/zsh
# ◆ CATALYST HUD — Claude Code status line
input=$(cat)
j() { print -r -- "$input" | jq -r "$1 // empty" 2>/dev/null }

model=$(j '.model.display_name')
dir=$(j '.workspace.current_dir')
sid=$(j '.session_id')
pct=$(j '.context_window.used_percentage')

R=$'\e[38;2;232;50;44m' RB=$'\e[48;2;232;50;44m\e[38;2;255;255;255m\e[1m'
W=$'\e[38;2;228;234;240m' D=$'\e[38;2;107;122;140m' B=$'\e[38;2;61;123;224m'
G=$'\e[38;2;255;214;10m' Y=$'\e[38;2;255;138;61m' X=$'\e[0m'

# District: the tab's (CATALYST_DISTRICT), else read from the active Claude theme
slug=$CATALYST_DISTRICT
if [[ -z $slug ]]; then
  t=$(jq -r '.theme // empty' ~/.claude/settings.json 2>/dev/null)
  [[ $t == custom:catalyst-* ]] && slug=${t#custom:catalyst-}
fi
district="DOWNTOWN"
if [[ -n $slug ]] && line=$(grep "^$slug|" ~/.config/catalyst/districts.tsv 2>/dev/null); then
  parts=(${(s:|:)line})
  district=$parts[2]
  R=$'\e[38;2;'"$parts[4]"'m'
  RB=$'\e[48;2;'"$parts[4]"$'m\e[38;2;255;255;255m\e[1m'
fi

out="${RB} ◆ RUNNER ${X}${R}${X} ${R}${district}${X}"
[[ -n $model ]] && out+=" ${R}╱${X} ${W}${model}${X}"
if [[ -n $dir ]]; then
  short=${dir/#$HOME/\~}
  out+=" ${R}╱${X} ${W}${short:t}${X}"
  branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)
  [[ -n $branch ]] && out+=" ${B} ${branch}${X}"
fi
if [[ -n $pct ]]; then
  p=${pct%.*}; filled=$(( (p + 5) / 10 )); bar=""
  for i in {1..10}; do (( i <= filled )) && bar+="▮" || bar+="▯"; done
  if (( p < 50 )); then col=$G; elif (( p < 80 )); then col=$Y; else col=$R; fi
  out+=" ${R}╱ GRID${X} ${col}${bar} ${p}%${X}"
fi
print -r -- "$out"

# --- Line 2: plan usage (Pro/Max only, arrives after the first response) ---
bar10() { local p=$1 f=$(( ($1 + 5) / 10 )) b="" i; for i in {1..10}; do (( i <= f )) && b+="▮" || b+="▯"; done; print -r -- $b }
pcol() { (( $1 < 50 )) && print -r -- $G || { (( $1 < 80 )) && print -r -- $Y || print -r -- $R } }
left() { # time left until the window resets
  local s=$(( $1 - EPOCHSECONDS ))
  (( s <= 0 )) && { print "now"; return }
  local d=$(( s / 86400 )) h=$(( s % 86400 / 3600 )) m=$(( s % 3600 / 60 ))
  if (( d > 0 )); then print "${d}d ${h}h"; elif (( h > 0 )); then print "${h}h ${m}m"; else print "${m}m"; fi
}
zmodload zsh/datetime
h5=$(j '.rate_limits.five_hour.used_percentage'); h5r=$(j '.rate_limits.five_hour.resets_at')
d7=$(j '.rate_limits.seven_day.used_percentage'); d7r=$(j '.rate_limits.seven_day.resets_at')
if [[ -n $h5 || -n $d7 ]]; then
  line="${RB} ◆ PLAN   ${X}${R}${X}"
  if [[ -n $h5 ]]; then
    p=${h5%.*}; c=$(pcol $p)
    line+=" ${R}5 HOURS${X} ${c}$(bar10 $p) ${p}%${X}"
    [[ -n $h5r ]] && line+=" ${D}⟳ $(left ${h5r%.*})${X}"
  fi
  if [[ -n $d7 ]]; then
    p=${d7%.*}; c=$(pcol $p)
    [[ -n $h5 ]] && line+=" ${R}╱${X}"
    line+=" ${R}WEEK${X} ${c}$(bar10 $p) ${p}%${X}"
    [[ -n $d7r ]] && line+=" ${D}⟳ $(left ${d7r%.*})${X}"
  fi
  print -r -- "$line"
fi

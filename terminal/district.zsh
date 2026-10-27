# ◆ Bölge seçimi: her yeni sekme rastgele bir bölge alır.
# CATALYST_DISTRICT dışa aktarılır, böylece bu sekmede açılan Claude da aynı bölgeyi kullanır.
typeset -gA CATALYST_NAME CATALYST_PROFILE CATALYST_RGB CATALYST_TAG
typeset -ga CATALYST_SLUGS
() {
  local slug name title rgb tag
  while IFS='|' read -r slug name title rgb tag; do
    CATALYST_SLUGS+=($slug); CATALYST_NAME[$slug]=$name; CATALYST_PROFILE[$slug]=$title
    CATALYST_RGB[$slug]=$rgb; CATALYST_TAG[$slug]=$tag
  done < ~/.config/catalyst/districts.tsv
}

# Bu sekmeyi (tty'sine göre) bir profile geçirir
catalyst_apply_profile() {
  local profile=$1 tty=$TTY
  [[ $TERM_PROGRAM == Apple_Terminal && -n $tty ]] || return
  osascript -e "tell application \"Terminal\"
    repeat with w in windows
      repeat with t in tabs of w
        if tty of t is \"$tty\" then set current settings of t to settings set \"$profile\"
      end repeat
    end repeat
  end tell" >/dev/null 2>&1
}

if [[ -z $CATALYST_DISTRICT || -z ${CATALYST_NAME[$CATALYST_DISTRICT]} ]]; then
  export CATALYST_DISTRICT=${CATALYST_SLUGS[$(( RANDOM % ${#CATALYST_SLUGS} + 1 ))]}
  ( catalyst_apply_profile "${CATALYST_PROFILE[$CATALYST_DISTRICT]}" & ) 2>/dev/null
fi

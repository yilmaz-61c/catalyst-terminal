# ◆ RUNNER NETWORK — yeni oturum açılış ekranı
() {
  local R=$'\e[31m' W=$'\e[97m' D=$'\e[90m' B=$'\e[34m' Y=$'\e[33m' G=$'\e[32m' X=$'\e[0m'
  local RB=$'\e[41;97;1m' BOLD=$'\e[1m'
  local district=${CATALYST_NAME[$CATALYST_DISTRICT]:-DOWNTOWN}
  local tagline=${CATALYST_TAG[$CATALYST_DISTRICT]}
  # KSEC = işlemci yükü: tüm süreçlerin CPU payı / çekirdek sayısı
  local cpu=$(ps -A -o %cpu= | awk -v n=$(sysctl -n hw.ncpu) '{s+=$1} END {v=s/n; if (v>100) v=100; printf "%d", v}')
  local level=$(( cpu < 20 ? 1 : cpu < 40 ? 2 : cpu < 60 ? 3 : cpu < 80 ? 4 : 5 )) bar="" i
  for i in {1..5}; do (( i <= level )) && bar+="▮" || bar+="▯"; done

  # Konum: IP'den (ipinfo.io), 6 saat önbellekli; yenileme arka planda yapılır
  local cache=~/.cache/catalyst/location loc=""
  _catalyst_fetch_loc() {
    mkdir -p ${cache:h}
    curl -fsS -m 3 https://ipinfo.io/json 2>/dev/null \
      | jq -r 'select(.city) | "\(.city)|\(.country)"' > $cache.tmp 2>/dev/null \
      && [[ -s $cache.tmp ]] && mv $cache.tmp $cache || rm -f $cache.tmp
  }
  # Sabit konum: ~/.config/catalyst/location varsa IP'ye bakılmaz
  local fixed=~/.config/catalyst/location
  if [[ -r $fixed ]]; then loc=$(<$fixed)
  else
  [[ -r $cache ]] && loc=$(<$cache)
  if [[ -z $loc ]]; then
    _catalyst_fetch_loc; [[ -r $cache ]] && loc=$(<$cache)
  elif [[ -n $(find $cache -mmin +360 2>/dev/null) ]]; then
    ( _catalyst_fetch_loc & ) 2>/dev/null
  fi
  fi
  local -A countries=(TR TÜRKİYE DE GERMANY NL NETHERLANDS GB "UNITED KINGDOM" US USA FR FRANCE)
  local place="CITY OF GLASS // CASCADIA"
  if [[ $loc == *\|* ]]; then
    local city=${loc%%|*} cc=${loc##*|}
    place="${(U)city} // ${countries[$cc]:-$cc}"
  fi
  local status_txt status_col
  case $level in
    1|2) status_txt="ROUTES CLEAR"   status_col=$G ;;
    3)   status_txt="PATROL ACTIVE"  status_col=$Y ;;
    *)   status_txt="LOCKDOWN SWEEP" status_col=$R ;;
  esac
  status_txt+="  ${D}· CPU ${cpu}%"
  local tips=(
    "Momentum is everything. Don't stop on the rooftops."
    "The Grid sees everything. Stay off it."
    "Red marks the way. Trust it."
    "Every surface is a path if you look at it right."
    "KrugerSec sweeps $district at dusk. Take the high route."
    "Delivery first. Questions later."
    "Glass reflects. Runners don't."
    "Keep your hands free and your feet moving."
  )
  local tip=${tips[$(( RANDOM % ${#tips} + 1 ))]}
  local who=${(U)USER}

  print
  print -- "  ${RB} ◆ R U N N E R   N E T W O R K ${X}${R}${X}  ${D}${place}${X}"
  print
  print -- "  ${R}OPERATOR${X}   ${W}${BOLD}${who}${X}"
  print -- "  ${R}DISTRICT${X}   ${W}${BOLD}${district}${X}  ${D}${tagline}${X}"
  print -- "  ${R}GRID TIME${X}  ${W}$(date '+%H:%M')${X} ${D}·${X} ${W}$(date '+%d.%m.%Y')${X}"
  print -- "  ${R}KSEC${X}       ${status_col}${bar}${X}  ${status_col}${status_txt}${X}"
  print
  print -- "  ${R}▸${X} ${D}${tip}${X}"
  print
}

# ◆ catalyst-terminal

*Mirror's Edge Catalyst esintili macOS Terminal + Claude Code teması.*
*A Mirror's Edge Catalyst–inspired theme for macOS Terminal and Claude Code.*

> Hayran projesidir; EA veya DICE ile bağlantısı yoktur. Oyuna ait görsel ya da dosya içermez, renkler artbook'tan ölçülerek yeniden oluşturulmuştur.
> Fan project, not affiliated with EA or DICE. No game assets are included.

```
 ◆ R U N N E R   N E T W O R K   ISTANBUL // TÜRKİYE

 OPERATOR   RUNNER
 DISTRICT   KRUGER HQ  The Shard. Cold blue light, KrugerSec everywhere.
 GRID TIME  20:31 · 27.10.2026
 KSEC       ▮▮▯▯▯  ROUTES CLEAR  · CPU 27%

 ▸ Glass reflects. Runners don't.
```

## Neler var

**Altı bölge, her sekmede rastgele biri.** Yapı aynı, vurgu rengi bölgeye özgü:

| Bölge | Vurgu |
|---|---|
| ◆ Downtown | koşucu kırmızısı `#e8322c` |
| ◆ Anchor | neon pembe `#ff4f9a` |
| ◆ The View | okyanus camgöbeği `#1fc8e8` |
| ◆ Rezoning | şantiye turuncusu `#ff7a1a` |
| ◆ Kruger HQ | KrugerSec mavisi `#3d8bff` |
| ◆ OmniStat Tunnels | sodyum sarısı `#ffd60a` |

Ayrıca açık tema **City of Glass**.

**Terminal**
- Her bölge için Terminal.app profili (JetBrains Mono Nerd Font)
- Açılış ekranı: konum (IP'den, 6 saat önbellekli), saat, CPU yüküne bağlı **KSEC** devriye seviyesi
- Starship prompt, lsd / fzf / zsh renkleri, `◆ ROUTE BLOCKED` hata mesajı
- `theme list`, `theme <bölge>`, `theme random`, `theme glass`

**Claude Code**
- Her bölge için renk teması; Claude, açıldığı sekmenin bölgesini alır
- HUD durum satırı: bölge, model, klasör, git, bağlam (GRID) ve abonelik kullanımı (5 saat / haftalık, sıfırlanma süresiyle)
- Koşucu spinner kelimeleri (`Wallrunning…`, `Evading KrugerSec…`)
- **catalyst-runner** modu: çalışırken `◆ RUNNER VISION  MOMENTUM ▰▰▰▱▱` bandı, tur sonunda `Wallran for 12s  ◆ 48.2K token ▸ girdi · önbellek · çıktı`

## Kurulum

Gereken araçlar: [jq](https://jqlang.github.io/jq/), [starship](https://github.com/starship/starship), [lsd](https://github.com/lsd-rs/lsd), [bat](https://github.com/sharkdp/bat), [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide) ve [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases). Homebrew ile: `brew install jq starship lsd bat fzf zoxide && brew install --cask font-jetbrains-mono-nerd-font`

```sh
git clone https://github.com/yilmaz-61c/catalyst-terminal.git
cd catalyst-terminal
./install.sh
```

Betik var olan dosyaların yedeğini `*.catalyst-backup` olarak alır ve `~/.zshrc` sonuna tek satır ekler.

### Claude Code modu

Claude Code oturumunda:

```
/plugin install catalyst-runner --marketplace yilmaz-61c/catalyst-terminal
```

Kabuktan:

```sh
claude plugin install catalyst-runner --marketplace yilmaz-61c/catalyst-terminal
```

Masaüstü uygulamasında (`/plugin` çalışmaz): prompt kutusunun yanındaki **+** → **Plugins** → **Add marketplace** ile `yilmaz-61c/catalyst-terminal`, ardından **Add plugin**.

Soru gelince `y` ile marketplace'i ekleyin, ardından kapsamı seçin.

## Özelleştirme

- **Sabit konum:** `printf 'Izmir|TR\n' > ~/.config/catalyst/location` (silerseniz IP'den bulunur)
- **Renkler / yeni bölge:** `~/.config/catalyst/districts.json` dosyasını düzenleyip `python3 ~/.config/catalyst/build-districts.py` çalıştırın. Yeni bölge eklerseniz `plugins/catalyst-runner/hooks/register.tsx` içindeki `DISTRICTS` listesine de ekleyin.

## Gizlilik

Açılış ekranı konumu bulmak için 6 saatte bir `ipinfo.io` adresine istek atar (IP adresiniz bu servise gider). İstemezseniz yukarıdaki gibi sabit konum yazın.

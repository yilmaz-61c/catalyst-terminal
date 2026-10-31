# ✦ catalyst-terminal

A Mirror's Edge Catalyst–inspired theme for macOS Terminal and Claude Code.

> Fan project, not affiliated with EA or DICE. No game assets are included: the colours were measured from the official art book and rebuilt by hand.

```
 ✦ R U N N E R   N E T W O R K   ISTANBUL // TÜRKİYE

 OPERATOR   RUNNER
 DISTRICT   KRUGER HQ  The Shard. Cold blue light, KrugerSec everywhere.
 GRID TIME  20:31 · 27.10.2026
 KSEC       ▮▮▯▯▯  ROUTES CLEAR  · CPU 27%

 ▸ Glass reflects. Runners don't.
```

## What's inside

**Six districts, one picked at random for every new tab.** The layout stays the same; each district has its own accent colour:

| District | Accent |
|---|---|
| ✦ Downtown | runner red `#e8322c` |
| ✦ Anchor | neon pink `#ff4f9a` |
| ✦ The View | ocean cyan `#1fc8e8` |
| ✦ Rezoning | construction orange `#ff7a1a` |
| ✦ Kruger HQ | KrugerSec blue `#3d8bff` |
| ✦ OmniStat Tunnels | sodium yellow `#ffd60a` |

Plus a light theme, **City of Glass**.

**Terminal**
- A Terminal.app profile per district (JetBrains Mono Nerd Font)
- Greeting screen with your location (from your IP, cached for 6 hours), the time, and a **KSEC** patrol level driven by CPU load
- Starship prompt, matching lsd / fzf / zsh colours, and a `✦ ROUTE BLOCKED` message for unknown commands
- `theme list`, `theme <district>`, `theme random`, `theme glass`

**Claude Code**
- A colour theme per district; Claude Code picks up the district of the tab it was started in
- HUD status line: district, model, folder, git branch, context usage (GRID) and plan usage (5-hour and weekly windows, with time until reset)
- Runner spinner verbs (`Wallrunning…`, `Evading KrugerSec…`)
- The **catalyst-runner** mod: a `✦ RUNNER VISION  MOMENTUM ▰▰▰▱▱` band while Claude works, and a token line at the end of every turn: `Wallran for 12s  ✦ 48.2K token ▸ input · cache · output`

## Install

You need: [jq](https://jqlang.github.io/jq/), [starship](https://github.com/starship/starship), [lsd](https://github.com/lsd-rs/lsd), [bat](https://github.com/sharkdp/bat), [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide) and [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases). With Homebrew: `brew install jq starship lsd bat fzf zoxide && brew install --cask font-jetbrains-mono-nerd-font`

```sh
git clone https://github.com/yilmaz-61c/catalyst-terminal.git
cd catalyst-terminal
./install.sh
```

The script backs up every file it replaces as `*.catalyst-backup` and adds a single line to the end of `~/.zshrc`.

### The Claude Code mod

At the prompt of a Claude Code session:

```
/plugin install catalyst-runner --marketplace yilmaz-61c/catalyst-terminal
```

From a shell:

```sh
claude plugin install catalyst-runner --marketplace yilmaz-61c/catalyst-terminal
```

In the desktop app, where `/plugin` does not run: click **+** next to the prompt box, then **Plugins**, **Add marketplace** with `yilmaz-61c/catalyst-terminal`, then **Add plugin**.

When asked, answer `y` to add the marketplace, then pick a scope.

## Customising

- **Fixed location:** `printf 'Izmir|TR\n' > ~/.config/catalyst/location` (delete the file to go back to IP lookup)
- **Colours or a new district:** edit `~/.config/catalyst/districts.json`, then run `python3 ~/.config/catalyst/build-districts.py`. A new district also needs an entry in the `DISTRICTS` list in `plugins/catalyst-runner/hooks/register.tsx`.

## Privacy

To show your location, the greeting sends a request to `ipinfo.io` at most once every 6 hours, which shares your IP address with that service. To avoid it, set a fixed location as shown above.

## License

MIT

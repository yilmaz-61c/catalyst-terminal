#!/usr/bin/env python3
"""Builds every Catalyst district from districts.json: Terminal profiles,
Claude Code themes and the shell/status line colour table."""
import json, os, subprocess

HOME = os.path.expanduser("~")
CFG = f"{HOME}/.config/catalyst"
OUT = f"{CFG}/profiles"
districts = json.load(open(f"{CFG}/districts.json"))

def rgb(h): return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))
def hexc(t): return "#%02x%02x%02x" % tuple(max(0, min(255, round(v))) for v in t)
def mix(a, b, t):  # t=0 -> a, t=1 -> b
    a, b = rgb(a), rgb(b)
    return hexc(tuple(a[i] + (b[i] - a[i]) * t for i in range(3)))

# Shared runner palette; each district swaps the red slot for its accent
BASE = {
    "black": ["#141c27", "#4a5868"], "green": ["#ffd60a", "#ffe45c"], "yellow": ["#f2b316", "#ffd25a"],
    "blue": ["#3d7be0", "#6fa3ff"], "magenta": ["#9a7cf0", "#c0a8ff"], "cyan": ["#36c0e8", "#7fdcf5"],
    "white": ["#c3ccd6", "#ffffff"],
}
ORDER = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
os.makedirs(OUT, exist_ok=True)
os.makedirs(f"{HOME}/.claude/themes", exist_ok=True)
table = []

for slug, d in districts.items():
    bg, acc, br = d["bg"], d["accent"], d["bright"]
    slots = {**BASE, **d.get("slots", {}), "red": [acc, br]}
    slots["black"] = [mix(bg, "#ffffff", 0.06), mix(bg, "#8090a0", 0.45)]
    normal = [slots[k][0] for k in ORDER]
    bright = [slots[k][1] for k in ORDER]
    title = f"Catalyst · {d['name'].title().replace('Hq', 'HQ')}"
    subprocess.run(["swift", f"{CFG}/profile.swift", f"{OUT}/{slug}.terminal", title,
                    bg, "#e4eaf0", acc, mix(acc, bg, 0.62), *normal, *bright, acc], check=True)

    theme = {
        "name": f"◆ {d['name'].title().replace('Hq', 'HQ')}",
        "base": "dark",
        "overrides": {
            "claude": acc, "claudeShimmer": mix(br, "#ffffff", 0.3),
            "text": "#e4eaf0", "inverseText": "#ffffff",
            "inactive": mix(acc, "#8a8f99", 0.75), "inactiveShimmer": mix(acc, "#b0b4bc", 0.7),
            "subtle": mix(acc, bg, 0.8),
            "suggestion": br, "permission": acc, "permissionShimmer": mix(br, "#ffffff", 0.3),
            "remember": br, "success": "#ffd60a" if slug != "omnistat" else "#ff9d2e",
            "error": "#ff4a3d", "warning": "#ff8a3d", "warningShimmer": "#ffb27a", "merged": "#9a7cf0",
            "promptBorder": acc, "promptBorderShimmer": mix(br, "#ffffff", 0.3),
            "planMode": "#36c0e8" if slug != "the-view" else "#5ff0d0",
            "autoAccept": "#ffd60a" if slug != "omnistat" else "#ff9d2e",
            "bashBorder": br, "ide": "#3d7be0", "fastMode": br, "fastModeShimmer": mix(br, "#ffffff", 0.4),
            "diffAdded": "#2e2a0c", "diffRemoved": "#3a1416", "diffAddedDimmed": "#201e0e",
            "diffRemovedDimmed": "#241418", "diffAddedWord": "#5c5014", "diffRemovedWord": "#6a1e1e",
            "userMessageBackground": mix(acc, bg, 0.86), "userMessageBackgroundHover": mix(acc, bg, 0.8),
            "bashMessageBackgroundColor": mix(br, bg, 0.84), "memoryBackgroundColor": "#221f12",
            "selectionBg": mix(acc, bg, 0.6), "composerSidebarBackground": mix(bg, "#000000", 0.2),
            "rate_limit_fill": acc, "rate_limit_empty": mix(acc, bg, 0.8),
            "briefLabelYou": br, "briefLabelClaude": acc,
            "red_FOR_SUBAGENTS_ONLY": "#e8322c", "blue_FOR_SUBAGENTS_ONLY": "#3d7be0",
            "green_FOR_SUBAGENTS_ONLY": "#ffd60a", "yellow_FOR_SUBAGENTS_ONLY": "#f2b316",
            "purple_FOR_SUBAGENTS_ONLY": "#9a7cf0", "orange_FOR_SUBAGENTS_ONLY": "#f07a28",
            "pink_FOR_SUBAGENTS_ONLY": "#f06a9a", "cyan_FOR_SUBAGENTS_ONLY": "#36c0e8",
        },
    }
    json.dump(theme, open(f"{HOME}/.claude/themes/catalyst-{slug}.json", "w"), ensure_ascii=False, indent=2)
    r, g, b = rgb(acc)
    table.append(f"{slug}|{d['name']}|{title}|{r};{g};{b}|{d['tag']}")

open(f"{CFG}/districts.tsv", "w").write("\n".join(table) + "\n")
print("\n".join(table))

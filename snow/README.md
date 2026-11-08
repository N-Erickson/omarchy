# Omarchy Snow — Samsung Chromebook XE303C12

Omarchy adapted for the Samsung Chromebook XE303C12 (Exynos 5250, ARMv7, 2GB RAM).

## What's Different

The Snow variant replaces Hyprland with **Sway** (Mali-T604 only supports GLES 2.0, no Vulkan) and adapts every UI layer for the hardware:

| Component | Standard Omarchy | Snow |
|-----------|-----------------|------|
| Compositor | Hyprland | Sway 1.12 |
| Status bar | Quickshell | i3blocks |
| Tiling | Hyprland dwindle | autotiling (sway) |
| Browser | Chromium | Firefox (tuned) |
| GPU | Vulkan | GLES 2.0 / llvmpipe |
| RAM tuning | none | zram 2x, aggressive sysctl |
| Audio | PipeWire | PipeWire + ALSA MAX98095 routing |

## Hardware

- **SoC**: Samsung Exynos 5250 (dual Cortex-A15, ARMv7)
- **GPU**: Mali-T604 (GLES 2.0 only)
- **RAM**: 2GB DDR3L
- **Display**: 11.6" 1366x768
- **Audio**: MAX98095 codec (requires explicit mixer routing)
- **WiFi**: Marvell 88W8797 (mwifiex driver)
- **Boot**: Depthcharge (Ctrl+U for USB/SD boot in dev mode)

## File Layout

```
snow/
├── bin/                          # ~/.local/bin/ scripts
│   ├── omarchy-menu              # Main menu (Super+M)
│   ├── omarchy-theme-selector    # Theme picker (all 23 themes)
│   ├── omarchy-background-picker # Wallpaper picker (80+ backgrounds)
│   ├── omarchy-volume-tui        # Volume slider TUI
│   ├── omarchy-system-menu       # System info + controls
│   └── ...                       # 26 scripts total
├── config/
│   ├── sway/config               # Sway compositor config
│   ├── i3blocks/config           # Status bar config
│   └── foot/foot.ini             # Terminal config
├── lib/i3blocks/                 # Per-block click handlers
│   ├── volume                    # Click → volume TUI
│   ├── wifi                      # Click → nmtui
│   ├── memory                    # Click → btop
│   ├── browser                   # Click → firefox
│   └── ...                       # 10 blocks total
├── hooks/theme-set.d/            # Theme change hooks (sway, mako, swaylock)
├── install/helpers/              # Stubs for missing Chromium/Hyprland deps
├── default/themed/foot.ini.tpl   # Foot template with alpha support
├── systemd/                      # ALSA restore service
├── firefox/user.js               # Firefox ARM performance config
└── install-snow.sh               # One-shot installer
```

## Install

On a running Arch Linux ARM system with Omarchy base packages:

```bash
git clone https://github.com/N-Erickson/omarchy.git
cd omarchy
git checkout snow
sudo ./snow/install-snow.sh
```

## Key Bindings

| Key | Action |
|-----|--------|
| Super+Enter | Terminal (foot) |
| Super+M | Main menu |
| Super+D | App launcher (fuzzel) |
| Super+Q | Close window |
| Super+V | Volume (alsamixer) |
| Super+1-9 | Workspaces |
| Alt+Tab | Cycle windows |
| Bar clicks | Per-block actions |
| Right-click bar | Quick menu |

## Themes

All 23 Omarchy themes work: catppuccin, dracula, gruvbox, nord, tokyo-night, etc. Theme switching updates Sway borders, foot terminal, mako notifications, and swaylock.

## Known Limitations

- No Chromium/WebEngine — Qt WebEngine and Chromium have no armv7h builds
- Firefox is the only full browser; it's slow but functional with the tuning in `user.js`
- PipeWire can crash on this hardware — stale lock files at `/run/user/1001/pipewire-0.lock` need manual cleanup
- GPU acceleration is limited (GLES 2.0 only, no Vulkan)

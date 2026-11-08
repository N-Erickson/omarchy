#!/bin/bash
# Omarchy Snow — installer for Samsung Chromebook XE303C12 (Exynos 5250)
# Deploys Sway-based Omarchy on ARMv7 with i3blocks, autotiling, and all Snow adaptations
set -e

SNOW_DIR="$(cd "$(dirname "$0")" && pwd)"
OMARCHY_USER="${OMARCHY_USER:-omarchy}"
HOME_DIR="/home/$OMARCHY_USER"

echo "=== Omarchy Snow Installer ==="
echo "Target user: $OMARCHY_USER"
echo "Source: $SNOW_DIR"
echo ""

# Detect hardware
if [ -f /sys/firmware/devicetree/base/compatible ]; then
    COMPAT=$(cat /sys/firmware/devicetree/base/compatible 2>/dev/null | tr '\0' ',')
    if echo "$COMPAT" | grep -q "google,snow"; then
        echo "[✓] Samsung Chromebook XE303C12 (Snow) detected"
    else
        echo "[!] Not a Snow Chromebook — compatible: $COMPAT"
        echo "    Continuing anyway (Sway config is portable)"
    fi
else
    echo "[!] No device tree — not running on ARM?"
    echo "    Continuing anyway"
fi

# Install required packages
echo ""
echo "[1/8] Installing packages..."
PACKAGES=(
    sway swaylock swayidle swaybg foot fuzzel mako grim slurp
    wl-clipboard xdg-desktop-portal-wlr
    i3blocks autotiling
    pipewire pipewire-pulse pipewire-alsa wireplumber
    networkmanager iwd
    brightnessctl
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    firefox
    btop fastfetch imv mpv
    bat ripgrep fd eza git jq less man-db
    zoxide fzf starship tmux bash-completion
    wob
)

if command -v pacman &>/dev/null; then
    pacman -S --needed --noconfirm "${PACKAGES[@]}" 2>&1 | tail -5
else
    echo "[!] No pacman — skipping package install. Install these manually:"
    printf '  %s\n' "${PACKAGES[@]}"
fi

# Create user directories
echo ""
echo "[2/8] Setting up directories..."
mkdir -p "$HOME_DIR/.config/sway"
mkdir -p "$HOME_DIR/.config/i3blocks"
mkdir -p "$HOME_DIR/.config/foot"
mkdir -p "$HOME_DIR/.config/omarchy/hooks/theme-set.d"
mkdir -p "$HOME_DIR/.local/bin"
mkdir -p "$HOME_DIR/.local/lib/i3blocks"
mkdir -p "$HOME_DIR/.local/state/omarchy/current/theme"
mkdir -p "$HOME_DIR/.mozilla/firefox/omarchy.default-release"

# Deploy configs
echo ""
echo "[3/8] Deploying Sway config..."
cp "$SNOW_DIR/config/sway/config" "$HOME_DIR/.config/sway/config"

echo "[4/8] Deploying i3blocks config + scripts..."
cp "$SNOW_DIR/config/i3blocks/config" "$HOME_DIR/.config/i3blocks/config"
cp "$SNOW_DIR/lib/i3blocks/"* "$HOME_DIR/.local/lib/i3blocks/"
chmod +x "$HOME_DIR/.local/lib/i3blocks/"*

echo "[5/8] Deploying bin scripts..."
cp "$SNOW_DIR/bin/"* "$HOME_DIR/.local/bin/"
chmod +x "$HOME_DIR/.local/bin/"*

echo "[6/8] Deploying foot config + theme hooks..."
cp "$SNOW_DIR/config/foot/foot.ini" "$HOME_DIR/.config/foot/foot.ini"
cp "$SNOW_DIR/hooks/theme-set.d/"* "$HOME_DIR/.config/omarchy/hooks/theme-set.d/"
chmod +x "$HOME_DIR/.config/omarchy/hooks/theme-set.d/"*

# Deploy system-level files
echo ""
echo "[7/8] Deploying system files..."

# Browser policy stubs (no Chromium on ARM)
cp "$SNOW_DIR/install/helpers/browser-policy.sh" /usr/share/omarchy/install/helpers/browser-policy.sh
cp "$SNOW_DIR/install/helpers/omarchy-theme-set-browser-policy" /usr/share/omarchy/bin/omarchy-theme-set-browser-policy
chmod +x /usr/share/omarchy/bin/omarchy-theme-set-browser-policy

# Sway stub for hyprctl commands
cp "$SNOW_DIR/install/helpers/omarchy-restart-hyprctl" /usr/share/omarchy/bin/omarchy-restart-hyprctl
chmod +x /usr/share/omarchy/bin/omarchy-restart-hyprctl

# Foot template with alpha support
cp "$SNOW_DIR/default/themed/foot.ini.tpl" /usr/share/omarchy/default/themed/foot.ini.tpl

# ALSA restore service for MAX98095 codec
cp "$SNOW_DIR/systemd/alsa-restore-snow.service" /etc/systemd/system/alsa-restore-snow.service
systemctl daemon-reload
systemctl enable alsa-restore-snow.service 2>/dev/null || true

# Firefox performance tuning
echo "[8/8] Deploying Firefox config..."
cp "$SNOW_DIR/firefox/user.js" "$HOME_DIR/.mozilla/firefox/omarchy.default-release/user.js"

# Fix ownership
chown -R "$OMARCHY_USER:$OMARCHY_USER" "$HOME_DIR"

# ALSA mixer routing for MAX98095
echo ""
echo "=== Configuring audio (MAX98095 codec) ==="
if aplay -l 2>/dev/null | grep -q MAX98095; then
    amixer -c 0 sset "Left Speaker Mixer Left DAC1" on 2>/dev/null || true
    amixer -c 0 sset "Right Speaker Mixer Right DAC1" on 2>/dev/null || true
    amixer -c 0 sset "Speaker" 100% 2>/dev/null || true
    alsactl store 2>/dev/null || true
    echo "[✓] MAX98095 mixer routed to speakers"
else
    echo "[!] MAX98095 not detected — skipping ALSA mixer config"
fi

# Performance tuning for 2GB RAM
echo ""
echo "=== Applying Snow performance tuning ==="

# zram
if [ ! -f /etc/systemd/zram-generator.conf ]; then
    cat > /etc/systemd/zram-generator.conf << 'ZRAM'
[zram0]
zram-size = ram * 2
compression-algorithm = zstd
ZRAM
    echo "[✓] zram configured (2x RAM, zstd)"
fi

# sysctl tuning
if [ ! -f /etc/sysctl.d/99-snow.conf ]; then
    cat > /etc/sysctl.d/99-snow.conf << 'SYSCTL'
vm.swappiness = 150
vm.dirty_ratio = 5
vm.dirty_background_ratio = 2
vm.vfs_cache_pressure = 200
SYSCTL
    sysctl --system >/dev/null 2>&1
    echo "[✓] sysctl tuned for low-memory ARM"
fi

echo ""
echo "=== Omarchy Snow installation complete ==="
echo ""
echo "What's installed:"
echo "  - Sway compositor with i3blocks status bar"
echo "  - Autotiling (dwindle layout)"
echo "  - 23 Omarchy themes with 80+ wallpapers"
echo "  - Full menu system (Super+M, right-click bar)"
echo "  - Volume TUI, theme selector, background picker"
echo "  - Firefox with ARM performance tuning"
echo "  - PipeWire audio with MAX98095 mixer routing"
echo "  - zram + sysctl tuning for 2GB RAM"
echo ""
echo "Start with: sway"

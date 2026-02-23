#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# SDDM Wallpaper and Wallust Colors Setter (silent, non-interactive)

set -euo pipefail

# Elevate to root if needed (non-interactive; exits silently if no cached credentials)
if [ "$(id -u)" -ne 0 ]; then
    exec sudo -n "$(readlink -f "$0")" "$@" 2>/dev/null || exit 0
fi

# Determine user home (handle sudo context)
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

# Paths
wallpaper_current="$USER_HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
wallpaper_modified="$USER_HOME/.config/hypr/wallpaper_effects/.wallpaper_modified"
rofi_wallust="$USER_HOME/.config/rofi/wallust/colors-rofi.rasi"
sddm_themes_dir="/usr/share/sddm/themes"
if [ ! -d "$sddm_themes_dir" ] && [ -d "/run/current-system/sw/share/sddm/themes" ]; then
    sddm_themes_dir="/run/current-system/sw/share/sddm/themes"
fi
sddm_simple="$sddm_themes_dir/simple_sddm_2"
sddm_theme_conf="$sddm_simple/theme.conf"

# Parse mode
mode="effects"
[ "${1:-}" = "--normal" ] && mode="normal"
[ "${1:-}" = "--effects" ] && mode="effects"

# Abort if SDDM is not running
if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active --quiet sddm || exit 0
elif ! pidof sddm >/dev/null 2>&1; then
    exit 0
fi

# Abort if required files are missing
[ -f "$rofi_wallust" ] || exit 1
[ -f "$sddm_theme_conf" ] || exit 0

# Abort on NixOS (read-only themes)
if hostnamectl 2>/dev/null | grep -q 'Operating System: NixOS'; then
    exit 0
fi

# Extract colors from rofi wallust config
extract_color() {
    grep -oP "$1:\s*\K#[A-Fa-f0-9]+" "$rofi_wallust" | head -n1
}

color0=$(extract_color "color1")
color1=$(extract_color "color0")
color7=$(extract_color "color14")
color10=$(extract_color "color10")
color12=$(extract_color "color12")
color13=$(extract_color "color13")

# Verify all colors extracted
for var in color0 color1 color7 color10 color12 color13; do
    [ -n "${!var}" ] || exit 1
done

# Select wallpaper source
if [ "$mode" = "normal" ]; then
    wallpaper_path="$wallpaper_current"
else
    wallpaper_path="$wallpaper_modified"
fi

# Update SDDM theme colors
sed -i "s/HeaderTextColor=\"#.*\"/HeaderTextColor=\"$color13\"/" "$sddm_theme_conf"
sed -i "s/DateTextColor=\"#.*\"/DateTextColor=\"$color13\"/" "$sddm_theme_conf"
sed -i "s/TimeTextColor=\"#.*\"/TimeTextColor=\"$color13\"/" "$sddm_theme_conf"
sed -i "s/DropdownSelectedBackgroundColor=\"#.*\"/DropdownSelectedBackgroundColor=\"$color13\"/" "$sddm_theme_conf"
sed -i "s/SystemButtonsIconsColor=\"#.*\"/SystemButtonsIconsColor=\"$color13\"/" "$sddm_theme_conf"
sed -i "s/SessionButtonTextColor=\"#.*\"/SessionButtonTextColor=\"$color13\"/" "$sddm_theme_conf"
sed -i "s/VirtualKeyboardButtonTextColor=\"#.*\"/VirtualKeyboardButtonTextColor=\"$color13\"/" "$sddm_theme_conf"
sed -i "s/HighlightBackgroundColor=\"#.*\"/HighlightBackgroundColor=\"$color12\"/" "$sddm_theme_conf"
sed -i "s/LoginFieldTextColor=\"#.*\"/LoginFieldTextColor=\"$color12\"/" "$sddm_theme_conf"
sed -i "s/PasswordFieldTextColor=\"#.*\"/PasswordFieldTextColor=\"$color12\"/" "$sddm_theme_conf"
sed -i "s/DropdownBackgroundColor=\"#.*\"/DropdownBackgroundColor=\"$color1\"/" "$sddm_theme_conf"
sed -i "s/HighlightTextColor=\"#.*\"/HighlightTextColor=\"$color10\"/" "$sddm_theme_conf"
sed -i "s/PlaceholderTextColor=\"#.*\"/PlaceholderTextColor=\"$color7\"/" "$sddm_theme_conf"
sed -i "s/UserIconColor=\"#.*\"/UserIconColor=\"$color7\"/" "$sddm_theme_conf"
sed -i "s/PasswordIconColor=\"#.*\"/PasswordIconColor=\"$color7\"/" "$sddm_theme_conf"

# Copy wallpaper to SDDM theme
if [ -f "${wallpaper_path:-}" ]; then
    cp -f "$wallpaper_path" "$sddm_simple/Backgrounds/default" 2>/dev/null || true
    [ -e "$sddm_simple/Backgrounds/default.jpg" ] && cp -f "$wallpaper_path" "$sddm_simple/Backgrounds/default.jpg"
    [ -e "$sddm_simple/Backgrounds/default.png" ] && cp -f "$wallpaper_path" "$sddm_simple/Backgrounds/default.png"
fi

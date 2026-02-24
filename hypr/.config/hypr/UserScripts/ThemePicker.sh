#!/usr/bin/env bash
# Theme Mode Picker - Toggle between Light/Dark mode and auto-rotation
# Super+Shift+W

set -euo pipefail

# Directories
THEMES_DIR="$HOME/.config/hypr/themes"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"
rofi_config="$HOME/.config/rofi/config-theme-picker.rasi"

# State files
MODE_FILE="$HOME/.cache/.theme_mode"
AUTO_ROTATE_FILE="$HOME/.cache/.theme_auto_rotate"
THEME_ROTATE_PID="$HOME/.cache/.theme_rotate.pid"

# swww transition config
FPS=60
TYPE="grow"
DURATION=2
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER --transition-pos 0.925,0.977"

# Get current mode
get_current_mode() {
  if [[ -f "$MODE_FILE" ]]; then
    cat "$MODE_FILE"
  else
    echo "Dark"
  fi
}

# Get auto-rotate status
get_auto_rotate() {
  if [[ -f "$AUTO_ROTATE_FILE" ]] && [[ "$(cat "$AUTO_ROTATE_FILE")" = "on" ]]; then
    echo "on"
  else
    echo "off"
  fi
}

# Set auto-rotate status
set_auto_rotate() {
  local status="$1"
  echo "$status" >"$AUTO_ROTATE_FILE"

  if [[ "$status" = "on" ]]; then
    # Start the rotation daemon
    "$UserScripts/ThemeRotate.sh" &
    echo $! >"$THEME_ROTATE_PID"
    notify-send -i "$HOME/.config/swaync/images/bell.png" "Auto-rotate" "Enabled - wallpapers change every 30 min"
  else
    # Stop the rotation daemon
    if [[ -f "$THEME_ROTATE_PID" ]]; then
      kill "$(cat "$THEME_ROTATE_PID")" 2>/dev/null || true
      rm -f "$THEME_ROTATE_PID"
    fi
    pkill -f "ThemeRotate.sh" 2>/dev/null || true
    notify-send -i "$HOME/.config/swaync/images/bell.png" "Auto-rotate" "Disabled"
  fi
}

# Apply theme with a random wallpaper from the theme's folder
apply_theme() {
  local theme="$1"
  local theme_dir="$THEMES_DIR/$theme"
  local preset_dir="$theme_dir/preset"
  local wallpapers_dir="$theme_dir/wallpapers"

  if [[ ! -d "$theme_dir" ]]; then
    notify-send -i "$HOME/.config/swaync/images/error.png" "Error" "Theme '$theme' not found"
    exit 1
  fi

  # Get a random wallpaper from the theme's wallpapers folder
  local wallpapers=()
  while IFS= read -r -d '' file; do
    wallpapers+=("$file")
  done < <(find -L "$wallpapers_dir" -type f \( \
    -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
    -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" \) -print0 2>/dev/null)

  if [[ ${#wallpapers[@]} -eq 0 ]]; then
    notify-send -i "$HOME/.config/swaync/images/error.png" "Error" "No wallpapers in $wallpapers_dir"
    exit 1
  fi

  local wallpaper="${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}"

  # Apply mode from preset
  if [[ -f "$preset_dir/mode" ]]; then
    local target_mode=$(cat "$preset_dir/mode")
    local current_mode=""
    [[ -f "$MODE_FILE" ]] && current_mode=$(cat "$MODE_FILE")

    if [[ "$target_mode" != "$current_mode" ]]; then
      _apply_mode "$target_mode"
    fi
  fi

  # Apply palette from preset
  if [[ -f "$preset_dir/palette" ]]; then
    local saved_palette=$(cat "$preset_dir/palette")
    sed -i "s/^palette = .*/palette = \"$saved_palette\"/" "$HOME/.config/wallust/wallust.toml"
  fi

  # Apply waybar symlinks from preset
  if [[ -f "$preset_dir/waybar_config" ]]; then
    ln -sf "$(cat "$preset_dir/waybar_config")" "$HOME/.config/waybar/config"
  fi
  if [[ -f "$preset_dir/waybar_style" ]]; then
    ln -sf "$(cat "$preset_dir/waybar_style")" "$HOME/.config/waybar/style.css"
  fi

  # Apply wallpaper following JaKooLit's methodology
  local focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
  swww query || swww-daemon --format xrgb
  swww img -o "$focused_monitor" "$wallpaper" $SWWW_PARAMS

  "$SCRIPTSDIR/WallustSwww.sh" "$wallpaper"
  sleep 2
  "$UserScripts/Refresh.sh"
  sleep 1
  "$UserScripts/sddm_wallpaper.sh" --normal

  # Signal kitty to reload
  if pidof kitty >/dev/null; then
    for pid in $(pidof kitty); do kill -SIGUSR1 "$pid" 2>/dev/null || true; done
  fi

  # Save current mode
  if [[ -f "$preset_dir/mode" ]]; then
    cat "$preset_dir/mode" >"$MODE_FILE"
  fi

  notify-send -i "$HOME/.config/swaync/images/bell.png" "Theme" "Switched to $theme mode"
}

# Apply light/dark mode to desktop environment
_apply_mode() {
  local mode="$1"

  local swaync_style="$HOME/.config/swaync/style.css"
  local ags_style="$HOME/.config/ags/user/style.css"
  local wallust_rofi="$HOME/.config/rofi/wallust/colors-rofi.rasi"
  local qt5ct_conf="$HOME/.config/qt5ct/qt5ct.conf"
  local qt6ct_conf="$HOME/.config/qt6ct/qt6ct.conf"

  if [[ "$mode" = "Light" ]]; then
    sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(255, 255, 255, 0.9);/' "$swaync_style" 2>/dev/null || true

    if command -v ags &>/dev/null && [[ -f "$ags_style" ]]; then
      sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(255, 255, 255, 0.4);/' "$ags_style"
      sed -i '/@define-color text-color/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(0, 0, 0, 0.7);/' "$ags_style"
      sed -i '/@define-color noti-bg-alt/s/#.*;/#F0F0F0;/' "$ags_style"
    fi

    # Light mode: white background, dark text
    sed -i '/^background:/s/.*/background: rgba(255,255,255,0.9);/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^foreground:/s/.*/foreground: #1a1a2e;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^normal-foreground:/s/.*/normal-foreground: #1a1a2e;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^active-foreground:/s/.*/active-foreground: #1a1a2e;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^urgent-foreground:/s/.*/urgent-foreground: #1a1a2e;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^selected-normal-foreground:/s/.*/selected-normal-foreground: #ffffff;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^selected-active-foreground:/s/.*/selected-active-foreground: #ffffff;/' "$wallust_rofi" 2>/dev/null || true

    [[ -f "$qt5ct_conf" ]] && sed -i "s|^color_scheme_path=.*$|color_scheme_path=$HOME/.config/qt5ct/colors/Catppuccin-Latte.conf|" "$qt5ct_conf"
    [[ -f "$qt6ct_conf" ]] && sed -i "s|^color_scheme_path=.*$|color_scheme_path=$HOME/.config/qt6ct/colors/Catppuccin-Latte.conf|" "$qt6ct_conf"

    if [[ -d /usr/share/Kvantum/catppuccin-latte-blue ]] || [[ -d "$HOME/.config/Kvantum/catppuccin-latte-blue" ]]; then
      kvantummanager --set catppuccin-latte-blue 2>/dev/null || true
    fi

    gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null || true

    # Kitty: swap to light ANSI colors
    ln -sf ansi-light.conf "$HOME/.config/kitty/kitty-themes/ansi-colors.conf"
  else
    sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(0, 0, 0, 0.8);/' "$swaync_style" 2>/dev/null || true

    if command -v ags &>/dev/null && [[ -f "$ags_style" ]]; then
      sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(0, 0, 0, 0.4);/' "$ags_style"
      sed -i '/@define-color text-color/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(255, 255, 255, 0.7);/' "$ags_style"
      sed -i '/@define-color noti-bg-alt/s/#.*;/#111111;/' "$ags_style"
    fi

    # Dark mode: dark background, light text
    sed -i '/^background:/s/.*/background: rgba(0,0,0,0.7);/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^foreground:/s/.*/foreground: #dfe3f1;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^normal-foreground:/s/.*/normal-foreground: #dfe3f1;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^active-foreground:/s/.*/active-foreground: #dfe3f1;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^urgent-foreground:/s/.*/urgent-foreground: #dfe3f1;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^selected-normal-foreground:/s/.*/selected-normal-foreground: #1a1a2e;/' "$wallust_rofi" 2>/dev/null || true
    sed -i '/^selected-active-foreground:/s/.*/selected-active-foreground: #1a1a2e;/' "$wallust_rofi" 2>/dev/null || true

    [[ -f "$qt5ct_conf" ]] && sed -i "s|^color_scheme_path=.*$|color_scheme_path=$HOME/.config/qt5ct/colors/Catppuccin-Mocha.conf|" "$qt5ct_conf"
    [[ -f "$qt6ct_conf" ]] && sed -i "s|^color_scheme_path=.*$|color_scheme_path=$HOME/.config/qt6ct/colors/Catppuccin-Mocha.conf|" "$qt6ct_conf"

    if [[ -d /usr/share/Kvantum/catppuccin-mocha-blue ]] || [[ -d "$HOME/.config/Kvantum/catppuccin-mocha-blue" ]]; then
      kvantummanager --set catppuccin-mocha-blue 2>/dev/null || true
    fi

    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true

    # Kitty: swap to dark ANSI colors
    ln -sf ansi-dark.conf "$HOME/.config/kitty/kitty-themes/ansi-colors.conf"
  fi

  echo "$mode" >"$MODE_FILE"
}

# Build the menu
build_menu() {
  local current_mode=$(get_current_mode)
  local auto_rotate=$(get_auto_rotate)

  # Mode options with marker for current
  if [[ "$current_mode" = "Light" ]]; then
    echo "[SELECTED] Light Mode"
    echo "Dark Mode"
  else
    echo "Light Mode"
    echo "[SELECTED] Dark Mode"
  fi

  echo "" # Separator

  # Auto-rotate toggle
  if [[ "$auto_rotate" = "on" ]]; then
    echo "Auto-rotate: ON"
  else
    echo "Auto-rotate: OFF"
  fi
}

# Main function
main() {
  # Handle --apply flag for non-interactive use (from keyd/fish functions)
  if [[ "${1:-}" = "--apply" ]]; then
    local theme="${2:-}"
    if [[ -n "$theme" ]]; then
      apply_theme "$theme"
      exit 0
    else
      echo "Usage: ThemePicker.sh --apply <light|dark>"
      exit 1
    fi
  fi

  # Handle --toggle-auto flag
  if [[ "${1:-}" = "--toggle-auto" ]]; then
    local current=$(get_auto_rotate)
    if [[ "$current" = "on" ]]; then
      set_auto_rotate "off"
    else
      set_auto_rotate "on"
    fi
    exit 0
  fi

  # Kill existing rofi
  if pgrep -x "rofi" >/dev/null; then
    pkill rofi
  fi

  local current_mode=$(get_current_mode)
  local auto_rotate=$(get_auto_rotate)

  # Build message showing current state
  local msg="Mode: $current_mode | Auto-rotate: $auto_rotate"

  local choice=$(build_menu | rofi -i -dmenu -config "$rofi_config" -mesg "$msg")

  [[ -z "$choice" ]] && exit 0

  # Strip leading spaces
  choice=$(echo "$choice" | sed 's/^[[:space:]]*//')

  case "$choice" in
  "Light Mode")
    apply_theme "light"
    ;;
  "Dark Mode")
    apply_theme "dark"
    ;;
  *"Auto-rotate: ON"*)
    set_auto_rotate "off"
    ;;
  *"Auto-rotate: OFF"*)
    set_auto_rotate "on"
    ;;
  esac
}

main "$@"

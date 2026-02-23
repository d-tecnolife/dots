#!/usr/bin/env bash
# Theme Rotate - Background daemon for automatic wallpaper rotation
# Rotates wallpapers every 30 minutes based on current theme mode

set -euo pipefail

# Directories
THEMES_DIR="$HOME/.config/hypr/themes"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"

# State files
MODE_FILE="$HOME/.cache/.theme_mode"
AUTO_ROTATE_FILE="$HOME/.cache/.theme_auto_rotate"
THEME_ROTATE_PID="$HOME/.cache/.theme_rotate.pid"
LAST_WALLPAPER_FILE="$HOME/.cache/.theme_last_wallpaper"

# Rotation interval in seconds (30 minutes)
INTERVAL=$((30 * 60))

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

# Check if auto-rotate is enabled
is_auto_rotate_enabled() {
    [[ -f "$AUTO_ROTATE_FILE" ]] && [[ "$(cat "$AUTO_ROTATE_FILE")" = "on" ]]
}

# Get random wallpaper from theme folder (avoiding last wallpaper if possible)
get_random_wallpaper() {
    local theme="$1"
    local wallpapers_dir="$THEMES_DIR/$theme/wallpapers"
    local last_wallpaper=""

    [[ -f "$LAST_WALLPAPER_FILE" ]] && last_wallpaper=$(cat "$LAST_WALLPAPER_FILE")

    # Get all wallpapers
    local wallpapers=()
    while IFS= read -r -d '' file; do
        wallpapers+=("$file")
    done < <(find -L "$wallpapers_dir" -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
        -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" \) -print0 2>/dev/null)

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        echo ""
        return
    fi

    # If only one wallpaper, return it
    if [[ ${#wallpapers[@]} -eq 1 ]]; then
        echo "${wallpapers[0]}"
        return
    fi

    # Filter out last wallpaper and pick random from remaining
    local candidates=()
    for wp in "${wallpapers[@]}"; do
        if [[ "$wp" != "$last_wallpaper" ]]; then
            candidates+=("$wp")
        fi
    done

    # If all wallpapers were the last one (shouldn't happen), just pick random
    if [[ ${#candidates[@]} -eq 0 ]]; then
        candidates=("${wallpapers[@]}")
    fi

    echo "${candidates[$((RANDOM % ${#candidates[@]}))]}"
}

# Rotate wallpaper for current theme
rotate_wallpaper() {
    local mode=$(get_current_mode)
    local theme

    # Map mode to theme folder name
    if [[ "$mode" = "Light" ]]; then
        theme="light"
    else
        theme="dark"
    fi

    local wallpaper=$(get_random_wallpaper "$theme")

    if [[ -z "$wallpaper" ]]; then
        echo "No wallpapers found for theme: $theme"
        return
    fi

    echo "Rotating to: $(basename "$wallpaper")"

    # Get focused monitor
    local focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' 2>/dev/null || echo "")

    # Apply wallpaper
    swww query || swww-daemon --format xrgb
    swww img -o "$focused_monitor" "$wallpaper" $SWWW_PARAMS

    # Run wallust and refresh
    "$SCRIPTSDIR/WallustSwww.sh" "$wallpaper"
    sleep 2
    "$UserScripts/Refresh.sh"

    # Save last wallpaper
    echo "$wallpaper" > "$LAST_WALLPAPER_FILE"

    notify-send -i "$HOME/.config/swaync/images/bell.png" "Theme Rotate" "New wallpaper: $(basename "$wallpaper")"
}

# Cleanup function
cleanup() {
    rm -f "$THEME_ROTATE_PID"
    exit 0
}

# Main loop
main() {
    # Save PID
    echo $$ > "$THEME_ROTATE_PID"

    # Set up cleanup on exit
    trap cleanup SIGTERM SIGINT

    # Enable auto-rotate flag
    echo "on" > "$AUTO_ROTATE_FILE"

    echo "Theme rotation daemon started (PID: $$)"

    while true; do
        # Check if auto-rotate is still enabled
        if ! is_auto_rotate_enabled; then
            echo "Auto-rotate disabled, exiting"
            cleanup
        fi

        # Sleep for interval
        sleep "$INTERVAL"

        # Check again after sleep
        if ! is_auto_rotate_enabled; then
            echo "Auto-rotate disabled during sleep, exiting"
            cleanup
        fi

        # Rotate wallpaper
        rotate_wallpaper
    done
}

main "$@"

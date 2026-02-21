function reload -d "Reload Hyprland, Waybar, swaync, SDDM, and wallpaper"
    hyprctl reload
    ~/.config/hypr/scripts/Refresh.sh &>/dev/null &
    disown
    sudo ~/.config/hypr/scripts/sddm_wallpaper.sh &>/dev/null &
    disown
    for pid in (pidof kitty)
        kill -SIGUSR1 $pid 2>/dev/null
    end
    echo "Reloaded: hyprland, waybar, swaync, sddm, kitty"
end

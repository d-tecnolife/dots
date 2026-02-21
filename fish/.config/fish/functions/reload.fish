function reload -d "Reload Hyprland, Waybar, swaync, SDDM, keyd, and wallpaper"
    hyprctl reload
    ~/.config/hypr/scripts/Refresh.sh &>/dev/null &
    disown
    sudo ~/.config/hypr/scripts/sddm_wallpaper.sh &>/dev/null &
    disown
    for pid in (pidof kitty)
        kill -SIGUSR1 $pid 2>/dev/null
    end
    sudo keyd reload
    echo "Reloaded: hyprland, waybar, swaync, sddm, kitty, keyd"
end

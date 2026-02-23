function reload -d "Reload Hyprland, Waybar, swaync, SDDM, keyd, and wallpaper"
    hyprctl reload
    ~/.config/hypr/UserScripts/Refresh.sh &>/dev/null &
    disown
    sudo ~/.config/hypr/UserScripts/sddm_wallpaper.sh --normal &>/dev/null &
    disown
    for pid in (pidof kitty)
        kill -SIGUSR1 $pid 2>/dev/null
    end
    sudo keyd reload
    echo "Reloaded: hyprland, waybar, swaync, sddm, kitty, keyd"
end

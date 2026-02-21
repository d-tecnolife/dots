function _theme_apply_mode -d "Apply light or dark mode to the desktop environment"
    set -l mode $argv[1]

    set -l swaync_style ~/.config/swaync/style.css
    set -l ags_style ~/.config/ags/user/style.css
    set -l wallust_rofi ~/.config/wallust/templates/colors-rofi.rasi
    set -l qt5ct_conf ~/.config/qt5ct/qt5ct.conf
    set -l qt6ct_conf ~/.config/qt6ct/qt6ct.conf

    if test "$mode" = Light
        sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(255, 255, 255, 0.9);/' $swaync_style

        if command -q ags; and test -f $ags_style
            sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(255, 255, 255, 0.4);/' $ags_style
            sed -i '/@define-color text-color/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(0, 0, 0, 0.7);/' $ags_style
            sed -i '/@define-color noti-bg-alt/s/#.*;/#F0F0F0;/' $ags_style
        end

        sed -i '/^background:/s/.*/background: rgba(255,255,255,0.9);/' $wallust_rofi

        test -f $qt5ct_conf; and sed -i "s|^color_scheme_path=.*\$|color_scheme_path=$HOME/.config/qt5ct/colors/Catppuccin-Latte.conf|" $qt5ct_conf
        test -f $qt6ct_conf; and sed -i "s|^color_scheme_path=.*\$|color_scheme_path=$HOME/.config/qt6ct/colors/Catppuccin-Latte.conf|" $qt6ct_conf
        if test -d /usr/share/Kvantum/catppuccin-latte-blue; or test -d ~/.config/Kvantum/catppuccin-latte-blue
            kvantummanager --set catppuccin-latte-blue
        end

        gsettings set org.gnome.desktop.interface color-scheme prefer-light
    else
        sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(0, 0, 0, 0.8);/' $swaync_style

        if command -q ags; and test -f $ags_style
            sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(0, 0, 0, 0.4);/' $ags_style
            sed -i '/@define-color text-color/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(255, 255, 255, 0.7);/' $ags_style
            sed -i '/@define-color noti-bg-alt/s/#.*;/#111111;/' $ags_style
        end

        sed -i '/^background:/s/.*/background: rgba(0,0,0,0.7);/' $wallust_rofi

        test -f $qt5ct_conf; and sed -i "s|^color_scheme_path=.*\$|color_scheme_path=$HOME/.config/qt5ct/colors/Catppuccin-Mocha.conf|" $qt5ct_conf
        test -f $qt6ct_conf; and sed -i "s|^color_scheme_path=.*\$|color_scheme_path=$HOME/.config/qt6ct/colors/Catppuccin-Mocha.conf|" $qt6ct_conf
        if test -d /usr/share/Kvantum/catppuccin-mocha-blue; or test -d ~/.config/Kvantum/catppuccin-mocha-blue
            kvantummanager --set catppuccin-mocha-blue
        end

        gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    end

    echo $mode >~/.cache/.theme_mode
end

function theme -d "Save and load desktop presets (waybar + wallpaper + mode)"
    set -l preset_dir ~/.config/hypr/presets

    if test (count $argv) -lt 1
        echo "Usage: theme save <name> [light|dark] | load <name> | list | delete <name>"
        return 1
    end

    switch $argv[1]
        case save
            if test (count $argv) -lt 2
                echo "Usage: theme save <name> [light|dark]"
                return 1
            end
            set -l name $argv[2]
            set -l dir $preset_dir/$name
            mkdir -p $dir

            set -l wb_config (readlink ~/.config/waybar/config)
            set -l wb_style (readlink ~/.config/waybar/style.css)
            set -l wallpaper (swww query 2>/dev/null | sed 's/.*image: //')

            echo $wb_config >$dir/waybar_config
            echo $wb_style >$dir/waybar_style
            echo $wallpaper >$dir/wallpaper
            sed -n 's/^palette = "\(.*\)"/\1/p' ~/.config/wallust/wallust.toml >$dir/palette

            if test (count $argv) -ge 3
                switch (string lower $argv[3])
                    case light
                        echo Light >$dir/mode
                    case dark
                        echo Dark >$dir/mode
                    case '*'
                        echo "Invalid mode '$argv[3]' — use 'light' or 'dark'"
                        return 1
                end
            else if test -f ~/.cache/.theme_mode
                cp ~/.cache/.theme_mode $dir/mode
            end

            echo "Saved preset '$name'"
            echo "  Waybar config: $(basename $wb_config)"
            echo "  Waybar style:  $(basename $wb_style)"
            echo "  Wallpaper:     $(basename $wallpaper)"
            if test -f $dir/mode
                echo "  Mode:          $(cat $dir/mode)"
            end
            echo "  Palette:       $(cat $dir/palette)"

        case load
            if test (count $argv) -lt 2
                echo "Usage: theme load <name>"
                return 1
            end
            set -l name $argv[2]
            set -l dir $preset_dir/$name

            if not test -d $dir
                echo "Preset '$name' not found"
                return 1
            end

            set -l wb_config (cat $dir/waybar_config)
            set -l wb_style (cat $dir/waybar_style)
            set -l wallpaper (cat $dir/wallpaper)

            if test -f $dir/mode
                set -l target_mode (cat $dir/mode)
                set -l current_mode ""
                if test -f ~/.cache/.theme_mode
                    set current_mode (cat ~/.cache/.theme_mode)
                end
                if test "$target_mode" != "$current_mode"
                    _theme_apply_mode $target_mode
                end
            end

            if test -f $dir/palette
                set -l saved_palette (cat $dir/palette)
                sed -i 's/^palette = .*/palette = "'"$saved_palette"'"/' ~/.config/wallust/wallust.toml
            end

            ln -sf $wb_config ~/.config/waybar/config
            ln -sf $wb_style ~/.config/waybar/style.css

            if test -f "$wallpaper"
                swww img $wallpaper --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2 --transition-fps 60 &>/dev/null
                fish -c "~/.config/hypr/scripts/WallustSwww.sh $wallpaper &>/dev/null; killall -SIGUSR1 kitty 2>/dev/null" &
                disown
            end

            pkill waybar
            sleep 0.2
            waybar &>/dev/null &
            disown

            echo "Loaded preset '$name'"

        case list
            if not test -d $preset_dir
                echo "No presets saved"
                return 0
            end
            for dir in $preset_dir/*/
                set -l name (basename $dir)
                set -l wb_config (basename (cat $dir/waybar_config 2>/dev/null))
                set -l wb_style (basename (cat $dir/waybar_style 2>/dev/null))
                set -l wallpaper (basename (cat $dir/wallpaper 2>/dev/null))
                set -l mode ""
                if test -f $dir/mode
                    set mode (cat $dir/mode)
                end
                set -l palette ""
                if test -f $dir/palette
                    set palette (cat $dir/palette)
                end
                echo "$name"
                set -l info "  Config: $wb_config | Style: $wb_style | Wall: $wallpaper"
                if test -n "$mode"
                    set info "$info | Mode: $mode"
                end
                if test -n "$palette"
                    set info "$info | Palette: $palette"
                end
                echo $info
            end

        case delete
            if test (count $argv) -lt 2
                echo "Usage: theme delete <name>"
                return 1
            end
            set -l name $argv[2]
            if test -d $preset_dir/$name
                rm -rf $preset_dir/$name
                echo "Deleted preset '$name'"
            else
                echo "Preset '$name' not found"
            end

        case '*'
            echo "Usage: theme save <name> [light|dark] | load <name> | list | delete <name>"
    end
end

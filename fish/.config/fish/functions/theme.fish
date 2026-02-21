function theme -d "Save and load desktop presets (waybar + wallpaper)"
    set -l preset_dir ~/.config/hypr/presets

    if test (count $argv) -lt 1
        echo "Usage: theme save <name> | load <name> | list | delete <name>"
        return 1
    end

    switch $argv[1]
        case save
            if test (count $argv) -lt 2
                echo "Usage: theme save <name>"
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

            echo "Saved preset '$name'"
            echo "  Waybar config: $(basename "$wb_config")"
            echo "  Waybar style:  $(basename "$wb_style")"
            echo "  Wallpaper:     $(basename "$wallpaper")"

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

            ln -sf $wb_config ~/.config/waybar/config
            ln -sf $wb_style ~/.config/waybar/style.css

            if test -f "$wallpaper"
                ~/.config/hypr/scripts/WallustSwww.sh $wallpaper &>/dev/null &
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
                echo "$name"
                echo "  Config: $wb_config | Style: $wb_style | Wall: $wallpaper"
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
            echo "Usage: theme save <name> | load <name> | list | delete <name>"
    end
end

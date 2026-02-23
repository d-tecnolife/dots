function theme-wallpaper -d "Symlink wallpapers into a theme folder"
    set -l themes_dir ~/.config/hypr/themes

    if test (count $argv) -lt 2
        echo "Usage: theme-wallpaper <light|dark> <path>..."
        echo "       theme-wallpaper <light|dark> --delete <name>..."
        echo ""
        echo "Symlinks image files into the theme's wallpapers directory."
        echo "Accepts full paths, relative paths, or bare filenames"
        echo "(bare names resolve from ~/pictures/wallpapers/)."
        echo ""
        echo "Examples:"
        echo "  theme-wallpaper dark dtec-vista_black.jpg"
        echo "  theme-wallpaper dark ~/pictures/ai-art/cyberpunk.png"
        echo "  theme-wallpaper dark /tmp/upscaled/*.jpg"
        echo "  theme-wallpaper light --delete cyberpunk.png"
        return 1
    end

    set -l theme $argv[1]
    set -l dest $themes_dir/$theme/wallpapers

    if not contains $theme light dark
        echo "Theme must be 'light' or 'dark'"
        return 1
    end

    if not test -d $dest
        mkdir -p $dest
    end

    set -l delete_mode false
    set -l files $argv[2..]

    if test "$argv[2]" = --delete
        set delete_mode true
        set files $argv[3..]
    end

    if test (count $files) -eq 0
        echo "No wallpapers specified"
        return 1
    end

    for name in $files
        set -l basename_name (basename $name)

        if $delete_mode
            if test -L $dest/$basename_name; or test -f $dest/$basename_name
                rm $dest/$basename_name
                echo "removed: $theme/$basename_name"
            else
                echo "not found: $theme/$basename_name"
            end
            continue
        end

        # Resolve source: if it contains a slash or exists as a path, use as-is;
        # otherwise fall back to ~/pictures/wallpapers/
        set -l source
        if string match -q '*/*' -- $name
            set source (realpath -m $name)
        else if test -f $name
            set source (realpath $name)
        else
            set source ~/pictures/wallpapers/$name
        end

        if not test -f $source
            echo "not found: $source"
            continue
        end

        if test -f $dest/$basename_name; and not test -L $dest/$basename_name
            rm $dest/$basename_name
        end

        ln -sf $source $dest/$basename_name
        echo "linked: $theme/$basename_name -> $source"
    end
end

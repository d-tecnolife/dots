function hacker
    if test "$argv[1]" = mode
        switch "$argv[2]"
            case on
                echo "Haxx0r Mode Sequence Initialized."
                ~/.config/hypr/UserScripts/ThemePicker.sh --apply dark >/dev/null 2>&1
            case off
                echo "Haxx0r Mode Sequence Terminated."
                ~/.config/hypr/UserScripts/ThemePicker.sh --apply light >/dev/null 2>&1
            case '*'
                echo "Try: hacker mode [on|off]"
        end
    else
        echo "Unknown command. Did you mean 'hacker mode'?"
    end
end

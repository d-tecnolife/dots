function hacker
    if test "$argv[1]" = mode
        switch "$argv[2]"
            case on
                echo "Haxx0r Mode Sequence Initialized."
                theme load vista-dark >/dev/null
            case off
                echo "Haxx0r Mode Sequence Terminated."
                theme load xp-silver >/dev/null
            case '*'
                echo "Try: hacker mode [on|off]"
        end
    else
        echo "Unknown command. Did you mean 'hacker mode'?"
    end
end

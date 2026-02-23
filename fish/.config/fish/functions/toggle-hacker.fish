function toggle-hacker
    set FLAG /tmp/hacker_mode_active
    if test -f $FLAG
        hacker mode off
        rm $FLAG
    else
        hacker mode on
        touch $FLAG
    end
end

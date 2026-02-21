function ytm -d "Download audio from YouTube as Opus"
    yt-dlp -f 'ba[acodec=opus]/ba' -x --audio-format opus --audio-quality 0 \
        --embed-metadata \
        -o ~/music/'%(title)s.%(ext)s' $argv
    and beet import ~/music
end

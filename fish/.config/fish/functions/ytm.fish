function ytm -d "Download audio from YouTube as Opus"
    yt-dlp -f 'ba[acodec=opus]/ba' -x --audio-format opus --audio-quality 0 \
        --embed-metadata \
        -o ~/music/.unsorted/'%(title)s.%(ext)s' $argv
    and beet import -s ~/music/.unsorted
end

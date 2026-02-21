#!/bin/bash
FLAG="/tmp/hacker_mode_active"

if [ -f "$FLAG" ]; then
  fish -c "hacker mode off"
  rm "$FLAG"
else
  fish -c "hacker mode on"
  touch "$FLAG"
fi

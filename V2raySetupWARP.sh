#!/usr/bin/env bash
script_path=~/v2ray-warp.sh
if [[ ! -f $script_path ]]; then
    curl -fsSL git.io/warp.sh > $script_path  # WARP setup script
fi
sudo -E bash $script_path 6

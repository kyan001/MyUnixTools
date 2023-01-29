#!/usr/bin/env bash
script_path=~/v2ray-warp.sh
if [[ ! -f $script_path ]]; then
    curl -fsSL git.io/warp.sh > $script_path  # WARP setup script
fi
sudo echo ""
echo "  Select:"
echo "      1. 中文"
echo "      2. 开启 BBR 或 BBR2 加速, 开启 BBR2 需要安装 XanMod 内核"
echo "      1 BBR 需要内核在 4.9 以上"
echo "      (1) FQ"
echo ""
echo -n "3... "
sleep 1s
echo -n "2... "
sleep 1s
echo -n "1... "
sleep 1s
echo "!"
sudo -E bash $script_path 6  # select wg

#!/usr/bin/env bash
curl -Lso- https://git.io/kernel.sh > v2ray-bbr.sh  # BBR setup script
echo ""
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
sudo -E bash ~/v2ray-bbr.sh

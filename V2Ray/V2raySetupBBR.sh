#!/usr/bin/env bash

export LC_ALL=C
export LANG=en_US.UTF-8  # Set language to US English
export LANGUAGE=en_US.UTF-8  # Set language to US English


# Run 3rd Party BBR Setup Script
function full_bbr_setup {
    script_path="~/v2ray-bbr.sh"
    curl -Lso- https://git.io/kernel.sh > $script_path  # BBR setup script
    sudo echo "*"
    echo "| 推荐的配置："
    echo "|     1. 中文"
    echo "|     2. 开启 BBR 或 BBR2 加速, 开启 BBR2 需要安装 XanMod 内核"
    echo "|     1 BBR 需要内核在 4.9 以上"
    echo "|     (1) FQ"
    echo '`'
    echo -n "3... 2... 1..."
    sleep 3s
    sudo -E bash $script_path
}


# Detect if script is running as root
function check_root {
    if [[ $EUID -ne 0 ]]; then
        echo "| [!] This script must be run as root."
        exit 1
    fi
}


# Press ENTER to continue, Ctrl-C to exit.
function press_to_continue {
    read -p "... Press ENTER to continue, Ctrl-C to exit."
}


# Install packages needed for setup.
# (Default Settings Only)
function install_pkg {
    local pkg_list=("wget" "curl" "git" "unzip" "apt-transport-https" "cpu-checker" "bc" "cron" "ca-certificates" "dmidecode")
    for pkg in "${pkg_list[@]}"; do
        if ! dpkg -l | grep -qw "$pkg"; then
            # dpkg -l: list installed packages.
            # grep -q: quiet, no text printed.
            # grep -w: only match whole word.
            echo "| Installing $pkg..."
            apt-get install -y "$pkg"
            if [[ "$pkg" == "ca-certificates" ]]; then
                update-ca-certificates
            fi
        else
            echo "| '$pkg' is already installed."
        fi
    done
}


# Ask and Rebook System
function reboot_system {
    local answer
    read -p "| [?] Reboot? (Y/n): " answer
    if [[ "$answer" == [Yy] ]]; then
        echo "| [:] Rebooting..."
        sudo reboot
    else
        echo "| [!] Reboot cancelled."
    fi
}


# Print current BBR/QD/ECN status
function show_current_status {
    echo "*"
    echo "| Current Status:"
    # Congestion Control
        # BBR = Bottlenect Bandwidth and Round-trip propagtion time
    current_cc=$(cat /proc/sys/net/ipv4/tcp_congestion_control)
    if [[ "$current_cc" == "bbr" ]]; then
        echo "|     BBR: On"
    else
        echo "|     [!] BBR: Off"
    fi
    # Congestion Control Running
    current_cc_enabled=$(sysctl net.ipv4.tcp_congestion_control)
    if [[ $current_cc_enabled == *"bbr" ]]; then
        echo "|     BBR Running: On"
    else
        echo "|     [!] BBR Running: Off"
    fi
    # Queue Discipline
        # FQ = Fair Queueing
    current_qd=$(cat /proc/sys/net/core/default_qdisc)
    if [[ "$current_qd" == "fq" ]]; then
        echo "|     FQ: On"
    else
        echo "|     [!] FQ: Off"
    fi
    # TCP Explicit Congestion Notification
        # 0 = Disabled
        # 1 = Enabled
        # 2 = Only for Inbound
    current_ecn=$(cat /proc/sys/net/ipv4/tcp_ecn)
    if [[ "$current_ecn" == "0" ]]; then
        echo "|     [!] ECN: Disabled"
    elif [[ "$current_ecn" == "1" ]]; then
        echo "|     ECN: Enabled"
    elif [[ "$current_ecn" == "1" ]]; then
        echo "|     ECN: Enabled (Inbound Only)"
    fi
    echo '`'
}


# Remove BBR related settings in /etc/sysctl.conf
function remove_bbr {
    echo "*"
    echo "| Remove BBR"
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
        # sed -i: manipulate the file content directly
        # '.../d': delete the line
        # /etc/sysctl.conf: target file
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
    echo "| [OK] BBR is removed!"
    echo '`'
}


# Remove Network Optimizing settings in multiple files
function remove_net_optimizing {
    echo "*"
    echo "| Remove Network Optimizing"
    sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
    sed -i '/1000000/d' /etc/security/limits.conf
    sed -i '/1000000/d' /etc/profile
    echo "| [OK] Network Optimizing is removed!"
    echo '`'
}


# Add BBr settings in /etc/sysctl.conf
function apply_bbr {
    echo '*'
    echo "| Apply BBR"
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf  # Turn on BBR
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf  # Turn on FQ
    echo "net.ipv4.tcp_ecn=2" >> /etc/sysctl.conf  # Turn on ECN
    sysctl -p
    if [[ $? -ne 0 ]]; then
        echo "| [!] Apply BBR Failed."
    else
        echo "| [OK] Apply BBR Done."
    fi
    echo '`'
}


# Add Network Optimizing settings in multiple files.
function apply_net_optimizing {
    echo "*"
    echo "| Apply Network Optimizing."
    if grep -q "1000000" "/etc/profile"; then
        echo "| Network already optimized"
    else
        remove_net_optimizing
        # /etc/sysctl.conf
        cat >> /etc/sysctl.conf <<-EOF
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100

net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768

# forward ipv4
#net.ipv4.ip_forward = 1
EOF
        # /etc/security/limits.conf
        cat >> /etc/security/limits.conf <<-EOF
*               soft    nofile          1000000
*               hard    nofile          1000000
EOF
        # /etc/profile
        echo "ulimit -SHn 1000000" >> /etc/profile
        source /etc/profile
        # apply
        sysctl -p
    fi
    echo '`'
}

function main {
    echo "*"
    echo "| Default Settings: Ubuntu + BBR + FQ"
    echo "|"
    local answer
    read -p "| [?] Use default settings? (Y/n): " answer
    if [[ -n "$answer" && "$answer" != "Y" && "$answer" != "y" ]]; then  # answer not empty not "Y" or "y"
        echo "| [!] Run full BBR setup."
        full_bbr_setup
    else
        check_root
        echo "| [:] Using default settings."
        echo '`'
        install_pkg  # install softwares by apt-get
        remove_bbr  # Remove BBR settings in sysctl
        apply_bbr  # Apply BBR settings in sysctl
        apply_net_optimizing  # Apply Network Optimizing
        reboot_system  # Ask and reboot
    fi
}


main

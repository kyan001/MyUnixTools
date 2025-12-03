# Remove Network Optimizing settings in multiple files
function remove_ipv6_disabling {
    echo "*"
    echo "| Removing IPv6 Disabling ..."
    sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
    echo "| [OK] IPv6 Disabling is removed!"
    echo '`'
}

function apply_ipv6_disabling {
    echo "*"
    echo "| Apply IPv6 Disabling."
    if grep -q "net.ipv6.conf.all.disable_ipv6 = 1" "/etc/sysctl.conf"; then
        echo "| IPv6 already disabled"
    else
        remove_ipv6_disabling
        echo "| Disabling IPv6 ..."
        # /etc/sysctl.conf
        echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
        # apply
        sysctl -p
    fi
    echo '`'
}
function detect_ipv6_disabling_status {
    if grep -q "net.ipv6.conf.all.disable_ipv6 = 1" "/etc/sysctl.conf"; then
        echo "| IPv6 is disabled."
    else
        echo "| IPv6 is enabled."
    fi
    echo '`'
}

function main {
    echo "*"
    echo "| Disable IPv6 Script"
    echo "|"
    detect_ipv6_disabling_status
    echo "|"
    local answer
    echo "| [?]"
    echo "| 1. Disable IPv6"
    echo "| 2. Enable IPv6"
    read -p "| > " answer
    if [[ "$answer" == "1" ]]; then  # answer not empty not "Y" or "y"
        apply_ipv6_disabling
    elif [[ "$answer" == "2" ]]; then
        remove_ipv6_disabling
    else
        echo "| [!] Invalid Option."
    fi
}

main

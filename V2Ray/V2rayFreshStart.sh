#!/usr/bin/env bash
# Pre-requirement: git clone https://github.com/kyan001/MyUnixTools
source $(dirname "$0")/../utils/pprint.sh  # MyUnixTools/utils/pprint.sh

if [[ $USER == "root" ]]; then
    autocreateuser_path="$(dirname "$0")/../AutoCreateUser.sh"
    echo -n "[?] Please enter your username: "  # do not add \n
    read -r username  # get user raw input
    if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: Invalid username. Only letters, numbers, underscores, and hyphens allowed."
        exit 1
    fi

    # Install Packages
    pprint --title "Installing required packages ..."
    bash $(dirname "$0")/InstallPackagesForV2ray.sh

    # User Creation
    if id "$username" >& /dev/null; then
        pprint --warn "User already exist."
    else
        pprint --title "Creating unix user ..."
        bash "$autocreateuser_path" -user "$username"  # Enter password manually
    fi
    # User Env Setup
    if [[ ! -f /bin/zsh ]]; then
        pprint --warn "Zsh not found, installing ..."
        apt install -y zsh  # install zsh
    fi
    if [[ ! -f /home/$username/.zshrc ]]; then
        pprint --warn "Zsh not initialized, initializing ..."
        touch "/home/$username/.zshrc"  # init zsh
    fi
    pprint --info "Setting zsh as user default shell"
    chsh -s /bin/zsh "$username"  # set zsh as user's shell
    pprint --panel "You can now relogin using $username"
else
    # Setup Zsh
    pprint --title "Setting up Zsh for V2ray ..."
    bash $(dirname "$0")/SetupZshForV2ray.sh

    # Setup Nginx for V2ray
    pprint --title "Setting up Nginx for V2ray ..."
    bash $(dirname "$0")/SetupNginxForV2ray.sh

    # Setup V2ray and HTTPS
    pprint --title "Setting up V2ray and HTTPS..."
    bash $(dirname "$0")/SetupHttpsAndV2ray.sh

    # Setup BBR
    echo "[?] Setup BBR for V2ray? [Y/n]"
    echo -n "> "
    read -r BBR_enable
    if [[ $BBR_enable == [Yy] ]]; then
        pprint --title "Setting up BBR ..."
        sudo -E bash $(dirname "$0")/SetupBbrForV2ray.sh
    else
        pprint --warn "BBR setup skipped."
    fi

    # Setup WARP
    echo "[?] Setup WARP for V2ray? [Y/n]"
    echo -n "> "
    read -r WARP_enable
    if [[ $WARP_enable == [Yy] ]]; then
        pprint --title "Setting up WARP ..."
        bash $(dirname "$0")/SetupWarpForV2ray.sh
    else
        pprint --warn "WARP setup skipped."
    fi

    # Disable IPv6
    echo "[?] Disable IPv6? [Y/n]"
    echo -n "> "
    read -r IPv6_disable
    if [[ $IPv6_disable == [Yy] ]]; then
        pprint --title "Disabling IPv6 ..."
        bash $(dirname "$0")/DisableIPv6.sh
    else
        pprint --warn "IPv6 disable skipped."
    fi

    # Set V2ray Alter ID to 32
    pprint --title "Setting V2ray Alter ID to 32 ..."
    bash $(dirname "$0")/SetAlterIdForV2ray.sh

    # Done
    pprint --warn "Done!"
fi

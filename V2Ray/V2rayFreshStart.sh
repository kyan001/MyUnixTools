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
    echo "============ Installing required packages ... ============"
    bash $(dirname "$0")/InstallPackagesForV2ray.sh

    # User Creation
    if id "$username" >& /dev/null; then
        echo "(Warning) User already exist."
    else
        echo "============ Creating unix user ... ============"
        bash "$autocreateuser_path" -user "$username"  # Enter password manually
    fi
    # User Env Setup
    if [[ ! -f /bin/zsh ]]; then
        echo "(Warning) Zsh not found, installing ..."
        apt install -y zsh  # install zsh
    fi
    if [[ ! -f /home/$username/.zshrc ]]; then
        echo "(Warning) Zsh not initialized, initializing ..."
        touch "/home/$username/.zshrc"  # init zsh
    fi
    echo "(Info) Setting zsh as user default shell"
    chsh -s /bin/zsh "$username"  # set zsh as user's shell
    echo "+-------------------------------------+"
    echo "| You can now relogin using $username |"
    echo "+-------------------------------------+"
else
    # Setup Zsh
    echo "============ Setting up Zsh for V2ray ... ============"
    bash $(dirname "$0")/SetupZshForV2ray.sh

    # Setup Nginx for V2ray
    echo "============ Setting up Nginx for V2ray ... ============"
    bash $(dirname "$0")/SetupNginxForV2ray.sh

    # Setup V2ray and HTTPS
    echo "============ Setting up V2ray and HTTPS... ============"
    bash $(dirname "$0")/SetupHttpsAndV2ray.sh

    # Setup BBR
    echo "[?] Setup BBR for V2ray? [Y/n]"
    echo -n "> "
    read -r BBR_enable
    if [[ $BBR_enable == [Yy] ]]; then
        echo "============ Setting up BBR ... ============"
        sudo -E bash $(dirname "$0")/SetupBbrForV2ray.sh
    else
        echo "(Warning) BBR setup skipped."
    fi

    # Setup WARP
    echo "[?] Setup WARP for V2ray? [Y/n]"
    echo -n "> "
    read -r WARP_enable
    if [[ $WARP_enable == [Yy] ]]; then
        echo "============ Setting up WARP ... ============"
        bash $(dirname "$0")/SetupWarpForV2ray.sh
    else
        echo "(Warning) WARP setup skipped."
    fi

    # Disable IPv6
    echo "[?] Disable IPv6? [Y/n]"
    echo -n "> "
    read -r IPv6_disable
    if [[ $IPv6_disable == [Yy] ]]; then
        echo "============ Disabling IPv6 ... ============"
        bash $(dirname "$0")/DisableIPv6.sh
    else
        echo "(Warning) IPv6 disable skipped."
    fi

    # Set V2ray Alter ID to 32
    echo "============ Setting V2ray Alter ID to 32 ... ============"
    bash $(dirname "$0")/SetAlterIdForV2ray.sh

    # Done
    echo "(Warning) Done!"
fi

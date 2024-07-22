#!/usr/bin/env bash
# Pre-requirement: git clone https://github.com/kyan001/MyUnixTools
source $(dirname "$0")/../utils/pprint.sh  # MyUnixTools/utils/pprint.sh

if [[ $USER == "root" ]]; then
    echo -n "[?] Please enter your username: "  # do not add \n
    read -r username  # get user raw input
    pprint --info "Installing necessary apps ..."
    apt update  # update index
    apt install -y zsh python3-pip nginx certbot python3-certbot-nginx pipx  # install apps, automatically yes.
    pipx ensurepath
    pipx install rich-cli
    # User Creation
    if id "$username" >& /dev/null; then
        pprint --warn "User already exist."
    else
        pprint --title "Creating unix user ..."
        bash AutoCreateUser.sh -user "$username"  # Enter password manually
    fi
    # User Env Setup
    if [[ ! -f /bin/zsh ]]; then
        pprint --warn "Zsh not found, installing ..."
        apt install -y zsh  # install zsh
    fi
    if [[ ! -f /home/$username/.zshrc ]]; then
        pprint --warn "Zsh not initialized, initializing ..."
        touch /home/"$username"/.zshrc  # init zsh
    fi
    pprint --info "Setting zsh as user default shell"
    chsh -s /bin/zsh "$username"  # set zsh as user's shell
    pprint --panel "You can now relogin using $username"
else
    autosetupzshpy_path="../Zsh/AutoSetupZsh.py"
    nginx_v2ray_path="../Nginx/nginx_v2ray"
    local_v2raysh_path="~/v2ray-233boy.sh"
    echo -n "[?] Please enter your domain for v2ray: "  # do not add \n
    read -r domain  # get user raw input
    pprint --info "Install Python3 Packages ..."
    if ! pip3 show "consolecmdtools" &> /dev/null; then
        pip3 install --user consolecmdtools --break-system-packages
    fi
    pprint --title "Setting up zsh ..."
    python3 $autosetupzshpy_path
    pprint --title "Updating user configs ..."
    cmgr  # pip3 install cmgr
    echo "[?] Using Nginx for V2ray? [Y/n]"
    echo -n "> "
    read -r nginx_enabled
    if [[ $nginx_enabled == [Yy] ]]; then
        pprint --info "Copying nginx v2ray config file ..."
        sudo cp $nginx_v2ray_path /etc/nginx/sites-available/v2ray  # copy nginx config for v2ray
        pprint --info "Putting your domain '$domain' in nginx config ..."
        sudo sed -i "s/__your_domain__/$domain/" /etc/nginx/sites-available/v2ray  # update nginx config file
        pprint --info "Linking Nginx configs ..."
        sudo ln -s /etc/nginx/sites-available/v2ray /etc/nginx/sites-enabled/
        pprint --info "Testing Nginx configs ..."
        if sudo nginx -t; then
            sudo service nginx restart
        fi
    else
        pprint --warn "Nginx configuration ignored."
    fi
    pprint --info "Downloading v2ray script"
    v2raysh_url="https://github.com/233boy/v2ray/raw/17786513942be03b562beaadd3f1676cab7b85a3/v2ray.sh"  # use old version v3.05
    # v2raysh_url="https://git.io/v2ray.sh"  # latest v2ray 233boy script
    curl -s -L $v2raysh_url > $local_v2raysh_path  # v2ray setup script
    pprint --warn "Please make sure your domain pointed to this IP."
    pprint --title "Installing v2ray ..."
    sudo -E bash $local_v2raysh_path  # WebSocket + TLS
    pprint --info "Getting HTTPS ceritification ..."
    sudo certbot --nginx  # Choose Your Domain
    pprint --warn "To setup BBR, use the following command:"
    pprint --info "bash ./V2raySetupBBR.sh"
    pprint --warn "To setup WARP, use the following command:"
    pprint --info "bash ./V2raySetupWARP.sh"
    pprint --title "Setting V2Ray AlterId=32"
    sudo sed -i 's/"alterId": 0/"alterId": 32/' /etc/v2ray/config.json
    sudo v2ray restart
    pprint --warn "Done!"
fi

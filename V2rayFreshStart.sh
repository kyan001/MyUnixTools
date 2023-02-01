#!/usr/bin/env bash
# Pre-requirement: git clone https://github.com/kyan001/MyUnixTools
source ./pprint.sh

if [[ $USER == "root" ]]; then
    echo -n "[?] Please enter your username: "  # do not add \n
    read -r username  # get user raw input
    pprint --info "Installing necessary apps ..."
    apt update  # update index
    apt install -y zsh python3-pip nginx certbot python3-certbot-nginx  # install apps, automatically yes.
    pip3 install rich-cli
    # User Creation
    if id "$username" >& /dev/null; then
        pprint --warn "User already exist."
    else
        pprint --title "Creating unix user ..."
        bash AutoCreateUser.sh -user "$username"  # Enter password manually
    fi
    # User Env Setup
    if [[ -f /home/$username/.zshrc ]]; then
        pprint --warn "User Zsh already initialized."
    else
        pprint --info "Initializing zsh ..."
        touch /home/"$username"/.zshrc  # init zsh
    fi
    pprint --info "Setting zsh as user default shell"
    chsh -s /bin/zsh "$username"  # set zsh as user's shell
    pprint --panel "You can now relogin using $username"
else
    echo -n "[?] Please enter your domain for v2ray: "  # do not add \n
    read -r domain  # get user raw input
    pprint --info "Install Python3 Packages ..."
    pip3 install --user consolecmdtools consoleiotools
    pprint --title "Setting up zsh ..."
    python3 AutoSetupZsh.py
    pprint --title "Updating user configs ..."
    python3 UpdateConfig.py
    pprint --info "Copying nginx v2ray config file ..."
    sudo cp config.nginx_v2ray /etc/nginx/sites-available/v2ray  # copy nginx config for v2ray
    pprint --info "Putting your domain '$domain' in nginx config ..."
    sudo sed -i "s/__your_domain__/$domain/" /etc/nginx/sites-available/v2ray  # update nginx config file
    pprint --info "Linking Nginx configs ..."
    sudo ln -s /etc/nginx/sites-available/v2ray /etc/nginx/sites-enabled/
    pprint --info "Testing Nginx configs ..."
    if sudo nginx -t; then
        sudo service nginx restart
    fi
    pprint --info "Downloading v2ray script"
    curl -s -L https://git.io/v2ray.sh > ~/v2ray-233boy.sh  # v2ray setup script
    sed -i 's/if \[\[ $v2ray_transport -eq 4 ]]/if \[\[ $v2ray_transport -eq 4 || $v2ray_transport -eq 33 ]]/' ~/v2ray-233boy.sh
    pprint --warn "Please make sure your domain pointed to this IP."
    pprint --title "Installing v2ray ..."
    sudo -E bash ~/v2ray-233boy.sh  # WebSocket + TLS
    pprint --info "Getting HTTPS ceritification ..."
    sudo certbot --nginx  # Choose Your Domain
    pprint --title "Setting up BBR ..."
    bash ./V2raySetupBBR.sh
    pprint --title "Setting up WARP ..."
    bash ./V2raySetupWARP.sh
    pprint --warn "Done!"
fi

#!/usr/bin/env bash
# Pre-requirement: git clone https://github.com/kyan001/MyUnixTools
source ./pprint.sh

if [[ $USER == "root" ]]; then
    echo -n "  [?] Please enter your username: "  # do not add \n
    read -r username  # get user raw input
    pprint --info "Installing necessary apps ..."
    apt update  # update index
    apt install -y zsh python3-pip nginx certbot python3-certbot-nginx  # install apps, automatically yes.
    pip3 install rich-cli
    # User Creation
    if id "$USER" >& /dev/null; then
        pprint --warn "User already exist."
    else
        pprint --info "Creating unix user ..."
        bash AutoCreateUser.sh -user "$username"  # Enter password manually
    fi
    # User Env Setup
    if [[ -f /home/$username/.zshrc ]]; then
        pprint --warn "User Zsh already initialized."
    else
        pprint --info "Initializing zsh ..."
        touch /home/"$username"/.zshrc  # init zsh
    fi
    pprint --info "Set zsh as user default shell"
    chsh -s /bin/zsh "$username"  # set zsh as user's shell
    pprint --warn "You can now relogin using $username"
else
    echo -n "  [?] Please enter your domain for v2ray: "  # do not add \n
    read -r domain  # get user raw input
    pprint --info "Install Python3 Packages ..."
    pip3 install --user consolecmdtools consoleiotools
    pprint --info "Setting up zsh ..."
    python3 AutoSetupZsh.py
    pprint --info "Updating user configs ..."
    python3 UpdateConfig.py
    pprint --info "Configing p10k ... (p10k config)"
    pprint --info "Copying nginx v2ray config file ..."
    sudo cp config.nginx_v2ray /etc/nginx/sites-available/v2ray  # copy nginx config for v2ray
    pprint --info "Please fill your domain '$domain' in nginx config ..."
    sudo sed "s/__your_domain__/$domain/" /etc/nginx/sites-available/v2ray  # update nginx config file
    pprint --info "Linking nginx configs ..."
    sudo ln -s /etc/nginx/sites-available/v2ray /etc/nginx/sites-enabled/
    pprint --info "Testing Nginx configs ..."
    sudo nginx -t
    pprint --info "Change dir to ~"
    cd ~ || exit
    pprint --info "Downloading v2ray script"
    curl -s -L https://git.io/v2ray.sh > v2ray-233boy.sh  # v2ray setup script
    pprint --warn "Please make sure your domain pointed to this IP."
    pprint --info "Installing v2ray ..."
    sudo -E bash ~/v2ray-233boy.sh  # WebSocket + TLS
    pprint --info "Getting HTTPS ceritification ..."
    sudo certbot --nginx  # Choose Your Domain
    pprint --warn "Done!"
fi

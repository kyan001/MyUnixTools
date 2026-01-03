source $(dirname "$0")/../utils/pprint.sh  # MyUnixTools/utils/pprint.sh

# Setup Nginx for V2ray
echo -n "[?] Please enter your domain for v2ray: "  # do not add \n
read -r domain  # get user raw input
nginx_v2ray_path="$(dirname "$0")/../Nginx/nginx_v2ray"
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

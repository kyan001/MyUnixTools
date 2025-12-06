local_v2raysh_path="$HOME/v2ray-233boy.sh"
pprint --info "Downloading v2ray script"
v2raysh_url="https://raw.githubusercontent.com/233boy/v2ray/old/install.sh?v"  # use old version 233boy's v2ray script
# v2raysh_url="https://git.io/v2ray.sh"  # latest 233boy's v2ray script
curl -s -L $v2raysh_url > $local_v2raysh_path  # download shell
pprint --warn "Please make sure your domain pointed to this IP."
pprint --title "Installing v2ray ..."
sudo -E bash $local_v2raysh_path online old  # args=online, branch=old
    # WebSocket + TLS, 40000.
pprint --info "Getting HTTPS ceritification ..."
sudo certbot --nginx  # Choose Your Domain

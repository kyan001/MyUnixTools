#! /usr/bin/env bash
# version 0.1.0
echo -n "[?] Please enter your username: "  # do not add \n
read -r username  # get user raw input
if [ "$USER" == "root" ]; then
    echo "[Info] Installing necessary apps ..."
    apt update  # update index
    apt install -y zsh python3-pip nginx certbot python3-certbot-nginx # install apps, automatically yes.
    #echo "[Info] Cloning MyUnixTools ..."  # Consider done when running this script
    #git clone https://github.com/kyan001/MyUnixTools  # Clone Git Repo under /root/
    cd MyUnixTools || exit  # /root/MyUnixTools, if failed exit.
    echo "[Info] Creating unix user ..."
    sh AutoCreateUser.sh -user "$username"  # Enter password manually
    echo "[Info] Initializing zsh ..."
    touch "/home/$username/.zshrc"  # init zsh
    echo "[Info] Set zsh as user default shell"
    chsh -s /bin/zsh "$username"  # set zsh as user's shell
    echo "[Warning] You can now relogin using $username"
    exit
else
    echo "[Info] Cloning MyUnixTools ..."
    git clone https://github.com/kyan001/MyUnixTools  # Clone Git Repo under /home/$username/
    cd MyUnixTools || exit  # ~/MyUnixTools, if failed exit.
    echo "[Info] Setting up zsh ..."
    python3 AutoSetupZsh.py
    echo "[Info] Updating user configs ..."
    python3 UpdateConfig.py
    echo "[Info] Configing p10k ... (p10k config)"
    echo "[Info] Copying nginx v2ray config file ..."
    sudo cp config.nginx_v2ray /etc/nginx/sites-available/v2ray  # copy nginx config for v2ray
    echo "[Info] Please fill your domain in nginx config ..."
    sudo vim /etc/nginx/sites-available/v2ray  # update nginx config file
    echo "[Info] Linking nginx configs ..."
    sudo ln -s /etc/nginx/sites-available/v2ray /etc/nginx/sites-enabled/
    echo "[Info] Testing Nginx configs ..."
    sudo nginx -t
    echo "[Info] Change dir to ~"
    cd ~ || exit
    echo "[Info] Downloading v2ray & bbr shells"
    curl -s -L https://git.io/v2ray.sh > v2ray-233boy.sh  # v2ray setup script
    curl -Lso- https://git.io/kernel.sh > v2ray-bbr.sh  # BBR setup script
    curl -fsSL git.io/warp.sh > v2ray-warp.sh  # WARP setup script
    echo "[Warning] Please make sure your domain pointed to this IP."
    echo "[Info] Installing v2ray ..."
    sudo -E bash ~/v2ray-233boy.sh  # WebSocket + TLS
    echo "[Info] Enabling BBR Plus ..."
    sudo -E bash ~/v2ray-bbr.sh  # select "(1) FQ"
    echo "[Info] Install WireGuard and IPv6 WARP ..."
    sudo -E bash ~/v2ray-warp.sh 6  # select wg
    echo "[Info] Getting HTTPS ceritification ..."
    sudo certbot --nginx  # Choose Your Domain
    echo "[Info] Installing v2ray ..."
    echo "[Warning] Done!"
fi

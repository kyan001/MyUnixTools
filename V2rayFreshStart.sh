#! /usr/bin/env bash
echo -n "[?] Please enter your username: "  # do not add \n
read -r username  # get user raw input
if [ "$USER" == "root" ]; then
    echo "[Info] Installing necessary apps ..."
    apt install -y zsh python3-pip nginx certbot python3-certbot-nginx # install apps, automatically yes.
    echo "[Info] Cloning MyUnixTools ..."
    git clone https://github.com/kyan001/MyUnixTools  # Clone Git Repo under /root/
    cd MyUnixTools || exit  # /root/MyUnixTools, if failed exit.
    echo "[Info] Creating unix user ..."
    sh AutoCreateUser.sh -user $username  # Enter password manually
    echo "[Info] Initializing zsh ..."
    touch /home/$username/.zshrc  # init zsh
    echo "[Info] Set zsh as user default shell"
    chsh -s /bin/zsh $username  # set zsh as user's shell
    echo "[Warning] You can now relogin using $username"
    exit
else
    # init (p10k config)
    echo "[Info] Cloning MyUnixTools ..."
    git clone https://github.com/kyan001/MyUnixTools  # Clone Git Repo under /home/$username/
    cd MyUnixTools || exit  # ~/MyUnixTools, if failed exit.
    echo "[Info] Setup zsh ..."
    python3 AutoSetupZsh.py
    echo "[Info] Update user configs ..."
    python3 UpdateConfig.py
    echo "[Info] Copy nginx v2ray config file ..."
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
    curl -s -L https://git.io/v2ray.sh > v2ray-233boy.sh
    curl -Lso- https://git.io/kernel.sh > v2ray-bbr.sh
    curl -Lso- https://git.io/kernel.sh > v2ray-kernel.sh
    echo "[Warning] Please make sure your domain pointed to this IP."
    echo "[Info] Installing v2ray ..."
    sudo -E bash ~/v2ray-233boy.sh
fi

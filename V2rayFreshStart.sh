USERNAME="kyan001"
if [ "$USER" = "root" ]; then
    apt install zsh python3-pip  # install apps
    git clone https://github.com/kyan001/MyUnixTools  # Clone Git Repo under /root/
    cd MyUnixTools || exit  # /root/MyUnixTools, if failed exit.
    sh AutoCreateUser.sh -user $USERNAME  # Enter password manually
    touch /home/$USERNAME/.zshrc  # init zsh
    chsh -s /bin/zsh $USERNAME  # set zsh as user's shell
    echo "[Info] You can now relogin using $USERNAME"
    exit
else
    git clone https://github.com/kyan001/MyUnixTools  # Clone Git Repo under /home/$USERNAME/
    cd MyUnixTools || exit  # ~/MyUnixTools, if failed exit.
    python3 AutoSetupZsh.py
    python3 UpdateConfig.py
    zsh  # init and exit after
fi

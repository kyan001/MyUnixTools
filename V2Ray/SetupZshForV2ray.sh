autosetupzshpy_path="$(dirname "$0")/../Zsh/AutoSetupZsh.py"
pprint --info "Install Python3 Packages ..."
if ! pip3 show "consolecmdtools" &> /dev/null; then
    pip3 install --user consolecmdtools --break-system-packages
fi
pprint --title "Setting up zsh ..."
python3 $autosetupzshpy_path
pprint --title "Updating user configs ..."
cmgr  # pip3 install cmgr

source $(dirname "$0")/../utils/pprint.sh  # MyUnixTools/utils/pprint.sh

autosetupzshpy_path="$(dirname "$0")/../Zsh/AutoSetupZsh.py"
echo "(Info) Install Python3 Packages ..."
if ! pip3 show "consolecmdtools" &> /dev/null; then
    pip3 install --user consolecmdtools --break-system-packages
fi
echo "============ Setting up zsh ... ============"
python3 $autosetupzshpy_path
echo "============ Updating user configs ... ============"
cmgr  # pip3 install cmgr

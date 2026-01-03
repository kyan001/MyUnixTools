source $(dirname "$0")/../utils/pprint.sh  # MyUnixTools/utils/pprint.sh

pprint --info "Installing necessary apps ..."
apt update  # update index
apt install -y zsh python3-pip nginx certbot python3-certbot-nginx pipx  # install apps, automatically yes.
pipx ensurepath
pipx install rich-cli

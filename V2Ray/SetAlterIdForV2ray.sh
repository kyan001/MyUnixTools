source $(dirname "$0")/../utils/pprint.sh  # MyUnixTools/utils/pprint.sh

pprint --title "Setting V2Ray AlterId=32"
sudo sed -i 's/"alterId": 0/"alterId": 32/' /etc/v2ray/config.json
sudo v2ray restart

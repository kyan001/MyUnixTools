echo "============ Setting V2Ray AlterId=32 ============"
sudo sed -i 's/"alterId": 0/"alterId": 32/' /etc/v2ray/config.json
sudo v2ray restart

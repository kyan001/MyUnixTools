#! /usr/bin/env bash
source $(dirname "$0")/utils/pprint.sh  # MyUnixTools/utils/pprint.s

pprint --title "Remove Old Docker Installations"
sudo apt-get remove docker docker-engine docker.io containerd runc
pprint --title "Install Necessary Libs"
sudo apt-get install ca-certificates curl gnupg lsb-release
pprint --title "Create Keyrings Folder"
sudo mkdir -p /etc/apt/keyrings
pprint --title "Add Docker GPG Key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
pprint --title "Add Docker Repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
pprint --title "Update Apt Index"
sudo apt-get update
pprint --title "Install Docker Packages"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
pprint --info "Test Docker Installation"
sudo docker run hello-world
pprint --panel "Docker Installation Done!"

pprint --title "Docker Group"
pprint --info "Add Docker Group"
sudo groupadd docker
pprint --info "Add User to Docker Group"
sudo usermod -aG docker "$USER"
pprint --info "Enable Docker Group"
newgrp docker
pprint --info "Test Docker Group"
docker run hello-world
pprint --panel "Docker Group Creation Done!"

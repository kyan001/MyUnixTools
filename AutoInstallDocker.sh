#! /usr/bin/env bash
echo "[Info] Remove Old Docker Installations"
sudo apt-get remove docker docker-engine docker.io containerd runc
echo "[Info] Install Necessary Libs"
sudo apt-get install ca-certificates curl gnupg lsb-release
echo "[Info] Create Keyrings Folder"
sudo mkdir -p /etc/apt/keyrings
echo "[Info] Add Docker GPG Key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "[Info] Add Docker Repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "[Info] Update Apt Index"
sudo apt-get update
echo "[Info] Install Docker Packages"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
echo "[Info] Test Docker Installation"
sudo docker run hello-world
echo "[Info] Docker Installation Done!"

echo "[Info] Add Docker Group"
sudo groupadd docker
echo "[Info] Add User to Docker Group"
sudo usermod -aG docker "$USER"
echo "[Info] Enable Docker Group"
newgrp docker
echo "[Info] Test Docker Group"
docker run hello-world
echo "[Info] Docker Group Creation Done!"

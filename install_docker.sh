#!/bin/bash
#
# This script automates the installation of Docker Engine on Ubuntu 24.04.
# It follows the official Docker installation guide.
#
# Usage:
# 1. Save this script as install_docker.sh
# 2. Make it executable: chmod +x install_docker.sh
# 3. Run it with sudo: sudo ./install_docker.sh

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Docker installation for Ubuntu 24.04 ---"

# 1. Uninstall old versions of Docker if they exist
echo "[Step 1/6] Uninstalling old Docker versions..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  if dpkg -l | grep -q $pkg; then
    sudo apt-get remove -y $pkg
  fi
done
echo "--- Old versions removed."

# 2. Set up Docker's apt repository.
echo "[Step 2/6] Setting up Docker's APT repository..."
# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Use the following command to set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "--- Repository setup complete."

# 3. Install Docker Engine
echo "[Step 3/6] Installing Docker Engine..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "--- Docker Engine installation complete."

# 4. Verify that the Docker Engine installation is successful by running the hello-world image.
echo "[Step 4/6] Verifying installation by running hello-world container..."
sudo docker run hello-world
echo "--- Verification complete."

# 5. Manage Docker as a non-root user (Optional but recommended)
echo "[Step 5/6] Adding current user to the 'docker' group..."
# Create the docker group if it doesn't exist
if ! getent group docker > /dev/null; then
  sudo groupadd docker
fi

# Add your user to the docker group.
sudo usermod -aG docker $USER
echo "--- User '$USER' added to the 'docker' group."

# 6. Final instructions
echo "[Step 6/6] Installation finished!"
echo ""
echo "######################################################################"
echo "### IMPORTANT: To apply the new group membership, you must log out ###"
echo "### and log back in, or run the following command: newgrp docker   ###"
echo "######################################################################"
echo ""


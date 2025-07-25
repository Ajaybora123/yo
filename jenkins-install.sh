#!/bin/bash
# Jenkins installation script for Ubuntu/Debian-based systems

set -e

# Update system
sudo apt-get update

# Install Java (Jenkins requirement)
sudo apt-get install -y fontconfig openjdk-17-jre

# Add Jenkins repository and key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Start and enable Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins installation complete."
echo "Access Jenkins at: http://localhost:8080"
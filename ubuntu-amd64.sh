#!/bin/bash
user="$(id -un 2>/dev/null || true)"

# Base
sudo apt update
sudo apt install snapd curl wget -y
sudo systemctl enable --now snapd.socket

# Git
sudo apt install git -y

# OpenJDK
sudo apt install openjdk-8-jdk -y
sudo touch /etc/profile.d/openjdk-path.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee /etc/profile.d/openjdk-path.sh

# Maven
sudo apt install maven -y

# Node
sudo snap install node --channel=10/stable --classic

# Docker
if [ -z "$(docker --version)" ]
then
  sudo curl -sSL https://get.docker.com | sh
fi
sudo apt install docker-compose -y
sudo usermod -aG docker $user

# MySQL Workbench
apt install mysql-workbench -y

# Postman
sudo snap install postman --candidate

# Google Chrome
if [ -z "$(google-chrome --version)" ]
then
  wget -O google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable.deb
  rm -f google-chrome-stable.deb
fi

# Visual Studio Code
sudo snap install code --classic
code_extensions=( \
  "PKief.material-icon-theme" \
  "CoenraadS.bracket-pair-colorizer" \
  "HookyQR.beautify" \
  "pflannery.vscode-versionlens" \
  "eamodio.gitlens" \
  "vscjava.vscode-java-pack" \
  "Pivotal.vscode-spring-boot" \
  "GabrielBB.vscode-lombok" \
  "octref.vetur" \
  "vuetifyjs.vuetify-vscode" \
  "sysoev.language-stylus" \
  "PeterJausovec.vscode-docker" \
  "msjsdiag.debugger-for-chrome" \
  "ritwickdey.LiveServer" \
)
i=0
while [ $i != ${#code_extensions[@]} ]
do
  /snap/bin/code --install-extension ${code_extensions[$i]}
  let "i++"
done

# Reboot
echo "Done, please reboot your system."

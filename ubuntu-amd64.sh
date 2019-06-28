#!/bin/bash
current_user="$(id -un 2>/dev/null || true)"

# Base
sudo apt update
sudo apt install snapd flatpak curl wget git -y
sudo systemctl enable --now snapd.socket
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# OpenJDK
sudo apt install openjdk-8-jdk -y
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee /etc/profile.d/openjdk-path.sh

# Maven
sudo apt install maven -y

# Node
echo "Installing node snap..."
sudo snap install node --channel=10/stable --classic

# Docker
if [ -z "$(docker --version)" ]
then
  sudo curl -sSL https://get.docker.com | sh
fi
sudo apt install docker-compose -y
sudo usermod -aG docker $current_user

# MySQL Workbench
sudo apt install mysql-workbench -y

# Postman
echo "Installing postman snap..."
sudo snap install postman --candidate

# Google Chrome
if [ -z "$(google-chrome --version)" ]
then
  wget -O google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable.deb
  rm -f google-chrome-stable.deb
  sudo apt install -fy
fi

# Visual Studio Code
echo "Installing code snap..."
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
  "ms-azuretools.vscode-docker" \
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

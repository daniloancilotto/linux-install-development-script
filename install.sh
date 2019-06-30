#!/bin/bash
args=("$@")
arch="amd64"
if [ "$(uname -m)" != "x86_64" ]
then
  arch="i386"
fi

echo "DEVELOPMENT ENVIRONMENT SCRIPT"
echo "Arguments: [$args]"
echo "Architecture: $arch"
echo "Interface: $DESKTOP_SESSION"
echo "User: $USER"
echo "Home: $HOME"
echo "Author: Danilo Ancilotto"

# Functions
dpkgInstall() {
  file="$HOME/$1"
  wget -O "$file" "$2"
  sudo dpkg -i "$file"
  rm -fv "$file"
  sudo apt install -fy
}

# Base
sudo apt update
sudo apt install snapd flatpak curl wget git unzip tar neofetch htop -y
sudo systemctl enable --now snapd.socket
sudo flatpak remote-add --if-not-exists flathub "https://dl.flathub.org/repo/flathub.flatpakrepo"

# OpenJDK
sudo apt install openjdk-8-jdk -y
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-$arch" | sudo tee "/etc/profile.d/openjdk-path.sh"

# Maven
sudo apt install maven -y

# Node
echo "Installing node snap..."
sudo snap install node --channel=10/stable --classic

# Docker
if [ -z "$(docker --version)" ]
then
  sudo curl -sSL "https://get.docker.com" | sh
fi
sudo apt install docker-compose -y
sudo usermod -aG docker $USER

# MySQL Workbench
sudo apt install mysql-workbench -y

# Postman
echo "Installing postman snap..."
sudo snap install postman --candidate

# Google Chrome
if [ -z "$(google-chrome --version)" ]
then
  dpkgInstall "google-chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_$arch.deb"
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
  /snap/bin/code --install-extension "${code_extensions[$i]}"
  
  let "i++"
done

# Reboot
echo "Done, please reboot your system."

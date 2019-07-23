#!/bin/bash
system="`lsb_release -sd`"
system_id="`lsb_release -si`"
system_version="`lsb_release -sr`"
system_release="$system_version"
if [ "$system_id" == "LinuxMint" ]
then
  case "$system_version" in
    "19.1"|"19.2")
      system_release="18.04"
    ;;
    *)
      system_release="19.04"
    ;;
  esac
fi

arch="amd64"
if [ "`uname -m`" != "x86_64" ]
then
  arch="i386"
fi

echo "DEVELOPMENT ENVIRONMENT SCRIPT - UBUNTU $system_release"
echo "Author: Danilo Ancilotto"
echo "System: $system"
echo "Architecture: $arch"
echo "Home: $HOME"
echo "User: $USER"

printLine() {
  text="$1"
  if [ ! -z "$text" ]
  then
    text="$text "
  fi
  lenght=${#text}
  sudo echo ""
  echo -n "$text"
  for i in {1..80}
  do
    if [ $i -gt $lenght ]
    then
      echo -n "="
    fi
  done
  echo ""
}

dpkgInstall() {
  file="$HOME/$1"
  wget -O "$file" "$2"
  sudo dpkg -i "$file"
  rm -fv "$file"
  sudo apt install -fy
}

printLine "Base Apps"
sudo apt update
sudo apt install wget unzip tar jq neofetch htop -y

printLine "App Hubs"
sudo apt install snapd flatpak -y
sudo systemctl enable --now snapd.socket
sudo flatpak remote-add --if-not-exists flathub "https://dl.flathub.org/repo/flathub.flatpakrepo"
autostart_dir="$HOME/.config/autostart"
mkdir -pv "$autostart_dir"

printLine "OpenJDK"
sudo apt install openjdk-8-jdk -y
java_dir="/usr/lib/jvm/java-8-openjdk-$arch"

printLine "Git"
sudo apt install git -y

printLine "Maven"
sudo apt install maven -y

printLine "Node"
echo "Running snap, please wait..."
sudo snap install node --channel=10/stable --classic

printLine "Docker"
if [ -z "`docker --version`" ]
then
  sudo curl -sSL "https://get.docker.com" | sh
else
  echo "docker is already installed"
fi
sudo apt install docker-compose -y
sudo usermod -aG docker $USER

printLine "MySQL Workbench"
if [ -z "`mysql-workbench --version`" ]
then
  dpkgInstall "mysql-workbench.deb" "https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_8.0.17-1ubuntu$system_release$'_'$arch.deb"
else
  echo "mysql-workbench is already installed"
fi

printLine "Postman"
echo "Running snap, please wait..."
sudo snap install postman --candidate

printLine "Google Chrome"
if [ -z "`google-chrome --version`" ]
then
  dpkgInstall "google-chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_$arch.deb"
else
  echo "google-chrome is already installed"
fi

printLine "Visual Studio Code"

echo "Running snap, please wait..."
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

file="$HOME/.config/Code/User/settings.json"
json="`cat "$file"`"
if [ -z "$json" ]
then
  json="{}"
  json="`echo "$json" | jq '."workbench.iconTheme"="material-icon-theme"'`"
  json="`echo "$json" | jq '."workbench.startupEditor"="none"'`"
  json="`echo "$json" | jq '."editor.minimap.enabled"=false'`"
  json="`echo "$json" | jq '."editor.suggestSelection"="first"'`"
  json="`echo "$json" | jq '."extensions.showRecommendationsOnlyOnDemand"=true'`"
  json="`echo "$json" | jq '."terminal.integrated.fontSize"=13'`"
  json="`echo "$json" | jq '."debug.console.fontSize"=13'`"
  json="`echo "$json" | jq '."debug.internalConsoleOptions"="neverOpen"'`"
  json="`echo "$json" | jq '."debug.openDebug"="neverOpen"'`"
  json="`echo "$json" | jq '."debug.showInStatusBar"="never"'`"
  json="`echo "$json" | jq '."liveServer.settings.donotShowInfoMsg"=true'`"
  json="`echo "$json" | jq '."java.configuration.checkProjectSettingsExclusions"=false'`"
  json="`echo "$json" | jq '."java.configuration.updateBuildConfiguration"="automatic"'`"
fi
json="`echo "$json" | jq '."java.home"="'$java_dir'"'`"
json="`echo "$json" | jq '."spring-boot.ls.java.home"="'$java_dir'"'`"
json="`echo "$json" | jq '."maven.terminal.useJavaHome"=true'`"
echo "$json" > "$file"

sudo rm -fv "/etc/profile.d/openjdk-path.sh"

echo "code have been configured"

printLine "Slack"

if [ ! -f "/usr/bin/slack" ]
then
  dpkgInstall "slack.deb" "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.0-$arch.deb"
else
  echo "slack is already installed"
fi

file="$autostart_dir/slack.desktop"
if [ ! -f "$file" ]
then
  conf=$'[Desktop Entry]\n'
  conf+=$'Name=Slack\n'
  conf+=$'Comment=Slack Desktop\n'
  conf+=$'GenericName=Slack Client for Linux\n'
  conf+=$'Exec=/usr/bin/slack --startup %U\n'
  conf+=$'Icon=/usr/share/pixmaps/slack.png\n'
  conf+=$'Type=Application\n'
  conf+=$'StartupNotify=true\n'
  conf+=$'Categories=GNOME;GTK;Network;InstantMessaging;\n'
  conf+=$'MimeType=x-scheme-handler/slack;\n'
  echo "$conf" > "$file"
else
  sed -i 's/\/usr\/bin\/slack %U/\/usr\/bin\/slack --startup %U/g' "$file"
fi

echo "slack have been configured"

printLine "Zoiper5"

if [ ! -f "/usr/local/applications/Zoiper5/zoiper" ]
then
  dpkgInstall "zoiper5.deb" "https://www.dropbox.com/s/dojmaltc6kanlrt/zoiper5_5.2.28_$arch.deb"
else
  echo "zoiper5 is already installed"
fi

file="$autostart_dir/Zoiper5.desktop"
if [ ! -f "$file" ]
then
  conf=$'[Desktop Entry]\n'
  conf+=$'Encoding=UTF-8\n'
  conf+=$'Name=Zoiper5\n'
  conf+=$'Comment=VoIP Softphone\n'
  conf+=$'Exec=/usr/local/applications/Zoiper5/zoiper\n'
  conf+=$'Terminal=false\n'
  conf+=$'Icon=/usr/share/pixmaps/zoiper5.png\n'
  conf+=$'Type=Application\n'
  echo "$conf" > "$file"
else
  sed -i ':a;N;$!ba;s/Icon=\n/Icon=\/usr\/share\/pixmaps\/zoiper5.png\n/g' "$file"
fi

file="/usr/share/applications/zoiper5.desktop"
if [ -f "$file" ]
then
  sudo sed -i 's/Name=zoiper5/Name=Zoiper5/g' "$file"
fi

echo "zoiper5 have been configured"

printLine "Finished"
echo "Done, please reboot your system."
echo ""
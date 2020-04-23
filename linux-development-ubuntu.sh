#!/bin/bash
system="`lsb_release -sd`"
architecture="`uname -m`"

echo "LINUX DEVELOPMENT UBUNTU"
echo "Author: Danilo Ancilotto"
echo "System: $system"
echo "Architecture: $architecture"
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

printLine "Base"

sudo apt update
sudo apt install wget unzip tar jq neofetch htop snapd -y
sudo systemctl enable --now snapd.socket

desktop_dir="$HOME/.local/share/applications"
mkdir -pv "$desktop_dir"
autostart_dir="$HOME/.config/autostart"
mkdir -pv "$autostart_dir"

printLine "OpenJDK"
sudo apt install openjdk-8-jdk openjdk-11-jdk -y
java8_dir="/usr/lib/jvm/java-8-openjdk-amd64"
java11_dir="/usr/lib/jvm/java-11-openjdk-amd64"

printLine "Git"
sudo apt install git -y

printLine "Maven"
sudo apt install maven -y

printLine "Node"
echo "Running snap, please wait..."
sudo snap install node --channel=12/stable --classic
sudo snap switch node --channel=12/stable
sudo snap refresh node

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
  dpkgInstall "mysql-workbench.deb" "https://www.dropbox.com/s/tk99jp28k9xw1ue/mysql-workbench-community_8.0.19_amd64.deb"
else
  echo "mysql-workbench is already installed"
fi
sudo apt install libproj-dev -y

printLine "Postman"
echo "Running snap, please wait..."
sudo snap install postman

printLine "Google Chrome"
if [ -z "`google-chrome --version`" ]
then
  dpkgInstall "google-chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
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
  "ms-azuretools.vscode-docker" \
  "msjsdiag.debugger-for-chrome" \
  "ritwickdey.LiveServer" \
)
i=0
while [ $i != ${#code_extensions[@]} ]
do
  snap run code --install-extension "${code_extensions[$i]}"
  
  let "i++"
done

file="$HOME/.config/Code/User/settings.json"
json="`cat "$file"`"
if [ -z "$json" ]
then
  json="{}"
  json="`echo "$json" | jq '."workbench.startupEditor"="none"'`"
  json="`echo "$json" | jq '."workbench.iconTheme"="material-icon-theme"'`"
  json="`echo "$json" | jq '."breadcrumbs.enabled"=false'`"
  json="`echo "$json" | jq '."editor.minimap.enabled"=false'`"
fi
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
json="`echo "$json" | jq '."java.configuration.runtimes"=[]'`"
json="`echo "$json" | jq '."java.configuration.runtimes"+=[{"name":"JavaSE-1.8","path":"'$java8_dir'"}]'`"
json="`echo "$json" | jq '."java.configuration.runtimes"+=[{"name":"JavaSE-11","path":"'$java11_dir'","default":true}]'`"
json="`echo "$json" | jq '."java.home"="'$java11_dir'"'`"
json="`echo "$json" | jq '."spring-boot.ls.java.home"="'$java11_dir'"'`"
json="`echo "$json" | jq '."maven.terminal.useJavaHome"=true'`"
echo "$json" > "$file"

inotify_watches="524288"
if [ "`cat /proc/sys/fs/inotify/max_user_watches`" != "$inotify_watches" ]
then
  echo "fs.inotify.max_user_watches=$inotify_watches" | sudo tee "/etc/sysctl.d/60-inotify-watches.conf"
  sudo sysctl -p
fi

echo "code have been configured"

printLine "Slack"

echo "Running snap, please wait..."
sudo snap install slack --classic

file="$autostart_dir/slack.desktop"
if [ ! -f "$file" ]
then
  desk=$'[Desktop Entry]\n'
  desk+=$'Name=Slack\n'
  desk+=$'Comment=Slack Desktop\n'
  desk+=$'GenericName=Slack Client for Linux\n'
  desk+=$'Exec=env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/slack_slack.desktop /snap/bin/slack --startup %U\n'
  desk+=$'Icon=/snap/slack/current/usr/share/pixmaps/slack.png\n'
  desk+=$'Type=Application\n'
  desk+=$'X-SnapInstanceName=slack\n'
  desk+=$'StartupWMClass=Slack\n'
  desk+=$'StartupNotify=true\n'
  desk+=$'Categories=GNOME;GTK;Network;InstantMessaging;\n'
  desk+=$'MimeType=x-scheme-handler/slack;\n'
  echo "$desk" > "$file"
else
  sed -i 's/\/snap\/bin\/slack %U/\/snap\/bin\/slack --startup %U/g' "$file"
fi

echo "slack have been configured"

printLine "Zoiper5"

if [ ! -f "/usr/local/applications/Zoiper5/zoiper" ]
then
  dpkgInstall "zoiper5.deb" "https://www.dropbox.com/s/qslfyc416knkr3s/zoiper5_5.3.8_amd64.deb"
else
  echo "zoiper5 is already installed"
fi

file="$autostart_dir/Zoiper5.desktop"
if [ ! -f "$file" ]
then
  desk=$'[Desktop Entry]\n'
  desk+=$'Encoding=UTF-8\n'
  desk+=$'Name=Zoiper5\n'
  desk+=$'Comment=VoIP Softphone\n'
  desk+=$'Exec=/usr/local/applications/Zoiper5/zoiper\n'
  desk+=$'Terminal=false\n'
  desk+=$'Icon=/usr/share/pixmaps/zoiper5.png\n'
  desk+=$'Type=Application\n'
  echo "$desk" > "$file"
else
  sed -i ':a;N;$!ba;s/Icon=\n/Icon=\/usr\/share\/pixmaps\/zoiper5.png\n/g' "$file"
fi

file="zoiper5.desktop"
origin_file="/usr/share/applications/$file"
target_file="$desktop_dir/$file"
if [ -f "$origin_file" ] && [ ! -f "$target_file" ]
then
  cp "$origin_file" "$target_file"
fi
if [ -f "$target_file" ]
then
  sed -i 's/Name=zoiper5/Name=Zoiper5/g' "$target_file"
fi

echo "zoiper5 have been configured"

printLine "Finished"
echo "Done, please reboot your system."
echo ""
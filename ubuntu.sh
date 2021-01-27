#!/bin/bash
system="`lsb_release -sd`"
architecture="`uname -m`"

echo "LINUX DEVELOPMENT SCRIPT (UBUNTU)"
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

desktopConf() {
  source_file="/usr/share/applications/$2"
  target_file="$1/$2"
  if [ -f "$source_file" ] && [ ! -f "$target_file" ]
  then
    cp "$source_file" "$target_file"
  fi
  if [ -f "$target_file" ]
  then
    crudini --set "$target_file" "Desktop Entry" "$3" "$4"
  fi
}

printLine "Update"
sudo apt update

desktop_dir="$HOME/.local/share/applications"
mkdir -pv "$desktop_dir"

autostart_dir="$HOME/.config/autostart"
mkdir -pv "$autostart_dir"

autostart_scripts_dir="$HOME/.config/autostart-scripts"
mkdir -pv "$autostart_scripts_dir"

portable_dir="$HOME/Applications"
mkdir -pv "$portable_dir"

printLine "Language Pack Pt"
sudo apt install language-pack-pt language-pack-gnome-pt -y

printLine "Snap"

sudo apt install snapd -y

sudo systemctl enable --now snapd.socket
sudo snap set system refresh.timer=mon,04:00

snap_cronjob="@reboot /usr/bin/sudo /usr/bin/snap refresh"
if [ -z "$(sudo crontab -l | grep -F "$snap_cronjob")" ]
then
  (sudo crontab -l 2>/dev/null; echo "$snap_cronjob") | sudo crontab -
fi

echo "snap have been configured"

printLine "Wget"
sudo apt install wget -y

printLine "Crudini"
sudo apt install crudini -y

printLine "Jq"
sudo apt install jq -y

printLine "Seahorse"

sudo apt install seahorse -y

file="$autostart_dir/gnome-keyring-pkcs11.desktop"
if [ ! -f "$file" ]
then
  cp "/etc/xdg/autostart/gnome-keyring-pkcs11.desktop" "$autostart_dir"
  sed -i '/^OnlyShowIn.*$/d' "$file"
fi
file="$autostart_dir/gnome-keyring-secrets.desktop"
if [ ! -f "$file" ]
then
  cp "/etc/xdg/autostart/gnome-keyring-secrets.desktop" "$autostart_dir"
  sed -i '/^OnlyShowIn.*$/d' "$file"
fi
file="$autostart_dir/gnome-keyring-ssh.desktop"
if [ ! -f "$file" ]
then
  cp "/etc/xdg/autostart/gnome-keyring-ssh.desktop" "$autostart_dir"
  sed -i '/^OnlyShowIn.*$/d' "$file"
fi

echo "seahorse have been configured"

printLine "Kssh Askpass"

sudo apt install ksshaskpass -y

file="$autostart_scripts_dir/ssh-askpass.sh"
if [ ! -f "$file" ]
then
  conf=$'#!/bin/bash\n'
  conf+=$'export SSH_ASKPASS=/usr/bin/ksshaskpass\n'
  conf+=$'/usr/bin/ssh-add </dev/null\n'
  echo "$conf" | sudo tee "$file"
  sudo chmod +x "$file"
fi

echo "ksshaskpass have been configured"

printLine "Python"
sudo apt install python3 python3-pip python3-tk python3-dev -y

python3_dir="/usr/bin/python3"

printLine "OpenJDK"
sudo apt install openjdk-8-jdk openjdk-11-jdk -y
desktopConf "$desktop_dir" "openjdk-8-policytool.desktop" "NoDisplay" "true"
echo "openjdk have been configured"

java8_dir="/usr/lib/jvm/java-8-openjdk-amd64"
java11_dir="/usr/lib/jvm/java-11-openjdk-amd64"

printLine "Git"
sudo apt install git -y

printLine "Maven"
sudo apt install maven -y

printLine "Node"

snap_channel="14/stable"

echo "Running snap, please wait..."
sudo snap install node --channel=$snap_channel --classic

if [[ "`snap list node`" != *" $snap_channel "* ]]
then
  sudo snap switch node --channel=$snap_channel
  sudo snap refresh node
fi

echo "node have been configured"

printLine "Docker"
sudo apt install docker docker-compose -y
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

printLine "MySQL Client"
sudo apt install mysql-client -y

printLine "MySQL Workbench"

portable_name="mysql-workbench"
portable_subdir="$portable_dir/$portable_name"
portable_cversion="`cat "$portable_subdir/version.txt"`"
portable_dropbox_path="84o4fbqicv786et"
portable_version="8.0.23"

if [ "$portable_cversion" != "$portable_version" ]
then
  rm -rf "$portable_subdir"

  sudo apt remove mysql-workbench-community -y
fi

if [ -z "`mysql-workbench --version`" ]
then
  dpkgInstall "mysql-workbench.deb" "https://www.dropbox.com/s/$portable_dropbox_path/mysql-workbench-community_$portable_version-1ubuntu20.04_amd64.deb"

  mkdir -pv "$portable_subdir"
  echo "$portable_version" > "$portable_subdir/version.txt"
else
  echo "mysql-workbench is already installed"
fi

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
  "pkief.material-icon-theme" \
  "coenraads.bracket-pair-colorizer-2" \
  "eamodio.gitlens" \
  "ms-python.python" \
  "ms-python.vscode-pylance" \
  "vscjava.vscode-java-pack" \
  "pivotal.vscode-spring-boot" \
  "gabrielbb.vscode-lombok" \
  "octref.vetur" \
  "vuetifyjs.vuetify-vscode" \
  "dbaeumer.vscode-eslint" \
  "ms-azuretools.vscode-docker" \
  "ritwickdey.liveserver" \
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
fi
json="`echo "$json" | jq '."workbench.startupEditor"="none"'`"
json="`echo "$json" | jq '."workbench.iconTheme"="material-icon-theme"'`"
json="`echo "$json" | jq '."extensions.showRecommendationsOnlyOnDemand"=true'`"
json="`echo "$json" | jq '."window.zoomLevel"=0'`"
json="`echo "$json" | jq '."editor.minimap.enabled"=false'`"
json="`echo "$json" | jq '."editor.suggestSelection"="first"'`"
json="`echo "$json" | jq '."diffEditor.ignoreTrimWhitespace"=false'`"
json="`echo "$json" | jq '."terminal.integrated.fontSize"=13'`"
json="`echo "$json" | jq '."debug.console.fontSize"=13'`"
json="`echo "$json" | jq '."debug.internalConsoleOptions"="neverOpen"'`"
json="`echo "$json" | jq '."debug.openDebug"="neverOpen"'`"
json="`echo "$json" | jq '."debug.showInStatusBar"="never"'`"
json="`echo "$json" | jq '."git.confirmSync"=false'`"
json="`echo "$json" | jq '."git.fetchOnPull"=true'`"
json="`echo "$json" | jq '."python.showStartPage"=false'`"
json="`echo "$json" | jq '."python.languageServer"="Pylance"'`"
json="`echo "$json" | jq '."python.pythonPath"="'$python3_dir'"'`"
json="`echo "$json" | jq '."java.semanticHighlighting.enabled"=true'`"
json="`echo "$json" | jq '."java.configuration.checkProjectSettingsExclusions"=false'`"
json="`echo "$json" | jq '."java.configuration.updateBuildConfiguration"="automatic"'`"
json="`echo "$json" | jq '."java.project.importOnFirstTimeStartup"="automatic"'`"
json="`echo "$json" | jq '."java.refactor.renameFromFileExplorer"="autoApply"'`"
json="`echo "$json" | jq '."java.configuration.runtimes"=[]'`"
json="`echo "$json" | jq '."java.configuration.runtimes"+=[{"name":"JavaSE-1.8","path":"'$java8_dir'"}]'`"
json="`echo "$json" | jq '."java.configuration.runtimes"+=[{"name":"JavaSE-11","path":"'$java11_dir'","default":true}]'`"
json="`echo "$json" | jq '."java.home"="'$java11_dir'"'`"
json="`echo "$json" | jq '."spring-boot.ls.java.home"="'$java11_dir'"'`"
json="`echo "$json" | jq '."maven.terminal.useJavaHome"=true'`"
json="`echo "$json" | jq '."liveServer.settings.donotShowInfoMsg"=true'`"
echo "$json" > "$file"

inotify_watches="524288"
if [ "`cat /proc/sys/fs/inotify/max_user_watches`" != "$inotify_watches" ]
then
  echo "fs.inotify.max_user_watches=$inotify_watches" | sudo tee "/etc/sysctl.d/60-inotify-watches.conf"
  sudo sysctl -p
fi

echo "code have been configured"

printLine "Zoiper5"

portable_name="zoiper5"
portable_subdir="$portable_dir/$portable_name"
portable_cversion="`cat "$portable_subdir/version.txt"`"
portable_dropbox_path="p2nmgamqjz4anuz"
portable_version="5.4.10"

if [ "$portable_cversion" != "$portable_version" ]
then
  rm -rf "$portable_subdir"

  sudo apt remove zoiper5 -y
fi

if [ ! -f "/usr/local/applications/Zoiper5/zoiper" ]
then
  dpkgInstall "zoiper5.deb" $'https://www.dropbox.com/s/'$portable_dropbox_path$'/zoiper5_'$portable_version$'_x86_64.deb'

  mkdir -pv "$portable_subdir"
  echo "$portable_version" > "$portable_subdir/version.txt"
else
  echo "zoiper5 is already installed"
fi

desktopConf "$desktop_dir" "zoiper5.desktop" "Name" "Zoiper5"

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
  crudini --set "$file" "Desktop Entry" "Icon" "/usr/share/pixmaps/zoiper5.png"
fi

echo "zoiper5 have been configured"

printLine "Finished"
echo "Please reboot your system."
echo ""
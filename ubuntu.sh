#!/bin/bash
system="`lsb_release -sd`"
system_release="`lsb_release -sr`"
system_architecture="`uname -m`"

echo "LINUX DEVELOPMENT SCRIPT (UBUNTU)"
echo "Author: Danilo Ancilotto"
echo "System: $system"
echo "Architecture: $system_architecture"
echo "Home: $HOME"
echo "User: $USER"
sudo echo -n ""

printLine() {
  text="$1"
  if [ ! -z "$text" ]
  then
    text="$text "
  fi
  length=${#text}
  sudo echo ""
  echo -n "$text"
  for i in {1..80}
  do
    if [ $i -gt $length ]
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

menuConf() {
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

python3_dir="/usr/bin/python3"
java8_dir="/usr/lib/jvm/java-8-openjdk-amd64"
java11_dir="/usr/lib/jvm/java-11-openjdk-amd64"

root_app_dir="/root/Applications"
sudo mkdir -pv "$root_app_dir"

home_menu_dir="$HOME/.local/share/applications"
mkdir -pv "$home_menu_dir"

home_autostart_dir="$HOME/.config/autostart"
mkdir -pv "$home_autostart_dir"

home_autostart_scripts_dir="$HOME/.config/autostart-scripts"
mkdir -pv "$home_autostart_scripts_dir"

printLine "Update"
sudo apt update

printLine "Kernel"

swappiness="10"
if [ "`cat /proc/sys/vm/swappiness`" != "$swappiness" ]
then
  file="/etc/sysctl.d/60-swappiness.conf"
  echo "vm.swappiness=$swappiness" | sudo tee "$file"
  sudo sysctl -p "$file"
fi

cache_pressure="50"
if [ "`cat /proc/sys/vm/vfs_cache_pressure`" != "$cache_pressure" ]
then
  file="/etc/sysctl.d/60-cache-pressure.conf"
  echo "vm.vfs_cache_pressure=$cache_pressure" | sudo tee "$file"
  sudo sysctl -p "$file"
fi

inotify_watches="524288"
if [ "`cat /proc/sys/fs/inotify/max_user_watches`" != "$inotify_watches" ]
then
  file="/etc/sysctl.d/60-inotify-watches.conf"
  echo "fs.inotify.max_user_watches=$inotify_watches" | sudo tee "$file"
  sudo sysctl -p "$file"
fi

echo "kernel have been configured"

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

file="$home_autostart_dir/gnome-keyring-pkcs11.desktop"
if [ ! -f "$file" ]
then
  cp "/etc/xdg/autostart/gnome-keyring-pkcs11.desktop" "$home_autostart_dir"
  sed -i '/^OnlyShowIn.*$/d' "$file"
fi
file="$home_autostart_dir/gnome-keyring-secrets.desktop"
if [ ! -f "$file" ]
then
  cp "/etc/xdg/autostart/gnome-keyring-secrets.desktop" "$home_autostart_dir"
  sed -i '/^OnlyShowIn.*$/d' "$file"
fi
file="$home_autostart_dir/gnome-keyring-ssh.desktop"
if [ ! -f "$file" ]
then
  cp "/etc/xdg/autostart/gnome-keyring-ssh.desktop" "$home_autostart_dir"
  sed -i '/^OnlyShowIn.*$/d' "$file"
fi

echo "seahorse have been configured"

printLine "Kssh Askpass"

sudo apt install ksshaskpass -y

file="$home_autostart_scripts_dir/ssh-askpass.sh"
if [ ! -f "$file" ]
then
  conf=$'#!/bin/bash\n'
  conf+=$'export SSH_ASKPASS=/usr/bin/ksshaskpass\n'
  conf+=$'/usr/bin/ssh-add </dev/null\n'
  echo "$conf" | sudo tee "$file"
  sudo chmod +x "$file"
fi

echo "ksshaskpass have been configured"

printLine "NVIDIA X Server Settings"

file="$home_autostart_scripts_dir/nvidia-settings.sh"
if [ ! -f "$file" ]
then
  conf=$'#!/bin/bash\n'
  conf+=$'/usr/bin/nvidia-settings -a [gpu:0]/GpuPowerMizerMode=1\n'
  echo "$conf" | sudo tee "$file"
  sudo chmod +x "$file"
fi

echo "nvidia-settings have been configured"

printLine "Python"
sudo apt install python3 python3-pip python3-tk python3-dev -y

printLine "OpenJDK"

sudo apt install openjdk-8-jdk openjdk-11-jdk -y
menuConf "$home_menu_dir" "openjdk-8-policytool.desktop" "NoDisplay" "true"

echo "openjdk have been configured"

printLine "Git"
sudo apt install git -y

printLine "Maven"
sudo apt install maven -y

printLine "Node"

node_channel="14/stable"

echo "Running snap, please wait..."
sudo snap install node --channel=$node_channel --classic

if [[ "`snap list node`" != *" $node_channel "* ]]
then
  sudo snap switch node --channel=$node_channel
  sudo snap refresh node
fi

printLine "Docker"

sudo apt install docker docker-compose -y
sudo systemctl enable docker.service

sudo usermod -aG docker $USER

echo "docker have been configured"

printLine "MySQL Client"
sudo apt install mysql-client -y

printLine "MySQL Workbench"

root_app_name="mysql-workbench"
root_app_subdir="$root_app_dir/$root_app_name"
root_app_cversion="`sudo cat "$root_app_subdir/version.txt"`"
root_app_version="8.0.24"

if [ "$root_app_cversion" != "$root_app_version" ]
then
  sudo rm -rf "$root_app_subdir"

  sudo apt remove mysql-workbench-community -y
fi

if [ -z "`mysql-workbench --version`" ]
then
  dpkgInstall "mysql-workbench.deb" $'https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_'$root_app_version$'-1ubuntu'$system_release$'_amd64.deb'

  sudo mkdir -pv "$root_app_subdir"
  echo "$root_app_version" | sudo tee "$root_app_subdir/version.txt"
else
  echo "$root_app_name is already installed"
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
  "pflannery.vscode-versionlens" \
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
json="`echo "$json" | jq '."extensions.ignoreRecommendations"=true'`"
json="`echo "$json" | jq '."window.zoomLevel"=0'`"
json="`echo "$json" | jq '."editor.minimap.enabled"=false'`"
json="`echo "$json" | jq '."editor.suggestSelection"="first"'`"
json="`echo "$json" | jq '."diffEditor.ignoreTrimWhitespace"=false'`"
json="`echo "$json" | jq '."terminal.integrated.fontSize"=13'`"
json="`echo "$json" | jq '."debug.console.fontSize"=13'`"
json="`echo "$json" | jq '."debug.internalConsoleOptions"="neverOpen"'`"
json="`echo "$json" | jq '."debug.openDebug"="neverOpen"'`"
json="`echo "$json" | jq '."debug.showInStatusBar"="never"'`"
json="`echo "$json" | jq '."git.suggestSmartCommit"=false'`"
json="`echo "$json" | jq '."git.confirmSync"=false'`"
json="`echo "$json" | jq '."git.fetchOnPull"=true'`"
json="`echo "$json" | jq '."gitlens.codeLens.authors.enabled"=false'`"
json="`echo "$json" | jq '."gitlens.codeLens.recentChange.enabled"=false'`"
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
json="`echo "$json" | jq '."redhat.telemetry.enabled"=false'`"
echo "$json" > "$file"

echo "code have been configured"

printLine "Zoiper5"

root_app_name="zoiper5"
root_app_subdir="$root_app_dir/$root_app_name"
root_app_cversion="`sudo cat "$root_app_subdir/version.txt"`"
root_app_dropbox_path="3jex7pp5q1ev1b4"
root_app_version="5.4.12"

if [ "$root_app_cversion" != "$root_app_version" ]
then
  sudo rm -rf "$root_app_subdir"

  sudo apt remove zoiper5 -y
fi

if [ ! -f "/usr/local/applications/Zoiper5/zoiper" ]
then
  dpkgInstall "zoiper5.deb" $'https://www.dropbox.com/s/'$root_app_dropbox_path$'/zoiper5_'$root_app_version$'_x86_64.deb'

  sudo mkdir -pv "$root_app_subdir"
  echo "$root_app_version" | sudo tee "$root_app_subdir/version.txt"
else
  echo "$root_app_name is already installed"
fi

file="$home_autostart_dir/Zoiper5.desktop"
if [ ! -f "$file" ]
then
  desk=$'[Desktop Entry]\n'
  desk+=$'Encoding=UTF-8\n'
  desk+=$'Name=Zoiper5\n'
  desk+=$'Comment=VoIP Softphone\n'
  desk+=$'Exec=/usr/local/applications/Zoiper5/zoiper\n'
  desk+=$'Terminal=false\n'
  desk+=$'Icon=/usr/share/pixmaps/Zoiper5.png\n'
  desk+=$'Type=Application\n'
  echo "$desk" > "$file"
else
  crudini --set "$file" "Desktop Entry" "Icon" "/usr/share/pixmaps/Zoiper5.png"
fi

echo "$root_app_name have been configured"

printLine "Finished"
echo "Please reboot your system."
echo ""
#!/bin/bash
system="`lsb_release -sd`"
system_release="`lsb_release -sr`"
system_architecture="`uname -m`"

echo "INSTALL DEVELOPMENT APPS (UBUNTU)"
echo "Version: 2024.10.21-950"
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
  if [ -f "$source_file" ] && [ "$5" != "--no-replace-file" ]
  then
    cp -fv "$source_file" "$target_file"
  fi
  if [ -f "$target_file" ]
  then
    crudini --set "$target_file" "Desktop Entry" "$3" "$4"
  fi
}

python3_dir="/usr/bin/python3"
java8_dir="/usr/lib/jvm/java-8-openjdk-amd64"
java17_dir="/usr/lib/jvm/java-17-openjdk-amd64"

root_app_dir="/root/Applications"
sudo mkdir -pv "$root_app_dir"

home_app_dir="$HOME/Applications"
mkdir -pv "$home_app_dir"

home_menu_dir="$HOME/.local/share/applications"
mkdir -pv "$home_menu_dir"

printLine "Update"
sudo apt update

printLine "Kernel"
sudo apt-mark auto $(apt-mark showmanual | grep -E "^linux-([[:alpha:]]+-)+[[:digit:].]+-[^-]+(|-.+)$")

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

printLine "Wget"
sudo apt install wget -y

printLine "Tar"
sudo apt install tar -y

printLine "Crudini"
sudo apt install crudini -y

printLine "Jq"
sudo apt install jq -y

printLine "Python"
sudo apt install python3 python3-pip python3-tk python3-dev python3-venv python-is-python3 -y

printLine "OpenJDK"

sudo apt install openjdk-8-jdk openjdk-11-jdk openjdk-17-jdk -y
menuConf "$home_menu_dir" "openjdk-8-policytool.desktop" "NoDisplay" "true"

echo "openjdk have been configured"

printLine "Git"
sudo apt install git -y

printLine "Maven"
sudo apt install maven -y

printLine "Node.js"
sudo snap remove node --purge
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs -y

printLine "Docker"

sudo apt install docker.io docker-compose -y

sudo usermod -aG docker $USER

file="/etc/docker/daemon.json"
json="{\"data-root\": \"/home/docker/data\"}"
if [ ! -f "$file" ]
then
  sudo mkdir -pv "/etc/docker"
  sudo mkdir -pv "/home/docker"
  echo "$json" | sudo tee "$file"

  if [ -d "/var/lib/docker" ] && [ ! -d "/home/docker/data" ]
  then
    sudo systemctl stop docker.service
    sudo mv -fv "/var/lib/docker" "/home/docker/data"
    sudo systemctl start docker.service
  fi
fi
sudo systemctl enable docker.service

cronjobs=( \
  "@reboot /usr/bin/sudo /usr/bin/docker volume prune -a -f" \
  "@reboot /usr/bin/sudo /usr/bin/docker image prune -a -f" \
)
i=0
while [ $i != ${#cronjobs[@]} ]
do
  cronjob="${cronjobs[$i]}"

  if [ -z "$(sudo crontab -l | grep -F "$cronjob")" ]
  then
    (sudo crontab -l 2>/dev/null; echo "$cronjob") | sudo crontab -
  fi

  let "i++"
done

echo "docker have been configured"

printLine "MySQL Client"
sudo apt install mysql-client -y

printLine "MySQL Workbench"

root_app_name="mysql-workbench"
root_app_subdir="$root_app_dir/$root_app_name"
root_app_cversion="`sudo cat "$root_app_subdir/version.txt"`"
root_app_version="8.0.38"

if [ "$root_app_cversion" != "$root_app_version" ]
then
  sudo rm -rf "$root_app_subdir"

  sudo apt remove mysql-workbench-community -y
fi

if [ -z "`mysql-workbench --version`" ]
then
  dpkgInstall "mysql-workbench.deb" $'https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_'$root_app_version$'-1ubuntu'$system_release$'_amd64.deb'

  sudo mkdir -pv "$root_app_subdir"

  if [ ! -z "`mysql-workbench --version`" ]
  then
    echo "$root_app_version" | sudo tee "$root_app_subdir/version.txt"
  fi
else
  echo "$root_app_name is already installed"
fi

printLine "Google Chrome"

if [ -z "`google-chrome --version`" ]
then
  dpkgInstall "google-chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
else
  echo "google-chrome is already installed"
fi
menuConf "$home_menu_dir" "google-chrome.desktop" "Exec" "/usr/bin/google-chrome-stable %U --disable-gpu-driver-bug-workarounds --disable-accelerated-2d-canvas"

echo "google-chrome have been configured"

printLine "Postman"

home_app_name="postman"
home_app_subdir="$home_app_dir/$home_app_name"
home_app_cversion="`cat "$home_app_subdir/version.txt"`"
home_app_version="latest"

if [ "$home_app_cversion" != "$home_app_version" ]
then
  rm -rf "$home_app_subdir"
fi

if [ ! -d "$home_app_subdir" ]
then
  file="$home_app_dir/postman-$home_app_version.tar.gz"
  wget -O "$file" "https://dl.pstmn.io/download/$home_app_version/linux_64"
  tar -xzf "$file" -C "$home_app_dir"
  rm -fv "$file"

  mv -fv "$home_app_dir/Postman" "$home_app_subdir"

  if [ -f "$home_app_subdir/Postman" ]
  then
    echo "$home_app_version" > "$home_app_subdir/version.txt"
  fi
else
  echo "$home_app_name is already installed"
fi

file="$home_menu_dir/postman.desktop"
desk=$'[Desktop Entry]\n'
desk+=$'Name=Postman\n'
desk+=$'Exec='$home_app_subdir$'/Postman\n'
desk+=$'Terminal=false\n'
desk+=$'Type=Application\n'
desk+=$'Icon='$home_app_subdir$'/app/icons/icon_128x128.png\n'
desk+=$'Categories=Utility;\n'
echo "$desk" > "$file"

echo "$home_app_name have been configured"

printLine "Visual Studio Code"

sudo snap remove code --purge
if [ -z "`code --version`" ]
then
  echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
  dpkgInstall "code.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
else
  echo "code is already installed"
fi

code_extensions=( \
  "pkief.material-icon-theme" \
  "eamodio.gitlens" \
  "ms-python.python" \
  "ms-python.vscode-pylance" \
  "ms-python.autopep8" \
  "ms-python.pylint" \
  "vscjava.vscode-java-pack" \
  "vmware.vscode-spring-boot" \
  "vscjava.vscode-lombok" \
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
  code --install-extension "${code_extensions[$i]}"
  
  let "i++"
done

file="$HOME/.config/Code/User/settings.json"
json="`cat "$file"`"
if [ -z "$json" ]
then
  json="{}"
fi
json="`echo "$json" | jq '."workbench.startupEditor"="none"'`"
json="`echo "$json" | jq '."workbench.colorTheme"="Default Dark+"'`"
json="`echo "$json" | jq '."workbench.iconTheme"="material-icon-theme"'`"
json="`echo "$json" | jq '."workbench.tree.enableStickyScroll"=false'`"
json="`echo "$json" | jq '."extensions.ignoreRecommendations"=true'`"
json="`echo "$json" | jq '."window.zoomLevel"=0'`"
json="`echo "$json" | jq '."editor.minimap.enabled"=false'`"
json="`echo "$json" | jq '."editor.stickyScroll.enabled"=false'`"
json="`echo "$json" | jq '."editor.suggestSelection"="first"'`"
json="`echo "$json" | jq '."editor.inlineSuggest.enabled"=false'`"
json="`echo "$json" | jq '."editor.bracketPairColorization.enabled"=true'`"
json="`echo "$json" | jq '."editor.foldingMaximumRegions"=65000'`"
json="`echo "$json" | jq '."diffEditor.ignoreTrimWhitespace"=false'`"
json="`echo "$json" | jq '."diffEditor.maxComputationTime"=0'`"
json="`echo "$json" | jq '."search.maxResults"=null'`"
json="`echo "$json" | jq '."terminal.integrated.env.linux"={}'`"
json="`echo "$json" | jq '."terminal.integrated.env.linux"."JAVA_HOME"="'$java17_dir'"'`"
json="`echo "$json" | jq '."terminal.integrated.cursorStyle"="underline"'`"
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
json="`echo "$json" | jq '."python.defaultInterpreterPath"="'$python3_dir'"'`"
json="`echo "$json" | jq '."python.analysis.importFormat"="absolute"'`"
json="`echo "$json" | jq '."python.analysis.autoImportCompletions"=true'`"
json="`echo "$json" | jq '."python.analysis.indexing"=true'`"
json="`echo "$json" | jq '."java.semanticHighlighting.enabled"=true'`"
json="`echo "$json" | jq '."java.configuration.checkProjectSettingsExclusions"=false'`"
json="`echo "$json" | jq '."java.configuration.updateBuildConfiguration"="automatic"'`"
json="`echo "$json" | jq '."java.project.importOnFirstTimeStartup"="automatic"'`"
json="`echo "$json" | jq '."java.compile.nullAnalysis.mode"="automatic"'`"
json="`echo "$json" | jq '."java.inlayHints.parameterNames.enabled"="none"'`"
json="`echo "$json" | jq '."java.refactor.renameFromFileExplorer"="autoApply"'`"
json="`echo "$json" | jq '."java.configuration.runtimes"=[]'`"
json="`echo "$json" | jq '."java.configuration.runtimes"+=[{"name":"JavaSE-1.8","path":"'$java8_dir'"}]'`"
json="`echo "$json" | jq '."java.configuration.runtimes"+=[{"name":"JavaSE-17","path":"'$java17_dir'","default":true}]'`"
json="`echo "$json" | jq '."java.jdt.ls.java.home"="'$java17_dir'"'`"
json="`echo "$json" | jq '."spring-boot.ls.java.home"="'$java17_dir'"'`"
json="`echo "$json" | jq '."maven.terminal.useJavaHome"=true'`"
json="`echo "$json" | jq '."liveServer.settings.donotShowInfoMsg"=true'`"
json="`echo "$json" | jq '."liveServer.settings.donotVerifyTags"=true'`"
json="`echo "$json" | jq '."redhat.telemetry.enabled"=false'`"
json="`echo "$json" | jq '."thunder-client.codeSnippetLanguage"="cs-httpclient"'`"
echo "$json" > "$file"

echo "code have been configured"

printLine "Language Pack"
sudo apt install language-pack-pt language-pack-gnome-pt -y
sudo apt install language-selector-common -y
sudo apt install `check-language-support` -y

printLine "Finished"
echo "Please reboot your system."
echo ""
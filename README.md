# Linux Development Script

### Supported Systems
* Ubuntu and Derivatives
  * [Ubuntu - 18.04 ~ 19.10](https://ubuntu.com/)
  * [Linux Mint - 19.1 ~ 19.2](https://linuxmint.com/)

### Supported Architectures
* Fully
  * amd64 (64-bit)
* Partially
  * i386 (32-bit)

<br/>

# Preparing to Run the Script

### Ubuntu and Derivatives
```bash
sudo apt install curl snapd flatpak -y
```

<br/>

# Running the Script

### Ubuntu and Derivatives
```bash
curl -H 'Cache-Control: no-cache' -sSL https://raw.githubusercontent.com/daniloancilotto/linux-development-script/master/linux-development-ubuntu.sh | bash
```

<br/>

# Installations and Configurations

### Apps
* Base - Latest
  * Wget
  * Unzip
  * Tar
  * Jq
  * Neofetch
  * Htop
  * Configurations
    * Repositories
      * https://dl.flathub.org/repo/flathub.flatpakrepo
    * Directories
      * ~/.config/autostart
* OpenJDK - 8
* Git - Latest
* Maven - Latest
* [Node - 10 (Snap)](https://snapcraft.io/node)
* [Docker - Latest (Script)](https://www.docker.com/)
  * Modules - Latest
    * Compose
  * Configurations
    * User Groups
      * docker
* MySQL Workbench - Latest
* [Postman - Latest (Snap)](https://snapcraft.io/postman)
* [Google Chrome - Latest (Dpkg)](https://www.google.com/chrome/)
* [Visual Studio Code - Latest (Snap)](https://snapcraft.io/code)
  * Extensions - Latest
    * Material Icon Theme
    * Bracket Pair Colorizer
    * Beautify
    * Version Lens
    * GitLens — Git supercharged
    * Java Extension Pack
    * Spring Boot Tools
    * Lombok Annotations Support for VS Code
    * Vetur
    * vuetify-vscode
    * language-stylus
    * Docker
    * Debugger for Chrome
    * Live Server
  * Configurations
    * Conf
      * /etc/sysctl.d/60-inotify-watches.conf
    * Json
      * ~/.config/Code/User/settings.json
* [Slack - 4.1.1 (Dpkg)](https://slack.com/)
  * Configurations
    * Desktop
      * ~/.config/autostart/slack.desktop
* [Zoiper5 - 5.3.4 (Dpkg)](https://www.zoiper.com/)
  * Configurations
    * Desktop
      * ~/.config/autostart/Zoiper5.desktop
      * /usr/share/applications/zoiper5.desktop

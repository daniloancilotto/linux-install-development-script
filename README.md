# Development Environment Script

### Supported Systems
* Ubuntu and Derivatives
  * [Ubuntu - 18.04 ~ 19.04](https://ubuntu.com/)
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
sudo apt install curl -y
```

<br/>

# Running the Script

### Ubuntu and Derivatives
```bash
curl -H 'Cache-Control: no-cache' -sSL https://raw.githubusercontent.com/daniloancilotto/development-environment-script/master/ubuntu.sh | bash
```

<br/>

# Installations and Configurations

### Apps
* Base Apps - Latest
  * Wget
  * Unzip
  * Tar
  * Jq
  * Neofetch
  * Htop
* App Hubs - Latest
  * [Snap](https://snapcraft.io/store)
  * [Flatpak](https://flathub.org/home)
    * Repositories
      * Flathub
* OpenJDK - 8
* Git - Latest
* Maven - Latest
* [Node - 10 (Snap)](https://snapcraft.io/node)
* [Docker - Latest (Script)](https://www.docker.com/)
  * Compose - Latest
  * User Groups
    * docker
* [MySQL Workbench - 8.0.17 (Dpkg)](https://www.mysql.com/products/workbench/)
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
* [Slack - 4.0.2 (Dpkg)](https://slack.com/)
  * Configurations
    * Desktop
      * ~/.config/autostart/slack.desktop
* [Zoiper5 - 5.3.3 (Dpkg)](https://www.zoiper.com/)
  * Configurations
    * Desktop
      * ~/.config/autostart/Zoiper5.desktop
      * /usr/share/applications/zoiper5.desktop

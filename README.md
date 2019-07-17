# Development Environment Script

### Supported Systems
* [Linux Mint - 19.1](https://linuxmint.com/)
  * Cinnamon - 4.0

### Supported Architectures
* amd64 (64-bit)
* i386 (32-bit) - Partially

### Install Apps
* Base Apps - Latest
  * Curl
  * Wget
  * Git
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
* Maven - Latest
* [Node - 10 (Snap)](https://snapcraft.io/node)
* [Docker - Latest (Script)](https://www.docker.com/)
  * Compose - Latest
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
  * User Configurations
    * Json
      * ~/.config/Code/User/settings.json
* [Slack - 4.0.0 (Dpkg)](https://slack.com/)
  * User Configurations
    * Desktop
      * ~/.config/autostart/slack.desktop
* [Zoiper5 - 5.2.28 (Dpkg)](https://www.zoiper.com/)
  * User Configurations
    * Desktop
      * ~/.config/autostart/Zoiper5.desktop
  * Shared Configurations
    * Desktop
      * /usr/share/applications/zoiper5.desktop

<br/>

# Execution Example

```bash
curl -H 'Cache-Control: no-cache' -sSL https://raw.githubusercontent.com/daniloancilotto/development-environment-script/master/install.sh | bash
```

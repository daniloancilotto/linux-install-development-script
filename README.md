# Linux Development Script

### Supported Systems
- [Ubuntu - 20.04 (Base)](https://ubuntu.com/download)

### Supported Architectures
- x86_64 (amd64)

<br/>

# Preparing to Run the Script

### Ubuntu
```bash
sudo apt install curl -y
```

<br/>

# Running the Script

### Ubuntu
```bash
curl -H 'Cache-Control: no-cache' -sSL https://raw.githubusercontent.com/daniloancilotto/linux-development-script/master/ubuntu.sh | bash
```

<br/>

# Installations and Configurations

### Ubuntu
- Language Pack Pt - Latest (Repository)
- Snap - Latest (Repository)
- Wget - Latest (Repository)
- Crudini - Latest (Repository)
- Jq - Latest (Repository)
- Seahorse - Latest (Repository)
  - Autostart
    - ~/.config/autostart/gnome-keyring-pkcs11.desktop
    - ~/.config/autostart/gnome-keyring-secrets.desktop
    - ~/.config/autostart/gnome-keyring-ssh.desktop
- Kssh Askpass - Latest (Repository)
  - Autostart Scripts
    - ~/.config/autostart-scripts/ssh-askpass.sh
- OpenJDK - 8 & 11 (Repository)
  - Desktop
    - ~/.local/share/applications/openjdk-8-policytool.desktop
- Git - Latest (Repository)
- Maven - Latest (Repository)
- [Node - 12 (Snap)](https://snapcraft.io/node)
- Docker - Latest (Repository)
  - Modules
    - Compose
  - User Groups
    - docker
- [MySQL Workbench - 8.0.22 (Dpkg)](https://dev.mysql.com/downloads/workbench/)
- [Postman - Latest (Snap)](https://snapcraft.io/postman)
- [Google Chrome - Latest (Dpkg)](https://www.google.com/chrome/)
- [Visual Studio Code - Latest (Snap)](https://snapcraft.io/code)
  - Extensions
    - Material Icon Theme
    - Bracket Pair Colorizer 2
    - GitLens — Git supercharged
    - Java Extension Pack
    - Spring Boot Tools
    - Lombok Annotations Support for VS Code
    - Vetur
    - vuetify-vscode
    - ESLint
    - Docker
    - Live Server
  - Preferences
    - ~/.config/Code/User/settings.json
  - Watches
    - /etc/sysctl.d/60-inotify-watches.conf
- [Zoiper5 - 5.4.8 (Dpkg)](https://www.zoiper.com/en/voip-softphone/download/current)
  - Desktop
    - ~/.local/share/applications/zoiper5.desktop
  - Autostart
    - ~/.config/autostart/Zoiper5.desktop
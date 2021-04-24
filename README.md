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
- Kernel (Configuration Only)
  - Parameters
    - /etc/sysctl.d/60-swappiness.conf
    - /etc/sysctl.d/60-cache-pressure.conf
    - /etc/sysctl.d/60-inotify-watches.conf
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
- NVIDIA X Server Settings (Configuration Only)
  - Autostart Scripts
    - ~/.config/autostart-scripts/nvidia-settings.sh
- Python - 3 (Repository)
- OpenJDK - 8 & 11 (Repository)
  - Menu
    - ~/.local/share/applications/openjdk-8-policytool.desktop
- Git - Latest (Repository)
- Maven - Latest (Repository)
- [Node - 14 (Snap)](https://snapcraft.io/node)
- Docker - Latest (Repository)
  - Modules
    - Compose
  - User Groups
    - docker
- MySQL Client - Latest (Repository)
- [MySQL Workbench - 8.0.24 (Dpkg)](https://dev.mysql.com/downloads/workbench/)
- [Postman - Latest (Snap)](https://snapcraft.io/postman)
- [Google Chrome - Latest (Dpkg)](https://www.google.com/chrome/)
- [Visual Studio Code - Latest (Snap)](https://snapcraft.io/code)
  - Extensions
    - Material Icon Theme
    - Bracket Pair Colorizer 2
    - GitLens — Git supercharged
    - Python
    - Pylance
    - Java Extension Pack
    - Spring Boot Tools
    - Lombok Annotations Support for VS Code
    - Vetur
    - vuetify-vscode
    - ESLint
    - Version Lens
    - Docker
    - Live Server
  - Preferences
    - ~/.config/Code/User/settings.json
- [Zoiper5 - 5.4.12 (Dpkg)](https://www.zoiper.com/en/voip-softphone/download/current)
  - Autostart
    - ~/.config/autostart/Zoiper5.desktop
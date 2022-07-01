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
- Snap - Latest (Repository)
- Wget - Latest (Repository)
- Crudini - Latest (Repository)
- Jq - Latest (Repository)
- Python - 3 (Repository)
- OpenJDK - 8 & 17 (Repository)
  - Menu
    - ~/.local/share/applications/openjdk-8-policytool.desktop
- Git - Latest (Repository)
- Maven - Latest (Repository)
- [Node - 16 (Snap)](https://snapcraft.io/node)
- Docker - Latest (Repository)
  - Modules
    - Compose
  - User Groups
    - docker
- MySQL Client - Latest (Repository)
- [MySQL Workbench - 8.0.29 (Dpkg)](https://dev.mysql.com/downloads/workbench/)
- [Google Chrome - Latest (Dpkg)](https://www.google.com/chrome/)
- [Visual Studio Code - Latest (Snap)](https://snapcraft.io/code)
  - Extensions
    - Material Icon Theme
    - GitLens — Git supercharged
    - Python
    - Pylance
    - Extension Pack for Java
    - Spring Boot Tools
    - Lombok Annotations Support for VS Code
    - Vetur
    - vuetify-vscode
    - ESLint
    - Version Lens
    - Docker
    - Thunder Client
    - Live Server
  - Preferences
    - ~/.config/Code/User/settings.json
- Language Pack Pt - Latest (Repository)
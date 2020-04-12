# Gaming Setup Scripts for Linux Distributions
[[English]](README.md) [[German]](README_de.md)

---

## About

These installers are designed to run on fresh linux installs.

### What's included:

* Installation preparation for proprietary Nvidia, AMD and/or Intel Drivers
* Lutris ( Uses Lutris Repositories on Debian ; https://github.com/lutris/lutris )
* Wine Staging ( Depending on the distribution from Winehq Repositories )
* DXVK for better Direct X Support ( https://github.com/doitsujin/dxvk )
* DXD3D for better Direct 3D Support ( https://github.com/d3d12/vkd3d )
* Winetricks ( https://github.com/Winetricks/winetricks )
* a few dependencies or helpful resources (for instance windows core fonts)
* Optimizes Copy on Write settings on BTRFS File Systems (if used) to avoid performance problems in games
* Communication Tools: Mumble, Teamspeak 3 and Discord (On Debian it's at the moment just mumble)
* Additional Install script for newest Glorious Eggroll Proton Builds ( https://github.com/GloriousEggroll/proton-ge-custom/releases )

---

## Requirements for GIT Installation

Git has to be installed, to clone the repository.

### 1) Install Git:
* Arch Linux, Manjaro, Artix Linux  
    sudo pacman -S git
* Debian  
    sudo apt install git

### 2) Download the scripts
* This will create the folder linux-gaming and downloads the scripts:  
    git clone https://github.com/exgade/linux-gaming

## Installation

The install Script detects the distribution you're using and sets up the system.

### with autoinstaller:
sudo linux-gaming/autoinstall.sh

### with specific installer:
You can also customize the installation by editing the installer script for your distribution.

---

## Custom Proton Version

There is an installer for the newest Glorious Eggroll Version also, which is having a lot of hotfixes for some games.

This Version will be installed for using in Steam, but you are also able to select it in Lutris.

### Command for installation of ge-proton
* linux-gaming/user_scripts/ge-proton.sh

---

## Update this script

you can use git to pull down a new version of this script:

* cd linux-gaming && git pull && cd ..

---

## Distribution related infos

### For Beginners
* Linux Mint ( https://www.linuxmint.com/ )
* Manjaro ( https://manjaro.org/ )

### For Advanced Users / Also working on these Distros
* Arch Linux
* Artix Linux
* Debian Testing or Sid
* Ubuntu
* Elementary OS

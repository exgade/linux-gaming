# Gaming Setup Scripts for Linux Distributions

---

## About

These installers are designed to run on fresh linux installs.

### What's included:

* Installation preparation for proprietary Nvidia, AMD and/or Intel Drivers
* Lutris ( https://github.com/lutris/lutris )
* Wine Staging ( Depending on the distribution from Winehq Repositories )
* DXVK for better Direct X Support ( https://github.com/doitsujin/dxvk )
* DXD3D for better Direct 3D Support ( https://github.com/d3d12/vkd3d )
* Winetricks ( https://github.com/Winetricks/winetricks )
* a few dependencies or helpful resources (for instance windows core fonts)
* Optimizes Copy on Write settings on BTRFS File Systems (if used) to avoid performance problems in games
* Communication Tools: Mumble, Teamspeak 3 and Discord (On Debian it's at the moment just mumble)

---

## Requirements for GIT Installation

Git has to be installed, to clone the repository.

### Arch Linux, Manjaro, Artix Linux
sudo pacman -S git

### Debian
sudo apt install git

## Installation

The install Script detects the distribution you're using and sets up the system.

### with autoinstaller:
git clone https://github.com/exgade/linux-gaming && sudo ./linux-gaming/autoinstall.sh

### with specific installer:
You can also customize the installation by editing the installer script for your distribution.

---

## Distribution related infos

### For Beginners
* Manjaro ( https://manjaro.org/ )

### For Advanced Users
* Arch Linux
* Artix Linux
* Debian Testing or Sid
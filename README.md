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

---

## Installation

The install Script detects the distribution you're using and sets up the system.

### with autoinstaller:
sudo pacman -S git && git clone https://github.com/exgade/linux-gaming && sudo ./linux-gaming/autoinstall.sh

### with Distribution specific installer:
You can also customize the installation by configuring the installer script for your installation before running it.

---

## Distribution related infos

### For Beginners
* Manjaro ( https://manjaro.org/ )

### For Advanced Users
* Arch Linux
* Artix Linux
* Debian Testing or Sid
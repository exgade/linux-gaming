#!/bin/bash
# AUR installer
sudo pacman -S git --needed
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

sudo -H sh -c "cd /home/$USER/linux-gaming; ./arch-gaming.sh"

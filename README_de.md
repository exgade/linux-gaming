# Gaming Setup Scripte für Linux Distributionen
[[English]](README.md) [[German]](README_de.md)

---

## Über das Script

Diese Installationsscripte sind für den Einsatz auf frisch installierten Linux Systemen gedacht.

### What's included:

* Installation von (proprietären) Nvidia, AMD and/or Intel Treibern
* Lutris ( Benutzt Lutris Repositories für Debian ; https://github.com/lutris/lutris )
* Wine Staging ( Benutzt WineHQ Repositories für Debian )
* DXVK für bessere Direct X Unterstützung ( https://github.com/doitsujin/dxvk )
* DXD3D für bessere Direct 3D Unterstützung ( https://github.com/d3d12/vkd3d )
* Winetricks ( https://github.com/Winetricks/winetricks )
* Einige benötigte Pakete und weitere hilfreiche Ressourcen (beispielsweise windows core fonts)
* Optimiert Copy on Write Einstellungen auf BTRFS Dateisystemen (sofern verwendet), um Performance Probleme mit Spielen zu verhindern.
* Kommunikations Tools: Mumble, Teamspeak 3 und Discord (Auf Debian ist aktuell nur Mumble verfügbar)
* Installationsscript für die neuesten Glorious Eggroll Proton Builds ( https://github.com/GloriousEggroll/proton-ge-custom/releases )

---

## Anforderungen für die Installation: Git

Um das Repository herunterzuladen muss man zunächst Git installiert haben.

### 1) Installiere Git:
* Arch Linux, Manjaro, Artix Linux  
    sudo pacman -S git
* Debian  
    sudo apt install git

### 2) Lade die Scripte mit Git herunter
* Dies wird den Ordner linux-gaming erstellen und die Scripte in den Ordner herunterladen:  
    git clone https://github.com/exgade/linux-gaming

## Installation

Das Installationsscript erkennt eure Distribution und installiert setzt dann das System entsprechend auf.

### Installation per autoinstaller:
sudo linux-gaming/autoinstall.sh

### Installation mit einem speziellem installer:
Die installation kann auch per Hand durchgeführt werden, indem zunächst das Script für die entsprechende Distribution bearbeitet wird.

---

## Angepasste Proton Version

Für die angepasste Proton Version von Glorious Eggroll ist ein Installer vorhanden. Die angepasste Version enthält haufenweise Hotfixes für einige Spiele und ist in der Regel deutlich aktueller als Proton in Steam.

Das Script installiert die angepasste Proton Version für die Nutzung in Steam, die Version ist dann jedoch auch in Lutris verfügbar.

### Befehl für die Installation von ge-proton:
* linux-gaming/user_scripts/ge-proton.sh

---

## Aktualisierung des Scriptes

Um eine neue Version des Scriptes herunterzuladen, kann folgender Befehl ausgeführt werden:

* cd linux-gaming && git pull && cd ..

---

## Distributionsspezifische Informationen

### Für Anfänger
* Linux Mint ( https://www.linuxmint.com/ )
* Manjaro ( https://manjaro.org/ )

### Für erfahrene Benutzer
* Arch Linux
* Artix Linux
* Debian Testing oder Sid
* Ubuntu
* Elementary OS

#!/bin/bash
username=$(id -u -n 1000)

sudo nala purge --autoremove -y \
account-plugin-facebook \
account-plugin-flickr \
account-plugin-jabber \
account-plugin-salut \
account-plugin-twitter \
account-plugin-windows-live \
account-plugin-yahoo \
aisleriot \
brltty \
deja-dup \
duplicity \
empathy \
empathy-common \
evolution-data-server-online-accounts \
example-content \
gnome-accessibility-themes \
gnome-contacts \
gnome-mahjongg \
gnome-mines \
gnome-orca \
gnome-screensaver \
gnome-sudoku \
gnome-video-effects \
gnomine \
landscape-common \
libreoffice-avmedia-backend-gstreamer \
libreoffice-calc \
libreoffice-draw \
libreoffice-gnome \
libreoffice-gtk \
libreoffice-impress \
libreoffice-math \
libreoffice-ogltrans \
libreoffice-pdfimport \
libreoffice-style-galaxy \
libreoffice-style-human \
libsane \
libsane-common \
mcp-account-manager-uoa \
mediascanner2.0 \
python3-uno \
rhythmbox \
rhythmbox-plugins \
rhythmbox-plugin-zeitgeist \
sane-utils \
shotwell \
shotwell-common \
telepathy-gabble \
telepathy-haze \
telepathy-idle \
telepathy-indicator \
telepathy-logger \
telepathy-mission-control-5 \
telepathy-salut \
thunderbird \
thunderbird-gnome-support \
totem \
totem-common \
totem-plugins \
unity-scope-chromiumbookmarks \
unity-scope-colourlovers \
unity-scope-devhelp \
unity-scope-firefoxbookmarks \
unity-scope-googlenews \
unity-scope-launchpad \
unity-scope-manpages \
unity-scope-musicstores \
unity-scope-onlinemusic \
unity-scope-openclipart \
unity-lens-shopping \
unity-scope-texdoc \
unity-scope-tomboy \
unity-scope-video-remote \
unity-scope-virtualbox \
unity-scope-yahoostock \
unity-scope-yelp \
unity-scope-zotero \
yelp

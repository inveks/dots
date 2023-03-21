#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Change Debian to SID Branch
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp sources.list /etc/apt/sources.list

username=$(id -u -n 1000)
builddir=$(pwd)

wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null


# Update packages list and update system
apt update
apt install nala -y

sudo nala fetch

sudo nala update -y
sudo nala upgrade -y

#bash scripts/inst
bash scripts/hold
sudo nala install apt-transport-https curl -y
sudo nala install xorg gnome-shell gnome-session gdm3 gnome-terminal -y

sudo nala install nautilus -y
sudo nala install timeshift -y

sudo nala install build-essential git inotify-tools nano -y

systemctl set-default graphical.target
sudo systemctl enable gdm



cd /tmp
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install


sudo EDITOR=nano systemctl edit --full grub-btrfsd

- ExecStart=/usr/bin/grub-btrfsd --syslog /.snapshots
+ ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto

sudo systemctl enable grub-btrfsd
sudo systemctl start grub-btrfsd

sudo systemctl enable grub-btrfsd
sudo systemctl start grub-btrfsd

sudo timeshift --list

sudo nano /etc/fstab
+ UUID=<UUID>   /run/timeshift/backup   btrfs   defaults,noatime   0 0

# Reboot the system. Now check if the run-timeshift-backup.mount mount point is created.

sudo systemctl list-units -t mount

sudo bash -c 'cat << EOF > /etc/systemd/system/update-grub.service
[Unit]
Description=Regenerate grub menu

[Service]
Type=oneshot
ExecStart=bash -c 'grub-mkconfig -o /boot/grub/grub.cfg'
EOF'

sudo bash -c 'cat << EOF > /etc/systemd/system/grub-btrfs.path
[Unit]
Description="Monitor Timeshift for new snapshots"
DefaultDependencies=no
Requires=run-timeshift-backup.mount
After=run-timeshift-backup.mount
BindsTo=run-timeshift-backup.mount

[Path]
PathModified=/run/timeshift/backup/timeshift-btrfs/snapshots
Unit=update-grub.service

[Install]
WantedBy=run-timeshift-backup.mount
EOF'

sudo systemctl enable grub-btrfs.path
sudo systemctl start grub-btrfs.path

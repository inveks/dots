# Debian Installation Guide

Guide to install Debian Stable on an EFI system. Uses the following features:

* Btrfs with `@`, `@home`, `@cache`, `@log`, and `@swap` subvolumes
* Swapfile
* Snapshots using Timeshift
* GRUB bootloader with bootable snapshots
* Minimal GNOME desktop environment
* GDM display manager

## Step 0: Create Bootable USB

Download the latest version of Debian Stable with non-free software from [here](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/).

Either use [Ventoy](https://www.ventoy.net/en/index.html) or manually create a bootable USB using the `dd` command.

```sh
sudo dd bs=4M if=/path/to/debian.iso of=/dev/sdX status=progress
```

Update `/path/to/debian.iso` and `/dev/sdX` with the correct USB device.

## Step 1: Disk Partitioning

Once booting into the Debian ISO, choose `Advanced options ...` and then `... expert Install`.

Go through all of the steps until you reach `Partition disks`.

Once reaching this step, choose `Manual` for the partitioning method. Create a new partition table of type `gpt`.

Choose the disk and create the following partitions.

Type | Size | Mount Point | Bootable |
| -- | -- | -- | -- |
| EFI System Partition | 512 MB | /boot/efi | yes
| btrfs | remaining | / | no

After creating the partitions, choose `Finish partitioning and write changes to disk`. If prompted for a missing swap partition, choose `No` to continue without the swap partition.

After choosing `Yes` for writing changes to disk, **DO NOT** choose `Install the base system`.

## Step 2: Mounting and Btrfs Subvolumes

Press Ctrl + Alt + F2 to enter the TTY terminal. Press enter to activate the terminal. The steps will be as follows:

* Unmount the current partitions
* Create the btrfs subvolumes
* Remount the partitions
* Create the file system table

List your current disks partitions.

```bash
df -h
```

Remember the device names for the EFI and root partitions. This is typically as follows.

| Type | EFI Partition | Root Partition |
| -- | -- | -- |
| SATA Disks | `/dev/sda1` | `/dev/sda2` |
| NVMe Disks | `/dev/nvme0n1p1` | `/dev/nvme0n1p2` |
| Virtual Machines | `/dev/vda1` | `/dev/vda2` |

The instructions will use `/dev/vda`, but use what is specific to your machine.

Unmount the current partitions.

```sh
umount /target/boot/efi
umount /target
```

Mount the root partition to the `/mnt` directory.

```sh
mount /dev/vda2 /mnt
```

Move into the `/mnt` directory.

```sh
cd /mnt
```

Rename the `@rootfs` subvolume to `@`.

```sh
mv @rootfs @
```

Create btrfs subvolumes for `@home` and `@swap`.

```sh
btrfs subvolume create @home
btrfs subvolume create @cache
btrfs subvolume create @log
btrfs subvolume create @swap
```

Renount the root subvolume back to `/target`.

```sh
mount -o noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@ /dev/vda2 /target
```

Create the directories for the ESP partition and btrfs subvolumes.

```sh
mkdir -p /target/boot/efi
mkdir /target/home
mkdir -p /target/var/cache
mkdir -p /target/var/log
mkdir /target/swap
```

Mount the `@home`, `@cache`, `@log`, and `@swap` subvolumes.

```sh
mount -o noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@home /dev/vda2 /target/home
mount -o noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@cache /dev/vda2 /target/var/cache
mount -o noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@log /dev/vda2 /target/var/log
mount -o noatime,ssd,subvol=@ /dev/vda2 /target/swap
```

Mount the ESP partition.

```sh
mount /dev/vda1 /target/boot/efi
```

Edit the file system table with the btrfs subvolumes.

```sh
nano /target/etc/fstab
```

Edit the file to look something like this.

```fstab
UUID=<UUID>   /           btrfs   noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@       0 0
UUID=<UUID>   /home       btrfs   noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@home   0 0
UUID=<UUID>   /var/cache  btrfs   noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@cache  0 0
UUID=<UUID>   /var/log    btrfs   noatime,compress=zstd:1,space_cache=v2,ssd,subvol=@log    0 0
UUID=<UUID>   /swap       btrfs   noatime,ssd,subvol=@swap                                  0 0
UUID=<UUID>   /boot/efi   vfat    umask=0077                                                0 1
```

Save and exit out of the file.

Exit out of the TTY using Ctrl + Alt + F1. Finish the remainder of the installation and reboot.

## Step 3: Swapfile

Log into the system using the console. Update the system.

```sh
sudo apt update
sudo apt upgrade
```

Install vim.

```sh
sudo apt install vim
```

Disable copy-one-write for the `@swap` subvolume.

```sh
sudo chattr -R +C /swap
```

Create the swapfile, disable copy-on-write, disable compression, and allocate it to 4GB.

```sh
sudo touch /swap/swapfile
sudo chattr +C /swap/swapfile
sudo btrfs property set /swap/swapfile compression none
sudo dd if=/dev/zero of=/swap/swapfile bs=1M count=4096 status=progress
```

Set permissions, format the swapfile, and activate it.

```sh
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile
```

Add the following line to the file system table for the swapfile.

```sh
sudo vim /etc/fstab
```

```diff
+ /swap/swapfile  none  swap  defaults  0 0
```

## Step 3: Installing GNOME Desktop Environment

Install the minimal packages required for the GNOME desktop environment. This will take some time.

```sh
sudo apt install xorg gnome-shell gnome-session gdm3 gnome-terminal
```

Enable GDM for the login manager.

```sh
sudo systemctl set-default graphical.target
sudo systemctl enable gdm
```

(Optional) Install some other GNOME packages that may be useful and cannot be found on flathub.

| Name | apt package |
| -- | -- |
| GNOME File Manager | nautilus |
| GNOME Software Store | gnome-software |
| GNOME Themes | gnome-themes-standard |
| GNOME Tweaks | gnome-tweaks |
| GNOME Disks | gnome-disk-utility |

```sh
sudo apt install <apt package>
```

Reboot and log into the desktop environment.

## Step 5: Btrfs Snapshots

### Timeshift

Install Timeshift.

```sh
sudo apt install timeshift
```

Launch Timeshift and select the backup frequency. It is recommended to enable daily, weekly, and monthly snapshots.

(Optional) Install the [timeshift-autosnap-apt](https://github.com/wmutschl/timeshift-autosnap-apt) package to automatically create snapshots when using the package manager.

### GRUB btrfs

Install the required programs to compile grub-btrfs.

```sh
sudo apt install build-essential git inotify-tools
```

Clone the git repo and install grub-btrfs manually.

```sh
cd /tmp
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install
```

Edit the grub-brtfs config to use Timeshift instead of Snapper.

```sh
sudo EDITOR=vim systemctl edit --full grub-btrfsd
```

```diff
- ExecStart=/usr/bin/grub-btrfsd --syslog /.snapshots
+ ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto
```

Enable and start the grub-btrfs daemon.

```sh
sudo systemctl enable grub-btrfsd
sudo systemctl start grub-btrfsd
```

Find out the UUID that Timeshift creates its snapshots

```sh
sudo timeshift --list
```

Add the following line to the file system table for the Timeshift snapshots.

```sh
sudo vim /etc/fstab
```

```diff
+ UUID=<UUID>   /run/timeshift/backup   btrfs   defaults,noatime   0 0
```

Reboot the system. Now check if the `run-timeshift-backup.mount` mount point is created.

```sh
sudo systemctl list-units -t mount
```

Create a new service `update-grub` with the following content.

```sh
sudo vim /etc/systemd/system/update-grub.service
```

```systemd
[Unit]
Description=Regenerate grub menu

[Service]
Type=oneshot
ExecStart=bash -c 'grub-mkconfig -o /boot/grub/grub.cfg'
```

Create a new path watch `grub-btrfs.path` with the following content.

```sh
sudo vim /etc/systemd/system/grub-btrfs.path
```

```systemd
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
```

Enable and start the grub-btrfs path watcher.

```sh
sudo systemctl enable grub-btrfs.path
sudo systemctl start grub-btrfs.path
```

Create a new snapshot in Timeshift and reboot. This should now automatically appear in the GRUB menu as a bootable snapshot.

## Step 6: Flatpak

Install flatpak and set flathub as the remote.

```sh
sudo apt install flatpak gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

(Optional) Install the useful flatpak packages.

| Name | flatpak package |
| -- | -- |
| Firefox | org.mozilla.firefox |
| Flatseal | com.github.tchx84.Flatseal |
| GNOME Extensions | org.gnome.Extensions |
| GNOME Image Viewer | org.gnome.eog |
| GNOME Videos | org.gnome.Totem |
| GNOME Photos | org.gnome.Photos |
| GNOME Music | org.gnome.Music |
| GNOME Document Viewer | org.gnome.Evince |
| GNOME File Roller | org.gnome.FileRoller |
| GNOME Text Editor | org.gnome.TextEditor |
| GNOME Calculator | org.gnome.Calculator |
| GNOME Clocks | org.gnome.clocks |
| GNOME Characters | org.gnome.Characters |
| GNOME Fonts | org.gnome.font-viewer |
| GNOME Disk Usage | org.gnome.baobab |
| GNOME Calendar | org.gnome.Calendar |
| GNOME Camera | org.gnome.Cheese |
| GNOME Web | org.gnome.Epiphany |
| Extension Manager | com.mattjakeman.ExtensionManager |
| Drawing | com.github.maoschanz.drawing |
| LibreOffice | org.libreoffice.LibreOffice |

```sh
flatpak install flathub <flatpak package>
```

It is recommended to use Flatseal to modify permissions (particularly for Firefox) to give access to directories.

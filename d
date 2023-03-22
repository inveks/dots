# first, get the iso from http://releases.ubuntu.com/

# make working dir hierarchy in /tmp (you'll need enough ram for this)
sudo mkdir -p /tmp/custom/{_squash,_work,iso,newiso,newlive,project}
sudo mount -o loop ~/Downloads/ubuntu-15.10-desktop-amd64.iso /tmp/custom/iso
sudo mount -t squashfs /tmp/custom/iso/casper/filesystem.squashfs /tmp/custom/_squash
sudo mount -t overlay overlay -onoatime,lowerdir=/tmp/custom/_squash,upperdir=/tmp/custom/project,workdir=/tmp/custom/_work /tmp/custom/newlive

# customize the live fs with systemd-nspawn (a better chroot)
sudo systemd-nspawn --bind-ro=/etc/resolv.conf:/run/resolvconf/resolv.conf --setenv=RUNLEVEL=1 -D /tmp/custom/newlive

apt-get update
apt-get upgrade
apt-get install --no-install-recommends ...
...
apt-get purge ...
apt-get autoremove --purge
apt-get clean
<ctrl-d>
sudo rm /tmp/custom/newlive/root/.bash_history
sudo rm /tmp/custom/newlive/var/lib/dbus/machine-id

# prepare new image content
sudo rsync -av --exclude casper/filesystem.squashfs /tmp/custom/iso/ /tmp/custom/newiso/

sudo mksquashfs /tmp/custom/newlive /tmp/custom/newiso/casper/filesystem.squashfs -noappend -b 1048576 -comp xz -Xdict-size 100%
printf $(sudo du -s --block-size=1 /tmp/custom/newlive | cut -f1) | sudo tee /tmp/custom/newiso/casper/filesystem.size

# remove leftovers
sudo umount /tmp/custom/_fs /tmp/custom/newlive /tmp/custom/iso
sudo rm -rf /tmp/custom/newiso

# /tmp/custom/project now has the delta of your changes, you could keep it for later reuse

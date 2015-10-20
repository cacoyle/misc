#preseed preseed/file=/cdrom/preseed/ubuntu-server-minimalvm.seed
lang en_US
langsupport en_US
keyboard us
mouse
timezone America/New_York
rootpw --disabled
user ubuntu --fullname "Ubuntu User" --password ChangeMe
reboot
text
install
url --url=http://10.13.13.254/media/
bootloader --location=mbr
zerombr yes
clearpart --all --initlabel

%pre
mkdir /tmp/drivers
wget http://10.13.13.254/media/pool/main/l/linux-lts-vivid/storage-core-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb -O /tmp/drivers/storage-core-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb
wget http://10.13.13.254/media/pool/main/l/linux-lts-vivid/scsi-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb -O /tmp/drivers/scsi-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb
wget http://10.13.13.254//media/pool/main/l/linux-lts-vivid/message-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb -O /tmp/drivers/message-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb

udpkg -i /tmp/drivers/*.udeb

depmod -a
modprobe mptbase
modprobe mptscsih
modprobe mptspi

sleep 6000
## No parted/fdisk in busybox
#echo $0 >> /tmp/whatshellisthis
#echo `pwd` >> /tmp/whatshellisthis
#echo `ls` >> /tmp/whatshellisthis
#echo "WHAR PARTED" >> /tmp/whatshellisthis
#echo `parted_devices` 2>&1 >> /tmp/whatshellisthis
#echo "WHAR?!" >> /tmp/whatshellisthis
#cat /sys/class/block/sda/size 2>&1 >> /tmp/whatshellisthis
#bin/cat /sys/class/block/sda/size 2>&1 >> /tmp/whatshellisthis
#sleep 600
#SECTOR_NO=`cat /sys/class/block/sda/size`
#SECTOR_SZ=`cat /sys/class/block/sda/queue/physical_block_size`
#
#resSize=$(( (${SECTOR_NO} * ${SECTOR_SZ}) / 1024 * 2 / 10 ))
#
#echo "part /boot --fstype=ext4 --size=512" >> /tmp/parted-include
#echo "part pv.01 --grow --size=1" >> /tmp/parted-include
#echo "volgroup vg01 pv.01" >> /tmp/parted-include
#echo "logvol /reserved --fstype=ext4 --vgname=vg01 --name=reserved --size=${resSize}" >> /tmp/parted-include
#echo "logvol / --fstype=ext4 --vgname=vg01 --name=rootvol --size=1 --grow" >> /tmp/parted-include
#echo "logvol swap --fstype=swap --vgname=vg01 --name=swap1 --recommend" >> /tmp/parted-include
%end

#%include /tmp/parted-include

#preseed preseed/file=/tmp/disk.seed

#preseed partman-auto-lvm/guided_size string 85%
#part /boot --fstype=ext4 --size=512 --asprimary
#part pv.1 --grow --size=1 --asprimary
#volgroup vg0 --pesize=4096 pv.1
#logvol / --fstype=ext4 --name=root --vgname=vg0 --size=1024
#logvol /usr --fstype=ext4 --name=usr --vgname=vg0 --size=2048
#logvol /var --fstype=ext4 --name=var --vgname=vg0 --size=1536
#logvol swap --name=swap --vgname=vg0 --size=2048 --maxsize=2048
#logvol /home --fstype=ext4 --name=home --vgname=vg0 --size=512

# Standard partitioning, --percent doesn't seem to be working
part /boot --fstype=ext4 --size=512
part pv.01 --grow --size=1
volgroup vg01 pv.01
logvol / --fstype=ext4 --vgname=vg01 --name=rootvol --size=4096
logvol swap --fstype=swap --vgname=vg01 --name=swap1 --recommend

#preseed disk layout
#preseed partman-auto/method string lvm
#preseed partman-auto-lvm/new_vg_name string vg01
#preseed partman-lvm/device_remove_lvm boolean true
#preseed partman-md/device_remove_md boolean true
#preseed partman-lvm/confirm boolean true
#preseed partman-auto-lvm/guided_size string 85%
#preseed partman/confirm_nooverwrite boolean true
#preseed partman-md/confirm_nooverwrite boolean true
#preseed partman-lvm/confirm_nooverwrite boolean true
#preseed partman-auto/choose_recipe select atomic
#preseed partman/default_filesystem string ext4
#preseed partman-partitioning/confirm_write_new_label boolean true
#preseed partman/choose_partition select finish
#preseed partman/confirm boolean true
#preseed partman/confirm_nooverwrite boolean true
#
#preseed base-installer/install-recommends boolean false
auth  --useshadow  --enablemd5
network --bootproto=dhcp --device=eth0
firewall --disabled --trust=eth0 --ssh
#preseed pkgsel/update-policy select unattended-upgrades
skipx
%packages
ca-certificates
openssl
python
wget
tcpd
openssh-server
curl
screen
vim

#%post
#lvresize -r -l 80%VG /dev/vg01/rootvol

%post
fdisk -s /dev/sda >> /root/disksize
echo "set background=dark" >>/etc/vim/vimrc.local
sed -i -e 's/^\(UMASK\W*\)[0-9]\+$/\1027/' /etc/login.defs
sed -i -e 's/\(errors=remount-ro\)/noatime,\1/' /etc/fstab
sed -i -e 's/\(boot.*defaults\)/\1,noatime,nodev/' /etc/fstab
sed -i -e 's/\(home.*defaults\)/\1,noatime,nodev/' /etc/fstab
sed -i -e 's/\(usr.*defaults\)/\1,noatime,nodev/' /etc/fstab
sed -i -e 's/\(var.*defaults\)/\1,noatime,nodev/' /etc/fstab
apt-get -qq -y autoremove
apt-get clean
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*

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
#clearpart --all --initlabel

#%pre
#mkdir /tmp/drivers
#wget http://10.13.13.254/media/pool/main/l/linux-lts-vivid/storage-core-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb -O /tmp/drivers/storage-core-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb
#wget http://10.13.13.254/media/pool/main/l/linux-lts-vivid/scsi-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb -O /tmp/drivers/scsi-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb
#wget http://10.13.13.254//media/pool/main/l/linux-lts-vivid/message-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb -O /tmp/drivers/message-modules-3.19.0-25-generic-di_3.19.0-25.26~14.04.1_amd64.udeb
#
#udpkg -i /tmp/drivers/*.udeb
#
#depmod -a
#modprobe mptbase
#modprobe mptscsih
#modprobe mptspi
#sleep 300
#sed -i 's/^d-i partman//g' /var/spool/kickseed/parse
#
#echo 'd-i partman-auto/method string lvm' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-auto-lvm/new_vg_name string vg01' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-lvm/device_remove_lvm boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-md/device_remove_md boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-lvm/confirm boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-auto-lvm/guided_size string 85%' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman/confirm_nooverwrite boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-md/confirm_nooverwrite boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-lvm/confirm_nooverwrite boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-auto/choose_recipe select atomic' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman/default_filesystem string ext4' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman-partitioning/confirm_write_new_label boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman/choose_partition select finish' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman/confirm boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#echo 'd-i partman/confirm_nooverwrite boolean true' >> /var/spool/kickseed/parse/preseed.cfg
#
#sleep 300
#%end


clearpart --all --initlabel
preseed partman-auto/method string lvm
preseed partman-auto-lvm/new_vg_name string vg01
preseed partman-lvm/device_remove_lvm boolean true
preseed partman-md/device_remove_md boolean true
preseed partman-lvm/confirm boolean true
preseed partman-auto-lvm/guided_size string 85%
preseed partman/confirm_nooverwrite boolean true
preseed partman-md/confirm_nooverwrite boolean true
preseed partman-lvm/confirm_nooverwrite boolean true
preseed partman-auto/choose_recipe select atomic
preseed partman/default_filesystem string ext4
preseed partman-partitioning/confirm_write_new_label boolean true
preseed partman/choose_partition select finish
preseed partman/confirm boolean true
preseed partman/confirm_nooverwrite boolean true

auth  --useshadow  --enablemd5
network --bootproto=dhcp --device=eth0
firewall --disabled --trust=eth0 --ssh
skipx

part /boot --fstype=ext4 --size=512
part pv.01 --grow --size=1

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

%post --nochroot
cp -ar /var/spool/kickseed/* /target/root/

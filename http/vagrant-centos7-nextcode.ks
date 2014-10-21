#platform=86, AMD64, or Intel EM64T

install
text
cdrom
firewall --disabled
firstboot --disable
ignoredisk --only-use=sda
keyboard --vckeymap=is-latin1 --xlayouts='is'
lang en_US.UTF-8

network --onboot yes --device eth0 --bootproto dhcp --noipv6 --hostname vagrant-centos-7.nextcode.com
rootpw vagrant
firewall --disabled
authconfig --enableshadow --passalgo=sha512
selinux --disabled
services --disabled="abrtd,autofs,avahi-daemon,gpm,iptables,ip6tables,kdump,microcode_ctl,nfs,nscd,nslcd,rhnsd" --enabled="ntpd,sshd"
skipx
timezone Atlantic/Reykjavik --isUtc
zerombr
clearpart --all --initlabel 
part /boot --fstype=ext4 --size=512
part pv.01 --grow --size=1
volgroup vg0 --pesize=4096 pv.01
logvol swap --name=lv_swap --vgname=vg0 --size=2048
logvol / --fstype=ext4 --name=lv_root --vgname=vg0 --grow --size=1
bootloader --location=mbr --boot-drive=sda
user --name=vagrant --groups=wheel --password=vagrant
reboot --eject

%packages --nobase
@core
%end


%post
yum -y upgrade

/sbin/swapoff -a
/sbin/mkswap /dev/mapper/vg0-lv_swap
/bin/dd if=/dev/zero of=/boot/EMPTY bs=1M
/bin/rm -f /boot/EMPTY
/bin/dd if=/dev/zero of=/EMPTY bs=1M
/bin/rm -f /EMPTY
%end

%post --interpreter=/bin/bash
exec > /root/post_config.log 2>&1
chkconfig NetworkManager off
%end

%post --nochroot
cp /etc/resolv.conf /mnt/sysimage/etc/resolv.conf
%end
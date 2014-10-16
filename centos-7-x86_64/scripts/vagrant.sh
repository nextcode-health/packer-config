#!/usr/bin/env bash
set -e
set -x

if [ "$(ping -q -c1 proxy.decode.is)" ] ; then 
  echo "Using decode proxy server."
  export http_proxy=http://proxy.decode.is:8080
  export https_proxy=http://proxy.decode.is:8080
else
  echo "Not setting proxy server."
fi

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config

# Add the EPEL Repository
/bin/cat << EOF > /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
baseurl=http://download.fedoraproject.org/pub/epel/7/\$basearch
enabled=1
gpgcheck=0
EOF

# Install vagrant keys
/bin/mkdir /home/vagrant/.ssh
/bin/chmod 700 /home/vagrant/.ssh
#/usr/bin/curl -o /home/vagrant/.ssh/id_rsa https://raw.github.com/mitchellh/vagrant/master/keys/vagrant
/usr/bin/curl -o /home/vagrant/.ssh/id_rsa http://test.nextcode.com/public/vagrant-keys/id_rsa
#/usr/bin/curl -o /home/vagrant/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
/usr/bin/curl -o /home/vagrant/.ssh/authorized_keys http://test.nextcode.com/public/vagrant-keys/id_rsa.pub
/bin/chown -R vagrant:vagrant /home/vagrant/.ssh
/bin/chmod 0400 /home/vagrant/.ssh/*

# Configure sudo
/bin/cat << EOF > /etc/sudoers.d/wheel
Defaults:%wheel env_keep += "SSH_AUTH_SOCK"
Defaults:%wheel !requiretty
%wheel ALL=NOPASSWD: ALL
EOF
/bin/chmod 0440 /etc/sudoers.d/wheel


yum -y install git gcc make automake autoconf bzip2 libtool gcc-c++ zlib-devel openssl-devel \
               readline-devel sqlite-devel perl wget nfs-utils bind-utils dkms sudo \
               rubygems ruby-devel kernel-headers-`uname -r` kernel-devel-`uname -r`

echo `uname -r`

# # Puppet and chef
# /usr/bin/gem install --no-ri --no-rdoc puppet
# /usr/sbin/groupadd -r puppet
# /usr/bin/gem install --no-ri --no-rdoc chef

if [[ -f /etc/.vbox_version ]]; then
  cd /tmp
  mount -o loop /tmp/VBoxGuestAdditions.iso /mnt
  sh /mnt/VBoxLinuxAdditions.run || true
  umount /mnt
  #rm -rf /tmp/VBoxGuestAdditions*.iso

  /etc/rc.d/init.d/vboxadd setup
fi
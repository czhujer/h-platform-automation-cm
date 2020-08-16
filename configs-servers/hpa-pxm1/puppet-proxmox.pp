#
# https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_Stretch
#

apt::source { 'pve-install-repo':
  ensure   => 'present',
  location => 'http://download.proxmox.com/debian/pve',
  # release  => 'unstable',
  repos    => 'pve-no-subscription',
  key      => {
    'id'     => '359E95965E2C3D643159CD300D9A1950E2EF0603',
    'source' => 'http://download.proxmox.com/debian/proxmox-ve-release-5.x.gpg',
  },
}

apt::source { 'pve-enterprise':
  ensure   => 'absent',
}

$proxmox_packages = ['proxmox-ve', 'postfix', 'open-iscsi']

package { $proxmox_packages:
  ensure  => 'installed',
  require => Apt::Source['pve-install-repo'],
  #notify => Exec['apt_dist_upgrate'],
}

exec { 'apt_dist_upgrate':
  command     => 'apt update && apt full-upgrade -y',
  #loglevel    => $::apt::_update['loglevel'],
  logoutput   => 'on_failure',
  #refreshonly => true,
  #timeout     => $::apt::_update['timeout'],
  #tries       => $::apt::_update['tries'],
  #try_sleep   => 1,
  path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  #provider     => shell,
  before      => Package[$proxmox_packages],
  require     => [
    Apt::Source['pve-enterprise'],
    Apt::Source['pve-install-repo'],
  ],
}

exec { 'download centos-7 template':
  command  => 'pveam download local centos-7-default_20190926_amd64.tar.xz',
  path     => '/usr/bin:/usr/sbin:/bin',
  provider => shell,
  unless   => 'stat /var/lib/vz/template/cache/centos-7-default_20190926_amd64.tar.xz',
  require  => Package[$proxmox_packages],
}

$proxmox_packages_absent = ['os-prober', 'linux-image-amd64',
                            'linux-image-4.9.0-12-amd64', 'linux-image-4.9.0-13-amd64']

package { $proxmox_packages_absent:
  ensure  => 'absent',
  require => [
    Exec['apt_dist_upgrate'],
    Package[$proxmox_packages],
  ],
}

# add/reconfigure bridge and networking
$script_bridged_networking = '#!/bin/bash

echo "# network interface settings; autogenerated
# Please do NOT modify this file directly, unless you know what
# you\'re doing.
#
# If you want to manage parts of the network configuration manually,
# please utilize the \'source\' or \'source-directory\' directives to do
# so.
# PVE will preserve these directives, but will NOT read its network
# configuration from sourced files, so do not attempt to move any of
# the PVE managed interfaces into external files!

source-directory /etc/network/interfaces.d

# The loopback network interface
auto lo
iface lo inet loopback

" > /etc/network/interfaces

echo "#auto ens5
iface ens5 inet manual
	pre-up ifconfig ens5 up
	post-down ifconfig ens5 down

auto vmbr0
iface vmbr0 inet dhcp
	bridge_ports ens5
" >> /etc/network/interfaces

systemctl restart networking
'

file { '/root/scripts/pve-fix-networking.sh':
  ensure   => 'present',
  content  => $script_bridged_networking,
  require  => File['/root/scripts'],
}

exec { 'fix network config for pve':
  command  => 'bash /root/scripts/pve-fix-networking.sh',
  path     => '/usr/bin:/usr/sbin:/bin:/sbin',
  #provider => shell,
  unless   => 'brctl show vmbr0 |grep ens',
  require  => [
    Package[$proxmox_packages_absent],
    Class['nginx'],
  ],
}

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

$proxmox_packages = ['proxmox-ve', 'postfix', 'open-iscsi']

package { $proxmox_packages:
  ensure  => 'installed',
  require => Apt::Source['pve-install-repo'],
  #notify => Exec['apt_dist_upgrate'],
}

# exec { 'apt_dist_upgrate':
#   command     => "${::apt::provider} dist-upgrade",
#   #loglevel    => $::apt::_update['loglevel'],
#   logoutput   => 'on_failure',
#   refreshonly => true,
#   #timeout     => $::apt::_update['timeout'],
#   #tries       => $::apt::_update['tries'],
#   #try_sleep   => 1
# }

# apt remove os-prober

# apt remove linux-image-amd64 linux-image-4.9.0-3-amd64

# update-grub

#
# provisioning plugins
#

# repo with scripts

vcsrepo { '/root/h-platform-automation-core':
  ensure   => latest,
  provider => git,
  source   => 'https://github.com/czhujer/h-platform-automation-core.git',
  revision => 'master',
}

file { '/root/scripts':
  ensure => 'directory',
}

#
# proxmox lxc containers - owncloudstack
#

file { '/root/scripts/pxm-create-container.rb':
  ensure  => 'link',
  target  => '/root/h-platform-automation-core/proxmox-owncloud/scripts/pxm-create-container.rb',
  require => [
    Vcsrepo['/root/h-platform-automation-core'],
    File['/root/scripts'],
  ],
}

# neccesary folders for pxm-create-container.rb
file { ['/home/jenkins-slave/workspace', '/home/jenkins-slave/workspace/create-owncloud-b2c-container']:
  ensure  => 'directory',
  require => Class['jenkins::slave'],
}

# neccesary lib(s) for pxm-create-container.rb
exec { 'download gem proxmox':
  command  => 'bash -E -c "source /etc/profile.d/rvm.sh; gem install fog-proxmox -v0.5.5 --no-document --no-post-install-message"',
  path     => '/usr/bin:/usr/sbin:/bin',
  #provider => shell,
  unless   => 'bash -E -c "source /etc/profile.d/rvm.sh; gem list -i fog-proxmox"',
}

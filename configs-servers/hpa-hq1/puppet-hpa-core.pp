# core pore
#
vcsrepo { '/root/h-platform-automation-core':
  ensure   => latest,
  provider => git,
  source   => 'https://github.com/czhujer/h-platform-automation-core.git',
  revision => 'master',
  require  => Package[$packages_system],
}

vcsrepo { '/root/h-platform-automation-cc-server':
  ensure   => latest,
  provider => git,
  source   => 'https://github.com/czhujer/h-platform-automation-cc-server.git',
  revision => 'master',
  require  => Package[$packages_system],
}

file { '/root/scripts':
  ensure => 'directory',
}

#
# terraform - owncloudstack
#

# download terraform and plugins


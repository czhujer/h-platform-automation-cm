# core pore
#
vcsrepo { '/root/h-platform-automation-core':
  ensure   => latest,
  provider => git,
  source   => 'https://github.com/czhujer/h-platform-automation-core.git',
  revision => 'master',
  require  => Package['git'],
}

vcsrepo { '/root/h-platform-automation-cc-server':
  ensure   => latest,
  provider => git,
  source   => 'https://github.com/czhujer/h-platform-automation-cc-server.git',
  #revision => 'master',
  tag      => 'v0.1',
  require  => Package['git'],
}

file { '/root/scripts':
  ensure => 'directory',
}

file { '/root/docker-compose/c-and-c-server':
  ensure => 'directory',
}

#
# terraform - owncloudstack
#

# download terraform and plugins


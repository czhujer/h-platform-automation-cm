# core pore
#
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
# terraform - owncloudstack
#

# download terraform and plugins


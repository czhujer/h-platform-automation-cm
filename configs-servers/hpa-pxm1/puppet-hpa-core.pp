# core repo
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

# proxmox-provisioning-server
#

# //TODO
# // exec: cd /root/h-platform-automation-core/proxmox-provisioning-server && bundle install

class { 'unicorn_systemd':
  user              => 'root',
  group             => 'root',
  working_directory => '/root/h-platform-automation-core/proxmox-provisioning-server',
  pidfile           => '/var/run/unicorn.pid',
  exec_start        => '/bin/bash -E -c "source /etc/profile.d/rvm.sh; unicorn -c unicorn.conf"',
  environment       => {
  },
}

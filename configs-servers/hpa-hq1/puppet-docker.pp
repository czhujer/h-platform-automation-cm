# docker
# https://forge.puppet.com/puppetlabs/docker
#
#
exec { 'enable docker repo':
  command  => 'dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo',
  path     => '/usr/bin:/usr/sbin:/bin:/sbin',
  unless   => 'rpm -qa |grep docker-ce',
  before => [
    Class['docker'],
  ],
}

exec { 'disable module container-tools':
  command  => 'dnf module disable container-tools -y',
  path     => '/usr/bin:/usr/sbin:/bin:/sbin',
  unless   => 'dnf module list |grep container-tools |grep "[x]"',
  before => [
    Class['docker'],
  ],
}

Package {'container-selinux':
  ensure          => installed,
  provider        => 'rpm',
  install_options => '--nodeps',
  source          => 'http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-1.el7_6.noarch.rpm',
  require         => Exec['disable module container-tools'],
  before          => [
    Class['docker'],
  ],
}

class { 'docker':
  use_upstream_package_source => false,
  docker_ce_package_name      => 'docker-ce',
}

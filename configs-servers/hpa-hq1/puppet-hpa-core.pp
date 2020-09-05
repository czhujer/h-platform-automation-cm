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
  tag      => 'v0.2',
  require  => Package['git'],
}

file { '/root/scripts':
  ensure => 'directory',
}

file { '/root/docker-compose/c-and-c-server':
  ensure => 'directory',
}

# terraform - owncloudstack
#
$terraform_install_dir = ['/opt', '/opt/terraform_0.13.2']

file { $terraform_install_dir:
  ensure => directory,
  owner  => 'root',
  group  => 'root',
  mode   => '0755',
}

archive { 'terraform_0.13.2_linux_amd64.zip':
  path          => '/tmp/terraform_0.13.2_linux_amd64.zip',
  source        => 'https://releases.hashicorp.com/terraform/0.13.2/terraform_0.13.2_linux_amd64.zip',
  extract       => true,
  extract_path  => '/opt/terraform_0.13.2/',
  creates       => '/opt/terraform_0.13.2/terraform',
  cleanup       => true,
  user          => 'root',
  group         => 'root',
  require       => File[$terraform_install_dir],
}

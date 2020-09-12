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
$terraform_install_dir = ['/opt', '/opt/terraform_0.13.2', '/opt/terraform_0.12.29']

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

archive { 'terraform_0.12.29_linux_amd64.zip':
  path          => '/tmp/terraform_0.12.29_linux_amd64.zip',
  source        => 'https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip',
  extract       => true,
  extract_path  => '/opt/terraform_0.12.29/',
  creates       => '/opt/terraform_0.12.29/terraform',
  cleanup       => true,
  user          => 'root',
  group         => 'root',
  require       => File[$terraform_install_dir],
}

$terraform_plugin_dir = ['/root/terraform.d',
                                '/root/terraform.d/plugins',
                                '/root/terraform.d/plugins/linux_amd64',
]

file { $terraform_plugin_dir:
  ensure  => directory,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => Vcsrepo['/root/h-platform-automation-core'],
}

archive { 'terraform-provider-ct_0.6.1_linux_amd64.zip':
  path          => '/tmp/terraform-provider-ct_0.6.1_linux_amd64.zip',
  source        => 'https://github.com/poseidon/terraform-provider-ct/releases/download/v0.6.1/terraform-provider-ct_0.6.1_linux_amd64.zip',
  extract       => true,
  extract_path  => '/root/terraform.d/plugins/linux_amd64',
  creates       => '/root/terraform.d/plugins/linux_amd64/terraform-provider-ct_v0.6.1',
  cleanup       => true,
  user          => 'root',
  group         => 'root',
  require       => File[$terraform_plugin_dir],
}

archive { 'terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz':
  path          => '/tmp/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz',
  source        => 'https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz',
  extract       => true,
  extract_path  => '/root/terraform.d/plugins/linux_amd64',
  creates       => '/root/terraform.d/plugins/linux_amd64/terraform-provider-libvirt',
  cleanup       => true,
  user          => 'root',
  group         => 'root',
  require       => File[$terraform_plugin_dir],
}

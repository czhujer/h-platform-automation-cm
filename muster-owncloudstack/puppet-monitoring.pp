
firewall { '112 accept tcp to dports 9100,9104,9117,9121,9253 / PROMETHEUS':
  chain  => 'INPUT',
  state  => 'NEW',
  proto  => 'tcp',
  dport  => ['9100','9104','9117','9121','9253'],
  source => '192.168.222.1',
  action => 'accept',
}

class { 'prometheus::node_exporter':
  version => '0.15.2',
  collectors_disable => ['bcache','bonding', 'conntrack', 'mdadm' ],
}


class { '::prometheus::apache_exporter':
  url           => 'https://localhost/server-status?auto',
  extra_options => '-insecure',
}

user { 'mysqld-exporter':
  ensure     => present,
  managehome => true,
  system     => true,
  shell      => '/sbin/nologin',
  before     => File['/home/mysqld-exporter'],
}

file {'/home/mysqld-exporter':
  ensure => directory,
  owner  => 'mysqld-exporter',
  group  => 'mysqld-exporter',
  mode   => '0700',
  before => Class['prometheus::mysqld_exporter'],
}

class { 'prometheus::mysqld_exporter':
  version => '0.10.0',
  #init_style => 'sysv',
  manage_user => false,
  manage_group => false,
  cnf_config_path => '/home/mysqld-exporter/.my.exporter.cnf',
}

# class { 'prometheus::process_exporter':
#   version => '0.4.0',
#   watched_processes => [ { 'name' => "{{.Comm}}", 'cmdline' => ['.+'] } ],
# }

class { '::prometheus::redis_exporter':
  extra_options => "-redis.alias ${::hostname}",
}

mysql_user{ 'mysqld-exporter@localhost':
  ensure        => present,
  password_hash => mysql::password("$prometheus::mysqld_exporter::cnf_password"),
  require       => Class['mysql::server'],
}

mysql_grant{'mysqld-exporter@localhost/*.*':
  user       => 'mysqld-exporter@localhost',
  table      => '*.*',
  privileges => ['PROCESS', 'REPLICATION CLIENT'],
}

class { '::prometheus::phpfpm_exporter':
  url => 'tcp://127.0.0.1:9001/fpm-status',
}

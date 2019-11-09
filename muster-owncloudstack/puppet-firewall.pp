#
# firewall manifest
#

package { 'iptables-services':
  ensure => installed,
}

service { 'iptables':
  ensure  => true,
  enable  => true,
}

service {'ip6tables':
  ensure  => true,
  enable  => true,
}

#docs
# https://forge.puppetlabs.com/puppetlabs/firewall#setup
#

class my_fw::pre {
  Firewall {
    require => undef,
  }
  # Default firewall rules
  firewall { '000 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }
  firewall { '001 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '002 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }
  firewall { '003 accept new tcp to dport 22 / SSH':
    chain   => 'INPUT',
    state   => 'NEW',
    proto   => 'tcp',
    dport   => ['22'],
    action  => 'accept',
  }
  firewall { '222 reject all forward':
    chain   => 'FORWARD',
    proto   => 'all',
    action  => 'reject',
    reject => 'icmp-host-prohibited',
  }
}

class my_fw::post {
  firewall { '999 reject all':
    proto  => 'all',
    action  => 'reject',
    reject => 'icmp-host-prohibited',
    before => undef,
  }
}

resources { 'firewall':
  purge => true,
}

class { ['my_fw::pre', 'my_fw::post']: }

Firewall {
  #  before  => Class['my_fw::post'],
  before  => [
    Class['my_fw::post'],
    #Class['my_fw::post6'],
  ],
  #  require => Class['my_fw::pre'],
  require => [
    Class['my_fw::pre'],
    #Class['my_fw::pre6'],
  ],
}

# firewall rules for services
#
firewall { '120 accept tcp to dports 80,443 / APACHE':
    chain   => 'INPUT',
    state   => 'NEW',
    proto   => 'tcp',
    dport   => ['80', '443'],
    action  => 'accept',
}

# firewall { '120 accept tcp to dports 80,443 / APACHE /v6':
#     chain   => 'INPUT',
#     state   => 'NEW',
#     proto   => 'tcp',
#     dport   => ['80', '443'],
#     action  => 'accept',
#     provider => 'ip6tables',
# }

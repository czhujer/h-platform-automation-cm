# firewall
# https://forge.puppetlabs.com/puppetlabs/firewall#setup
#
class my_fw::pre {
  Firewall {
    require => undef,
  }

  #
  # Default filter rules
  #
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
    dport   => '22',
    action  => 'accept',
  }
  #  firewall { '222 reject all forward':
  #    chain   => 'FORWARD',
  #    proto   => 'all',
  #    action  => 'reject',
  #    reject => 'icmp-host-prohibited',
  #  }
  #
  # docker nat fules
  #
  firewall { '000 jump into DOCKER-WAN':
    chain    => 'PREROUTING',
    table    => 'nat',
    proto    => 'all',
    iniface  => 'ens192',
    jump     => 'DOCKER-WAN',
  }

  firewall { '001 jump into DOCKER-WAN':
    chain    => 'PREROUTING',
    table    => 'nat',
    proto    => 'all',
    iniface  => 'tun0',
    jump     => 'DOCKER-WAN',
  }

}

class my_fw::post {

  #
  # last filter rule
  #
  firewall { '999 reject all':
    proto  => 'all',
    action  => 'reject',
    reject => 'icmp-host-prohibited',
    before => undef,
  }
  #
  # last nat rule(s)
  #
  firewall { '990 accept all from outsite (skip docker dnat)':
    chain    => 'DOCKER-WAN',
    table    => 'nat',
    iniface  => 'ens192',
    proto    => 'all',
    action  => 'accept',
    before => undef,
  }
  firewall { '991 accept all from outsite (skip docker dnat)':
    chain    => 'DOCKER-WAN',
    table    => 'nat',
    iniface  => 'tun0',
    proto    => 'all',
    action  => 'accept',
    before => undef,
  }
}

firewallchain { 'INPUT:filter:IPv4':
  purge  => true,
}

firewallchain { 'OUTPUT:filter:IPv4':
  purge  => true,
}

firewallchain { 'INPUT:nat:IPv4':
  purge  => true,
}

firewallchain { 'OUTPUT:nat:IPv4':
  purge  => true,
  ignore => [
    '! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER',
  ],
}

firewallchain { 'PREROUTING:nat:IPv4':
  purge  => true,
  ignore => [
    '-m addrtype --dst-type LOCAL -j DOCKER',
  ],
}

firewallchain { 'DOCKER-WAN:nat:IPv4':
  purge  => true,
  before => Firewall['000 jump into DOCKER-WAN'],
}

resources { 'firewall':
  #  purge => true,
}

class { ['my_fw::pre', 'my_fw::post']: }

Firewall {
  #  before  => Class['my_fw::post'],
  before  => [
    Class['my_fw::post'],
    Class['my_fw::post6'],
  ],
  #  require => Class['my_fw::pre'],
  require => [
    Class['my_fw::pre'],
    Class['my_fw::pre6'],
    Package['firewalld'],
  ],
}

package {'firewalld':
  ensure => 'absent',
}

package {'iptables-services':
  ensure => 'installed',
  require => Package['firewalld'],
}

service { ['iptables', 'ip6tables']:
  ensure  => true,
  enable  => true,
  require => Package['iptables-services'],
}

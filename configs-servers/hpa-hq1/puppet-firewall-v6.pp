# firewall v6
#
class my_fw::pre6 {
  Firewall {
    require => undef,
  }

  #
  # Default filter rules
  #
  firewall { '000 accept related established rules /v6':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
    provider => 'ip6tables',
  }
  firewall { '001 accept all icmp /v6':
    proto  => 'ipv6-icmp',
    action => 'accept',
    provider => 'ip6tables',
  }->
  firewall { '002 accept all to lo interface /v6':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
    provider => 'ip6tables',
  }

# -A INPUT -d fe80::/64 -p udp -m udp --dport 546 -m state --state NEW -j ACCEPT
  firewall { '003 accept new udp to dport546 / DHCP-v6 /v6':
    chain   => 'INPUT',
    state   => 'NEW',
    proto   => 'udp',
    source  => 'fe80::/64',
    dport   => '546',
    action  => 'accept',
    provider => 'ip6tables',
  }

  firewall { '004 accept new tcp to dport 22,10022 / SSH /v6':
    chain   => 'INPUT',
    state   => 'NEW',
    proto   => 'tcp',
    dport   => ['22', '10022'],
    action  => 'accept',
    provider => 'ip6tables',
  }

# firewall { '220 allow icmp to docker CTs /v6':
#    chain   => 'FORWARD',
#    proto   => 'ipv6-icmp',
#    destination => '2a03:b0c0:3:d0::30b1:9000/124',
#    action  => 'accept',
#    provider => 'ip6tables',
# }

# firewall { '221 allow icmp from docker CTs /v6':
#    chain   => 'FORWARD',
#    proto   => 'ipv6-icmp',
#    source => '2a03:b0c0:3:d0::30b1:9000/124',
#    action  => 'accept',
#    provider => 'ip6tables',
# }

#  firewall { '222 reject all forward /v6':
#    chain   => 'FORWARD',
#    proto   => 'all',
#    action  => 'reject',
#    reject => 'icmp6-adm-prohibited',
#    provider => 'ip6tables',
#  }

  #
  # docker nat fules
  #
  firewall { '000 jump into DOCKER-WAN /v6':
    chain    => 'PREROUTING',
    table    => 'nat',
    proto    => 'all',
    iniface  => 'ens192',
    jump     => 'DOCKER-WAN',
    provider => 'ip6tables',
  }

  firewall { '001 jump into DOCKER-WAN /v6':
    chain    => 'PREROUTING',
    table    => 'nat',
    proto    => 'all',
    iniface  => 'tun0',
    jump     => 'DOCKER-WAN',
    provider => 'ip6tables',
  }

}

class my_fw::post6 {

  #
  # last nat rule(s)
  #
  firewall { '990 accept all from outsite (skip docker dnat) /v6':
    chain    => 'DOCKER-WAN',
    table    => 'nat',
    iniface  => 'ens192',
    proto    => 'all',
    action  => 'accept',
    provider => 'ip6tables',
    before => undef,
  }
  firewall { '991 accept all from outsite (skip docker dnat) /v6':
    chain    => 'DOCKER-WAN',
    table    => 'nat',
    iniface  => 'tun0',
    proto    => 'all',
    action  => 'accept',
    provider => 'ip6tables',
    before => undef,
  }

  #
  # last filter rule
  #
  firewall { '999 reject all /v6':
    proto  => 'all',
    action  => 'reject',
    reject => 'icmp6-adm-prohibited',
    before => undef,
    provider => 'ip6tables',
  }
}

firewallchain { 'INPUT:filter:IPv6':
  purge  => true,
}

firewallchain { 'OUTPUT:filter:IPv6':
  purge  => true,
}

firewallchain { 'FORWARD:filter:IPv6':
#  purge  => true,
  ignore => [
    '-o docker0 -j DOCKER',
  ],
}

firewallchain { 'INPUT:nat:IPv6':
#  purge  => true,
}

firewallchain { 'OUTPUT:nat:IPv6':
#  purge  => true,
}

firewallchain { 'PREROUTING:nat:IPv6':
  purge  => true,
  ignore => [
    '-m addrtype --dst-type LOCAL -j DOCKER',
  ],
}

firewallchain { 'POSTROUTING:nat:IPv6':
#  purge  => true,
}

firewallchain { 'DOCKER-WAN:nat:IPv6':
  purge  => true,
  before => Firewall['000 jump into DOCKER-WAN /v6'],
}

#resources { 'firewall':
#  purge => true,
#}

class { ['my_fw::pre6', 'my_fw::post6']: }

#Firewall {
#  before  => Class['my_fw::post'],
#  require => Class['my_fw::pre'],
#}

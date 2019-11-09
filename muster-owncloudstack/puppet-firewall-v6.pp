#
# firewall manifest
#

# defined is site manifest
#package { 'iptables-services':
#  ensure => installed,
#}

#docs
# https://forge.puppetlabs.com/puppetlabs/firewall#setup
#

# -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
# -A INPUT -p ipv6-icmp -j ACCEPT
# -A INPUT -i lo -j ACCEPT
# -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
# -A INPUT -d fe80::/64 -p udp -m udp --dport 546 -m state --state NEW -j ACCEPT
# -A INPUT -j REJECT --reject-with icmp6-adm-prohibited
# -A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
#
#
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

 firewall { '222 reject all forward /v6':
   chain   => 'FORWARD',
   proto   => 'all',
   action  => 'reject',
   reject => 'icmp6-adm-prohibited',
   provider => 'ip6tables',
 }

}

class my_fw::post6 {

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


#resources { 'firewall':
#  purge => true,
#}

class { ['my_fw::pre6', 'my_fw::post6']: }

#Firewall {
#  before  => Class['my_fw::post'],
#  require => Class['my_fw::pre'],
#}


firewall { '005 accept new tcp to dport 80,433 / APACHE /v6':
  chain   => 'INPUT',
  state   => 'NEW',
  proto   => 'tcp',
  dport   => ['80', '443'],
  action  => 'accept',
  provider => 'ip6tables',
}

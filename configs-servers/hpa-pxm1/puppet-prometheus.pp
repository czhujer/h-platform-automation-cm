
class { 'prometheus::node_exporter':
  version => '0.18.1',
  collectors_disable => ['bcache','bonding', 'conntrack', 'mdadm' ],
}

# class {'prometheus::pve_exporter':
#   version => '0.1.6',
# }

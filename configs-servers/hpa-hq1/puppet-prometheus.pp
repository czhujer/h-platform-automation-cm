
class { 'prometheus::node_exporter':
  version => '0.15.2',
  collectors_disable => ['bcache','bonding', 'conntrack', 'mdadm' ],
}

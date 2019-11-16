
class { 'prometheus::node_exporter':
  version => '0.18.1',
  collectors_disable => ['bcache','bonding', 'conntrack', 'mdadm' ],
}

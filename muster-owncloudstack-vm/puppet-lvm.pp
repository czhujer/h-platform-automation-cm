physical_volume { '/dev/sdb':
  ensure    => present,
  unless_vg => "data",
}

volume_group { 'data':
  ensure           => present,
  physical_volumes => '/dev/sdb',
  createonly       => true,
}

logical_volume { 'lv_owncloud':
  ensure       => present,
  volume_group => 'data',
  #size         => '100%FREE',
}

filesystem { '/dev/data/lv_owncloud':
  ensure  => present,
  fs_type => 'xfs',
  require => Logical_volume['lv_owncloud'],
}

exec { 'mkdir -p /var/www/html/owncloud':
  path   => ['/bin', '/usr/bin'],
  unless => 'test -d /var/www/html/owncloud',
}

mount { '/var/www/html/owncloud':
  #ensure  => present, #only fstab record, not real mount
  ensure  => mounted,
  device  => '/dev/data/lv_owncloud',
  #dump    =>
  remounts => true,
  atboot  => true,
  fstype  => 'xfs',
  require => [
    Exec['mkdir -p /var/www/html/owncloud'],
    Filesystem['/dev/data/lv_owncloud'],
  ],
}

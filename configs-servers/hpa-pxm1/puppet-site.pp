
#
# main manifest
#

# class { 'zabbix::agent':
#   hostname       => "${facts['ipaddress']}",
#   zabbix_version => '3.0',
#   server         => '',
#   serveractive   => '',
#   listenip       => '0.0.0.0',
#   logtype        => 'system',
# }
#
# firewall { "111 accept tcp to dport 10050 from 172.16.2.130 / ZABBIX-AGENT":
#   chain  => 'INPUT',
#   state  => 'NEW',
#   proto  => 'tcp',
#   dport  => ['10050'],
#   source => '172.16.2.130',
#   action => 'accept',
# }
#
# class { 'zabbixagent::plugin2::apt_stats':
#   use_puppetlabs_zabbix_class => true,
# }

#zabbixagent::plugin { 'nginx-stats':
#  use_puppetlabs_zabbix_class => true,
#}

#class { 'zabbixagent::plugin2::systemd_services':
#}

#
# jenkins client
#

# class {'jenkins::slave':
#   masterurl         => 'https://hpa-hq1',
#   install_java      => true,
#   labels            => "debian debian9 hpa-pxm1",
#   version           => '3.17',
#   slave_name        => "hpa-pxm1",
#   executors         => 4,
#   disable_ssl_verification => true,
# }
#
# $c="#\nDefaults:jenkins-slave !requiretty\n#\njenkins-slave	ALL=(ALL)	NOPASSWD: ALL\n"
#
# file {"jenkins-slave sudo file":
#   path => "/etc/sudoers.d/jenkins-slave",
#   ensure  => present,
#   content => $c,
# }

#
# others
#

$packages_system = ["iftop", "tcpdump", "htop", "iotop", "bind9utils", "telnet", "lsof", "traceroute",
  "vim", "iptables-persistent",
]

package { $packages_system:
  ensure => "installed",
}

#
# change MC color scheme
#
if ! defined (Package["mc"]){
  package { 'mc':
    ensure => "installed",
  }
}

if ! defined (File['/root/.config']){
  file { '/root/.config':
    ensure => directory,
    mode    => '0755',
    owner   => 'root',
  }
}

if ! defined (File['/root/.config/mc']){
  file { '/root/.config/mc':
    ensure => directory,
    mode    => '0755',
    owner   => 'root',
  }
}

#$mc_color_schema = "gray,black:normal=orange,black:selected=black,brown:marked=black,white:markselect=black,brown:errors=white,red:menu=black,brown:reverse=brightbrown,black:dnormal=black,lightgray:dfocus=black,cyan:dhotnormal=blue,lightgray:dhotfocus=blue,cyan:viewunderline=black,green:menuhot=white,gray:menusel=white,black:menuhotsel=yellow,black:helpnormal=black,lightgray:helpitalic=red,lightgray:helpbold=blue,lightgray:helplink=black,cyan:helpslink=yellow,blue:gauge=white,black:input=brown,gray:directory=brown,gray:executable=brown,gray:link=brightbrown,gray:stalelink=brightred,blue:device=magenta,gray:core=red,blue:special=black,blue:editnormal=white,black:editbold=yellow,blue:editmarked=black,white:errdhotnormal=yellow,red:errdhotfocus=yellow,lightgray"
$mc_color_schema = "gray,black:normal=yellow,black:selected=black,yellow:marked=yellow,brown:markselect=black,magenta:errors=white,red:menu=yellow,gray:reverse=brightmagenta,black:dnormal=black,lightgray:dfocus=black,cyan:dhotnormal=blue,lightgray:dhotfocus=blue,cyan:viewunderline=black,green:menuhot=red,gray:menusel=white,black:menuhotsel=yellow,black:helpnormal=black,lightgray:helpitalic=red,lightgray:helpbold=blue,lightgray:helplink=black,cyan:helpslink=yellow,blue:gauge=white,black:input=yellow,gray:directory=brightred,gray:executable=brightgreen,gray:link=brightcyan,gray:stalelink=brightred,blue:device=white,gray:core=red,blue:special=black,blue:editnormal=white,black:editbold=yellow,blue:editmarked=black,white:errdhotnormal=yellow,red:errdhotfocus=yellow,lightgray"

ini_setting { 'mc change colorschema':
  ensure  => present,
  path    => "/root/.config/mc/ini",
  section => 'Colors',
  setting => 'base_color',
  value   => $mc_color_schema,
  require => [ Package["mc"], File["/root/.config/mc"], ],
}

#
# time & timezone
#

#class { 'timezone':
#  timezone => 'Europe/Prague',
#}

#
# openvpn
#

#class { 'openvpn':
#  manage_service => true,
#}

#service {'cron':
#  ensure => 'true',
#  enable => 'true',
#  require => Package[$packages_system],
#}

#
# requirements for duplicity
#

$back2own_dupl_deps = ["librsync-dev", "python-dev", "gcc",
  "python-lockfile", "python-paramiko", "duplicity"]

package{ $back2own_dupl_deps:
  ensure => installed,
}

#
# requirements for zoner DNS API script
#
package{ ['php7.0-common', 'php7.0-xml', 'php7.0-mbstring', 'php7.0-cli']:
  ensure => installed,
}

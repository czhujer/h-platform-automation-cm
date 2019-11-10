#
# main manifest
#

# class { 'zabbix::agent':
#   hostname       => "${facts['ipaddress']}",
#   zabbix_version => '3.0',
#   server         => '172.16.2.130',
#   serveractive   => '172.16.2.130',
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
# zabbixagent::plugin {'redhat-yum-stats':
#   use_puppetlabs_zabbix_class => true,
# }
#
# zabbixagent::plugin { 'nginx-stats':
#   use_puppetlabs_zabbix_class => true,
# }
#
# class { 'zabbixagent::plugin2::systemd_services':
# }

#
# jenkins client
#
#class {'jenkins::slave':
#  masterurl    => 'http://127.0.0.1:8080',
#  install_java => false,
#  labels       => "centos centos6 master_cz sf-ifs sf-jenkins-test",
#  version      => '3.7',
#  slave_name   => "sf-jenkins-test",
#  executors    => 99,
#  ensure       => stopped,
#  enable       => false,
#}

#$c="#\nDefaults:jenkins-slave !requiretty\n#\njenkins-slave	ALL=(ALL)	NOPASSWD: ALL\n"

#file {"jenkins-slave sudo file":
#    path => "/etc/sudoers.d/jenkins-slave",
#    content => $c,
#    ensure  => false,
#}

#
# openvpn part
#

#class { 'openvpn':
#  manage_service => true,
#}

#
# others
#

$packages_system = [ "irqbalance", "acpid", "iftop", "iptraf", "tcpdump", "htop", "iotop", "bind-utils"]

package { $packages_system:
    ensure => 'installed',
#    #before => [ Class["zabbixagent"], ],
}


class { 'timezone':
    timezone => 'Europe/Prague',
}

#class { '::ntp':
#    restrict => ['127.0.0.1'],
#    logfile => "/var/log/ntp",
#    keys_enable => true,
#    keys_file => "/etc/ntp/keys",
#    keys_trusted => ["1"],
#    keys_requestkey => "1",
#    service_enable => true,
#    service_ensure => "running",
#}

#class { 'java':
##      version  => "1.8.0.101-3.b13.el6_8",
#      package => "java-1.8.0-openjdk-devel",
#      notify  => [ Service["jenkins-slave"],
#                   Service["jenkins"],
#                 ],
#}

#service {'crond':
#  ensure => 'true',
#  enable => 'true',
#  require => Package[$packages_system],
#}

# requirements for duplicity

$back2own_dupl_deps = ["librsync-devel", "python-devel", "gcc",
                       "python-lockfile", "python-paramiko", "python-GnuPGInterface"]

package{ $back2own_dupl_deps:
    ensure => installed,
}


    # change MC color scheme
    #
    if ! defined (Package["mc"]){
      package { 'mc':
        ensure => "installed",
      }
    }

    if ! defined (File["/root/.mc"]){
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

#
#pristupy
#
user { 'root':
  ensure     => present,
  home       => '/root',
  purge_ssh_keys => true,
}

# ssh_authorized_key { 'user':
#   user => 'root',
#   type => 'ssh-rsa',
#   key  => '_key_',
# }

#
# others
#

$packages_system = ["iftop", "iptraf", "tcpdump", "htop", "iotop",
                    "bind-utils", "telnet", "lsof", "vim-minimal", "yum-utils",
                    "traceroute", "vim-enhanced", "numad", "yum-cron", "apachetop",
                    "deltarpm", "sudo", "wget",
                ]

package { $packages_system:
    ensure => "installed",
}

#timezone add ntp is already declared in owncloud-stack module

#package { 'duplicity':
#    ensure => "installed",
#}

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
  require => [ Package["mc"], File['/root/.config'], File['/root/.config/mc'], ],
}

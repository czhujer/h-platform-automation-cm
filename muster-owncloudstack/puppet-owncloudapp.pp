#
# ap settings
#

file {'/var/www/html/owncloud/config/config.php':
  ensure => present,
  owner  => 'apache',
  group  => 'apache',
  mode   => '0640',
  require => Class['owncloudstack'],
}

# update settings - direct in config
#

# /var/www/html/owncloud/config/config.php
#   'memcache.locking' => '\\OC\\Memcache\\Redis',
#  'memcache.local' => '\OC\Memcache\APCu',

file_line { 'owncloud php hashbang config':
  ensure => present,
  path   => '/var/www/html/owncloud/config/config.php',
  line   => '<?php',
  match  => '<\?php',
  require => File['/var/www/html/owncloud/config/config.php'],
}

file_line { 'owncloud memcache locking config':
  ensure => present,
  path   => '/var/www/html/owncloud/config/config.php',
  line   => '$CONFIG[\'memcache.locking\'] = \'\\\OC\\\Memcache\\\Redis\';',
  match  => '\$CONFIG\[\'memcache\.locking',
  #after  => '\$CONFIG = array \(',
  require => File_line['owncloud php hashbang config'],
}
file_line { 'owncloud memcache local config':
  ensure => present,
  path   => '/var/www/html/owncloud/config/config.php',
  line   => '$CONFIG[\'memcache.local\'] = \'\\\OC\\\Memcache\\\APCu\';',
  match  => '\$CONFIG\[\'memcache\.local',
  #after  => '\$CONFIG = array \(',
  require => File_line['owncloud php hashbang config'],
}

# https://doc.owncloud.com/server/admin_manual/configuration/server/language_configuration.html
file_line { 'owncloud language config':
  ensure => present,
  path   => '/var/www/html/owncloud/config/config.php',
  line   => '$CONFIG[\'default_language\'] = \'cs_CZ\';',
  match  => '\$CONFIG\[\'default_language',
  #after  => '\$CONFIG = array \(',
  require => File_line['owncloud php hashbang config'],
}

#
# app install - finish part
#
exec { 'trigger oc-install finish part':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'curl https://127.0.0.1 -k',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ user:list 1>/dev/null 2>&1',
  require => [
    File_line['owncloud memcache locking config'],
    File_line['owncloud memcache local config'],
    File_line['owncloud language config'],
    Php::Fpm::Conf['www'],
    Service['php-fpm'],
    Apache::Vhost['owncloud-ssl'],
  ],
}

# update settings
#

# https://doc.owncloud.org/server/admin_manual/configuration/server/occ_command.html#background-jobs-selector
# https://doc.owncloud.com/server/10.0/admin_manual/configuration/server/occ_command.html?highlight=occ#background-jobs-selector
#
exec { 'oc_switch_cron_job':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ background:cron',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:app:get core backgroundjobs_mode |grep cron 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_logtimezone':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set logtimezone --value="Europe/Prague"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get logtimezone |grep "Europe/Prague" 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

# sudo -u apache php /var/www/html/owncloud/occ config:system:set upgrade.disable-web --value=false --type=boolean
exec { 'oc_set_upgrade_disable_web':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set upgrade.disable-web --value=false --type=boolean',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get upgrade.disable-web |grep false 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

# install app(s)
#
exec { 'oc_install_activity_app':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ market:install activity',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ app:list | grep activity 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

# disable market
#
exec { 'oc_disable_market_app':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ app:disable market',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ app:list |grep Disabled -A 99 | grep market 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

# setup outbound mail 
#
exec { 'oc_set_smtpmode':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtpmode --value="smtp"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtpmode | grep smtp 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_smtphost':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtphost --value="mail.algoportal.cz"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtphost | grep mail.algoportal.cz 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_smtpport':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtpport --value=587',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtpport | grep 587 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_smtpauth':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtpauth --value=true --type=boolean',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtpauth | grep true 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_smtpauthtype':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtpauthtype --value="LOGIN"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtpauthtype | grep LOGIN 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_smtpname':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtpname --value="noreply@ceskycloud.cz"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtpname | grep \'noreply@ceskycloud.cz\' 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

# exec { 'oc_set_smtppassword':
#   path    => '/usr/bin:/usr/sbin:/bin',
#   command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtppassword --value=""',
#   unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtppassword | grep "" 2>/dev/null',
#   require => Exec['trigger oc-install finish part'],
# }

exec { 'oc_set_smtpsecure':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_smtpsecure --value="tls"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_smtpsecure | grep \'tls\' 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_mail_domain':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_domain --value="ceskycloud.cz"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_domain | grep "ceskycloud.cz" 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

exec { 'oc_set_mail_from_address':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => 'sudo -u apache php /var/www/html/owncloud/occ config:system:set mail_from_address --value="noreply"',
  unless  => 'sudo -u apache php /var/www/html/owncloud/occ config:system:get mail_from_address | grep noreply 2>/dev/null',
  require => Exec['trigger oc-install finish part'],
}

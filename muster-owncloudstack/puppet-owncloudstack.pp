#
# apache server
#
  class { '::apache':
      default_vhost => false,
      mpm_module    => 'prefork',
      purge_configs => true,
      #
      serveradmin          => 'info@example.com',
      server_signature     => 'off',
      server_tokens        => 'prod',
      #keepalive            => $apache_keepalive,
      keepalive_timeout    => 2,
      timeout              => '90',
      #
      default_mods         => [ 'actions', 'authn_core', 'cache', 'ext_filter', 'mime', 'mime_magic', 'rewrite', 'speling',
                                    'version', 'vhost_alias', 'auth_digest', 'authn_anon', 'authn_dbm', 'authz_dbm', 'authz_owner',
                                    'expires', 'include', 'logio', 'substitute', 'usertrack', 'alias',
                                    'authn_file', 'autoindex', 'dav', 'dav_fs', 'dir', 'negotiation', 'setenvif', 'auth_basic',
                                    'authz_user', 'authz_groupfile', 'env', 'suexec'],
      #
  }

  class { 'apache::mod::status':
    #allow_from      => ['127.0.0.1','::1'],
    requires        => [
                    'ip 127.0.0.1', #ipv4 localhost
                    'ip ::1', #ipv6 localhost
                    'ip 192.168.222.1', # gw
                   ],
    extended_status => 'On',
    status_path     => '/server-status',
  }

  class { 'apache::mod::ssl':
  }

  class { 'php::cli':
    #ensure           => $php_pkg_version_full,
    #cli_package_name => $php_cli_package_name,
  }

  class { 'php::common':
    #common_package_name => $php_common_package_name,
    require             => Class['php::cli'],
  }

  class { 'apache::mod::proxy':
    #proxy_timeout => $apache_php_proxy_timeout,
  }
  class { 'apache::mod::proxy_fcgi':
  }

  php::ini { '/etc/php.ini':
     #error_reporting            => "$php_error_reporting"
     #memory_limit               => "$php_memory_limit",
     date_timezone              => "Europe/Berlin",
     max_execution_time         => '90',
     allow_url_fopen            => 'On',
     #upload_max_filesize        => $php_upload_max_filesize,
     #post_max_size              => $php_post_max_size,
     #session_gc_maxlifetime     => $php_session_gc_maxlifetime,
     #session_save_handler       => $php_session_save_handler,
     #session_save_path          => $php_session_save_path,
  }

  php::fpm::conf { 'www':
    package_name   => 'php-fpm',
    listen         => '127.0.0.1:9001',
    user           => 'apache',
    pm_status_path => '/fpm-status',
    ping_path      => '/fpm-ping',
    #
    php_value      => {
      # error_reporting        => $php_error_reporting,
      # memory_limit           => $php_memory_limit,
      date_timezone          => 'Europe/Berlin',
      # max_execution_time     => $php_max_execution_time,
      allow_url_fopen        => 'On',
      # upload_max_filesize    => $php_upload_max_filesize,
      # post_max_size          => $php_post_max_size,
      # session_gc_maxlifetime => $php_session_gc_maxlifetime,
      # session_save_handler   => $php_session_save_handler,
      # session_save_path      => $php_session_save_path,
    },
  }~>File['/var/log/php-fpm']

  class { 'php::fpm::daemon':
    ensure       => present,
    package_name => 'php-fpm',
    log_owner    => 'apache',
    log_group    => 'apache',
    log_dir_mode => '0775',
  }

  apache::vhost { 'owncloud':
    serveraliases   => '*',
    port            => '80',
    docroot         => '/var/www/html/owncloud-http',
    error_log_file  => 'error_log',
    access_log_file => 'access_log',
    rewrites => [
      {
        comment      => 'redirect to HTTPS',
        rewrite_cond => ['%{SERVER_PORT} !^443$'],
        rewrite_rule => ['^/(.*) https://%{HTTP_HOST}/$1 [NC,R,L]'],
      },
    ],
  }

  apache::vhost { 'owncloud-ssl':
    serveraliases   => '*',
    port            => '443',
    docroot         => '/var/www/html/owncloud',
    docroot_group   => 'apache',
    docroot_owner   => 'apache',
    docroot_mode    => '755',
    ssl             => true,
    #
    error_log_file  => 'ssl_error_log',
    access_log_file => 'ssl_access_log',
    #
    setenvif        => [
      'Authorization "(.+)" HTTP_AUTHORIZATION=$$1',
    ],
    #
    proxy_pass_match => [
      # {
      # 'path' => '^/phpmyadmin/(.*\.php)$',
      # 'url'  => 'fcgi://127.0.0.1:9002/usr/share/phpMyAdmin/$1',
      # },{
      # 'path' => '/phpmyadmin(.*/)$',
      # 'url'  => 'fcgi://127.0.0.1:9002/usr/share/phpMyAdmin$1index.php'
      # },{
      # 'path' => '^/phpMyAdmin/(.*\.php)$',
      # 'url'  => 'fcgi://127.0.0.1:9002/usr/share/phpmyadmin/$1'
      # },{
      # 'path' => '^/phpMyAdmin(.*/)$',
      # 'url'  => 'fcgi://127.0.0.1:9002/usr/share/phpMyAdmin$1index.php'
      # },
      {
      'path' => '^/(.*\.php(/.*)?)$',
      'url'  => 'fcgi://127.0.0.1:9001/var/www/html/owncloud/$1'
      },
    ],
    #
    directories => [
       {
         path             => "/var/www/html/owncloud",
         provider         => 'directory',
         require        => 'all granted',
         allow_override => ['all'],
         options        => ['all'],
       },
       {
         path             => "/var/www/html",
         provider         => 'directory',
         require        => 'all granted',
         allow_override => ['all'],
         options        => ['all'],
      },
      # for phpMyAdmin
      # {
      #    path             => "/usr/share/phpMyAdmin/",
      #    provider         => 'directory',
      #    order            => 'Allow,Deny',
      #    'allow'          => 'from all',
      #    adddefaultcharset => 'UTF-8',
      # },
      # {
      #    path             => "/usr/share/phpMyAdmin/setup/",
      #    provider         => 'directory',
      #    order            => 'Deny,Allow',
      #    'deny'          => 'from All',
      #    'allow'          => 'from None',
      # },
      # {
      #    path             => "/usr/share/phpMyAdmin/libraries/",
      #    provider         => 'directory',
      #    order            => 'Deny,Allow',
      #    'deny'           => 'from All',
      #    'allow'          => 'from None',
      # },
      # {
      #    path             => "/usr/share/phpMyAdmin/setup/lib/",
      #    provider         => 'directory',
      #    order            => 'Deny,Allow',
      #    'deny'           => 'from All',
      #    'allow'          => 'from None',
      # },
      # {
      #    path             => "/usr/share/phpMyAdmin/.git",
      #    provider         => 'directory',
      #    order            => 'Deny,Allow',
      #    'deny'           => 'from All',
      #    'allow'          => 'from None',
      # },
      # {
      #    path             => "/usr/share/phpMyAdmin/setup/frames/",
      #    provider         => 'directory',
      #    order            => 'Deny,Allow',
      #    'deny'           => 'from All',
      #    'allow'          => 'from None',
      # },
    ],
    aliases => [
      # {
      #   alias            => '/phpMyAdmin',
      #   path             => '/usr/share/phpMyAdmin',
      # },
      # {
      #   alias            => '/phpmyadmin',
      #   path             => '/usr/share/phpMyAdmin',
      # },
    ],
  }

  class {'owncloudstack':
      owncloud_version => '10',
      manage_apache => false,
      manage_vhost  => false,
      manage_clamav => false,
      manage_fail2ban => false,
      manage_sendmail => false,
      libreoffice_pkg_manage => false,
      manage_ntp => false,
      manage_phpmysql => false,
      mysql_override_options => { mysqld => {
          'innodb_buffer_pool_instances' => '1',
          'innodb_buffer_pool_size'      => '256M',
          'innodb_log_file_size'         => '32M',
          #
              'log_warnings' => '4',
              'slow_query_log' => '1',
              'slow_query_log_file' => '/var/log/mysql-slow.log',
              'log_output' => 'table,file', #!! for GENERAL and SLOW-QUERY
              'long_query_time' => '1',
              'query_cache_type' => '1',
              'query_cache_size' => '64M',
              'key_buffer_size'  => '4M',
       }
      },
      php_extra_modules => ['php-pecl-apcu', 'php-pecl-redis', 'php-opcache', 'php-xml', 'php-gd', 'php-intl',
                            'php-mbstring', 'php-process', 'php-zip', 'php-bcmath', 'php-mysqlnd',],
      owncloud_ssl => true,
      php_version => '7.1',
      owncloud_cron_file => '/var/www/html/owncloud/cron.php',
  }

  php::module::ini { 'opcache':
        pkgname => "php-opcache",
        prefix  => '10',
        zend    => true,
        settings => {
          'opcache.enable'                     => '1',
          'opcache.fast_shutdown'              => '1',
          'opcache.interned_strings_buffer'    => '16',
          'opcache.max_accelerated_files'      => '1000000',
          'opcache.memory_consumption'         => '256',
          'opcache.revalidate_freq'            => '0',
          'opcache.revalidate_path'            => '1',
        },
  }

class { 'redis':
  bind => '127.0.0.1';
    #masterauth  => 'secret';
}

#  cron::job{
#    "owncloud":
#      minute      => '*/15',
#      hour        => '*',
#      date        => '*',
#      month       => '*',
#      weekday     => '*',
#      user        => 'apache',
#      command     => "php -f /var/www/owncloud/cron.php > /dev/null 2>&1",
#      environment => [ 'PATH="/usr/bin:/bin"' ],
#      notify      => Service["crond"],
#  }

  # sudo -u apache php /var/www/html/owncloud/occ trashbin:cleanup
#  cron::daily{
#    "owncloud-erase-files-in-trash":
#      minute      => '11',
#      user        => 'apache',
#      command     => "php /var/www/html/owncloud/occ trashbin:cleanup",
#      environment => [ 'PATH="/usr/bin:/bin"' ],
#      notify      => Service["crond"],
#  }

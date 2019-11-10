#
# nginx part
#

apt::source { 'nginx':
 location => 'https://nginx.org/packages/debian/',
 release  => 'stretch',
 repos    => 'nginx',
 include  => {
   'src' => true,
   'deb' => true,
 },
 key      => {
   'id'     => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62',
 },
}

class { 'nginx':
  package_source => 'nginx-mainline',
  #  service_ensure => 'undef',
  #  service_restart => 'undef',
  confd_purge   => true,
  #vhost_purge   => true,
  server_purge  => true,
  #
  manage_repo   => false, #because duplicate defs for package['apt-transport-https']
  #
  log_format    => { 'timed_combined' => "\$remote_addr \$host \$remote_user [\$time_local]  '\n  '\"\$request\" \$status \$body_bytes_sent '\n  '\"\$http_referer\" \"\$http_user_agent\" \$request_time \$upstream_response_time \$pipe" },
  # compression
  gzip_comp_level => 2,
  gzip_proxied  => "any",
  gzip_vary     => "on",
  gzip_types    => "text/plain text/xml text/css application/x-javascript application/javascript application/json",
  #
  server_tokens => 'off',
  #
  spdy          => 'off',
  http2         => 'on',
#   # load vts module
#   nginx_cfg_prepend => { 'load_module' => '/usr/lib64/nginx/modules/ngx_http_vhost_traffic_status_module.so'},
#   # enable vts module
#   http_cfg_append => { 'vhost_traffic_status_zone' => ''},
}

firewall { '120 accept tcp to dports 80,443 / NGINX':
  chain   => 'INPUT',
  state   => 'NEW',
  proto   => 'tcp',
  dport   => ['80', '443'],
  action  => 'accept',
}

exec { "create custom dh params":
  command => "openssl dhparam -out /etc/ssl/dhparams.pem 2048",
  path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
  unless => 'stat /etc/ssl/dhparams.pem',
  before => Service["nginx"],
}

# upstream
nginx::resource::upstream { 'exporter-node':
  members => ['127.0.0.1:9100',],
}

#default vhost

nginx::resource::server { '_':
  ssl         => true,
  ssl_dhparam => '/etc/ssl/dhparams.pem',
  ssl_cert    => '/etc/ssl/certs/localhost.crt',
  ssl_key     => '/etc/ssl/private/localhost.key',
  #ssl_ciphers => 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA',
  ssl_ciphers => 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA:!3DES:!DES-CBC3-SHA',
  ##
  #ssl_stapling        => true,
  #ssl_stapling_verify => true,
  #ssl_trusted_cert    => '/etc/ssl/certs/ca_rapidssl_stapling.pem',
  #
  ssl_protocols       => 'TLSv1.2 TLSv1.3',
  #
  server_cfg_append => {
    'add_header' => [
      #'Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"',
      'X-Frame-Options "SAMEORIGIN" always',
      'X-Xss-Protection "1; mode=block" always',
      'X-Content-Type-Options "nosniff"',
      #                        'Content-Security-Policy "default-src \'self\'; script-src \'self\'; object-src \'self\'"',
      'Content-Security-Policy "default-src \'self\'; script-src \'self\' ; object-src \'self\'; style-src \'self\' ; "',
      'Referrer-Policy "no-referrer, strict-origin-when-cross-origin"',
    ],
  },
  add_header => {
  },
  #
  www_root    => "/var/www/html",
  location_cfg_append => {
    'rewrite' => '^ https://www.hsoftware.cz? permanent',
    'proxy_set_header'   => [
      # because: Inet <-> HTTPS (nginx) <-> HTTP (apache)
      #'X-Forwarded-Proto $scheme',
      # because: compression moved to nginx:
      #'Accept-Encoding ""',
    ],
    #because: better security
    'add_header' => [
      #'Strict-Transport-Security  "max-age=31536000; includeSubDomains; preload"',
      'X-Frame-Options "SAMEORIGIN" always',
      'X-Xss-Protection "1; mode=block" always',
      'X-Content-Type-Options "nosniff"',
      #                        'Content-Security-Policy "default-src \'self\'; script-src \'self\'; object-src \'self\'"',
      'Content-Security-Policy "default-src \'self\'; script-src \'self\' ; object-src \'self\'; style-src \'self\' ; "',
      'Referrer-Policy "no-referrer, strict-origin-when-cross-origin"',
    ],
  },
}

nginx::resource::location { "__status":
  ensure          => present,
  ssl             => true,
  ssl_only        => true,
  server          => '_',
  www_root        => "/var/www/html",
  location        => '/nginx_stat',
  proxy           => undef,
  stub_status      => true,
  location_allow   => ['127.0.0.1'],
  location_deny    => ['all'],
  location_cfg_append => {
    'access_log' => 'off',
  }
}

nginx::resource::server { "${facts['ipaddress']}":
  ssl         => true,
  listen_port => 443,
  ssl_dhparam => '/etc/ssl/dhparams.pem',
  ssl_cert    => '/etc/ssl/certs/localhost.crt',
  ssl_key     => '/etc/ssl/private/localhost.key',
  #ssl_ciphers => 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA',
  ssl_ciphers => 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA:!3DES:!DES-CBC3-SHA',
  ##
  #ssl_stapling        => true,
  #ssl_stapling_verify => true,
  #ssl_trusted_cert    => '/etc/ssl/certs/ca_rapidssl_stapling.pem',
  #
  ssl_protocols       => 'TLSv1.2 TLSv1.3',
  #
  server_cfg_append => {
    'add_header' => [
      #because: better security
      #'Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"',
      'X-Frame-Options "SAMEORIGIN" always',
      'X-Xss-Protection "1; mode=block" always',
      'X-Content-Type-Options "nosniff"',
      #                        'Content-Security-Policy "default-src \'self\'; script-src \'self\'; object-src \'self\'"',
      'Content-Security-Policy "default-src \'self\'; script-src \'self\' ; object-src \'self\'; style-src \'self\' ; "',
      'Referrer-Policy "no-referrer, strict-origin-when-cross-origin"',
    ],
  },
  add_header => {
  },
  www_root    => "/var/www/html",
  location_cfg_append => {
    'rewrite' => '^ https://www.hsoftware.cz? permanent',
    'proxy_set_header'   => [
      # because: Inet <-> HTTPS (nginx) <-> HTTP (apache)
      #'X-Forwarded-Proto $scheme',
      # because: compression moved to nginx:
      'Accept-Encoding ""',
    ],
    #because: better security
    'add_header' => [
      #'Strict-Transport-Security  "max-age=31536000; includeSubDomains; preload"',
      'X-Frame-Options "SAMEORIGIN" always',
      'X-Xss-Protection "1; mode=block" always',
      'X-Content-Type-Options "nosniff"',
      #                        'Content-Security-Policy "default-src \'self\'; script-src \'self\'; object-src \'self\'"',
      'Content-Security-Policy "default-src \'self\'; script-src \'self\' ; object-src \'self\'; style-src \'self\' ; "',
      'Referrer-Policy "no-referrer, strict-origin-when-cross-origin"',
    ],
  },
}

nginx::resource::location { "${facts['ipaddress']}-node":
  ensure          => present,
  www_root        => undef,
  ssl             => true,
  ssl_only        => true,
  server          => "${facts['ipaddress']}",
  location        => '/exporter-node/metrics',
  proxy           => 'http://exporter-node/metrics',
  location_allow  => [
    '127.0.0.1', '::1', #localhost
  ],
  location_deny   => ['all'],
}

nginx::resource::location { "${facts['ipaddress']}_status":
  ensure          => present,
  ssl             => true,
  ssl_only        => true,
  server          => "${facts['ipaddress']}",
  www_root        => "/var/www/html",
  location        => '/nginx_stat',
  proxy           => undef,
  stub_status      => true,
  location_allow   => ['127.0.0.1' ],
  location_deny    => ['all'],
  location_cfg_append => {
    'access_log' => 'off',
  }
}

nginx::resource::server { "${facts['ipaddress']}_http":
  ssl         => false,
  www_root    => "/var/www/html",
  listen_options => 'default_server',
  #
  server_cfg_append => {
    'add_header' => [
      #because: better security
      #'Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"',
      'X-Frame-Options "SAMEORIGIN" always',
      'X-Xss-Protection "1; mode=block" always',
      'X-Content-Type-Options "nosniff"',
      #                        'Content-Security-Policy "default-src \'self\'; script-src \'self\'; object-src \'self\'"',
      'Content-Security-Policy "default-src \'self\'; script-src \'self\' ; object-src \'self\'; style-src \'self\' ; "',
      'Referrer-Policy "no-referrer, strict-origin-when-cross-origin"',
    ],
  },
  #
  location_cfg_append => {
    'rewrite' => "^ https://${facts['ipaddress']}? permanent",
    'proxy_set_header'   => [
      # because: Inet <-> HTTPS (nginx) <-> HTTP (apache)
      #'X-Forwarded-Proto $scheme',
      # because: compression moved to nginx:
      #'Accept-Encoding ""',
    ],
    #because: better security
    'add_header' => [
      #'Strict-Transport-Security  "max-age=31536000; includeSubDomains; preload"',
      'X-Frame-Options "SAMEORIGIN" always',
      'X-Xss-Protection "1; mode=block" always',
      'X-Content-Type-Options "nosniff"',
      #                        'Content-Security-Policy "default-src \'self\'; script-src \'self\'; object-src \'self\'"',
      'Content-Security-Policy "default-src \'self\'; script-src \'self\' ; object-src \'self\'; style-src \'self\' ; "',
      'Referrer-Policy "no-referrer, strict-origin-when-cross-origin"',
    ],
  },
}

# nginx::resource::location { "${facts['ipaddress']}_status2":
#   ensure                => present,
#   #ssl             => true,
#   #ssl_only        => true,
#   server              => "${facts['ipaddress']}",
#   www_root            => "/var/www/html",
#   location            => '/nginx_vts_status',
#   proxy               => undef,
#   #stub_status      => true,
#   location_allow      => ['127.0.0.1'],
#   location_deny       => ['all'],
#   location_cfg_append => {
#     'access_log'                          => 'off',
#     # vts module params
#     'vhost_traffic_status_display'        => '',
#     'vhost_traffic_status_display_format' => 'html',
#   }
# }

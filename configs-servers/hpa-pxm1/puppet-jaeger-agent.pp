
$version = "1.18.1"
$install_directory = "/opt/jaeger-agent-${version}"
$basefilename = "jaeger-${version}.tgz"

group { 'jaeger-agent':
  ensure => present,
}

user { 'jaeger-agent':
  ensure  => present,
  shell   => '/bin/bash',
  require => Group['jaeger-agent'],
}

file { '/var/tmp/jaeger-agent':
  ensure  => directory,
  owner   => 'jaeger-agent',
  group   => 'jaeger-agent',
  require => [
    Group['jaeger-agent'],
    User['jaeger-agent'],
  ],
}

file { $install_directory:
  ensure  => directory,
  owner   => 'jaeger-agent',
  group   => 'jaeger-agent',
  require => [
    Group['jaeger-agent'],
    User['jaeger-agent'],
  ],
}

file { '/opt/jaeger-agent':
  ensure  => link,
  target  => $install_directory,
  #notify  => $install_notify,
  require => File[$install_directory],
}

archive { "/var/tmp/jaeger-agent/${basefilename}":
  ensure          => present,
  extract         => true,
  extract_command => 'tar xfz %s --strip-components=1',
  extract_path    => $install_directory,
  source          => "https://github.com/jaegertracing/jaeger/releases/download/v${version}/jaeger-${version}-linux-amd64.tar.gz",
  creates         => "${install_directory}/jaeger-agent",
  cleanup         => true,
  user            => 'jaeger-agent',
  group           => 'jaeger-agent',
  require         => [
    File['/var/tmp/jaeger-agent'],
    File[$install_directory],
    Group['jaeger-agent'],
    User['jaeger-agent'],
  ],
}

include systemd

$service_name = 'jaeger-agent'

$service_unit_content = '#
[Unit]
Description=jaeger agent
Wants=basic.target
After=basic.target network.target

[Service]
User=jaeger-agent
Group=jaeger-agent
#EnvironmentFile=/etc/default/jaeger_agent
ExecStart=/opt/jaeger-agent/jaeger-agent \
--reporter.grpc.host-port=tracing-stack:14250

ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
'

file { "/etc/systemd/system/${service_name}.service":
  ensure  => file,
  mode    => '0644',
  content => $service_unit_content,
}

File["/etc/systemd/system/${service_name}.service"]
~> Exec['systemctl-daemon-reload']
-> Service[$service_name]

service { $service_name:
  ensure     => true,
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
}

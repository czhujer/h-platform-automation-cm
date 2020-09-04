# C&C server defs
#
docker_compose { 'c-and-c-server':
  compose_files => ['/root/docker-compose/c-and-c-server/docker-compose.yaml'],
  ensure  => present,
  require => Vcsrepo['/root/h-platform-automation-cc-server'],
}

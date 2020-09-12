#!/bin/bash

STACK_NAME="traefik-stack"

echo "Installing docker-compose systemd service..."

(
cat <<-EOF
[Unit]
Description=%i service with docker compose
Requires=docker.service
After=docker.service

[Service]
Restart=always

WorkingDirectory=/etc/docker/compose/%i

# Remove old containers, images and volumes
ExecStartPre=/usr/bin/docker-compose down -v
ExecStartPre=/usr/bin/docker-compose rm -fv
ExecStartPre=-/bin/bash -c 'docker volume ls -qf "name=%i_" | xargs docker volume rm'
#ExecStartPre=-/bin/bash -c 'docker network ls -qf "name=%i_" | xargs docker network rm'
ExecStartPre=-/bin/bash -c 'docker ps -aqf "name=%i_*" | xargs docker rm'

# Compose up
ExecStart=/usr/bin/docker-compose up

# Compose down, remove containers and volumes
ExecStop=/usr/bin/docker-compose down -v

[Install]
WantedBy=multi-user.target
EOF
) | tee /etc/systemd/system/docker-compose@.service

sudo systemctl daemon-reload

echo "Preparing ENV for ${STACK_NAME}.."

mkdir -p /etc/docker/compose/${STACK_NAME}

#(
#cat <<-EOF3
#MYSQL_ROOT_PASSWORD=your_root_password
#MYSQL_USER=your_wordpress_database_user
#MYSQL_PASSWORD=your_wordpress_database_password
#EOF3
#) | tee /etc/docker/compose/${STACK_NAME}/.env

echo "Starting ${STACK_NAME} docker-compose service..."

sudo systemctl restart docker-compose@${STACK_NAME}

sudo systemctl enable docker-compose@${STACK_NAME}

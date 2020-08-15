#!/bin/bash

yum clean all -q

yum install which virt-what yum-utils epel-release deltarpm -y -q

#for vagrant/facter
yum install bind-utils net-tools -y -q

yum update -y -q

# Install dependencies for RVM and Ruby...
#if which yum &>/dev/null; then
yum -q -y install gcc-c++ patch readline-devel zlib-devel libxml2-devel libyaml-devel libxslt-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison git augeas-devel
#  # patch, libyaml-devel, glibc-headers, autoconf, gcc-c++, glibc-devel, patch, readline-devel, zlib-devel, libffi-devel, openssl-devel, automake, libtool, bison, sqlite-devel
#else
#  echo "ERROR: devel packages instalation failed";
#fi

yum install -q -y yum install centos-release-scl

yum install rh-ruby26 rh-ruby26-ruby-devel -y -q

#mkdir -p /usr/local/share/gems && mkdir -p /usr/local/rvm/gems && ln -s /usr/local/share/gems /usr/local/rvm/gems/ruby-2.4.3

echo 'source /opt/rh/rh-ruby26/enable' >> /root/.bashrc

echo '' >> /root/.bashrc;
echo 'unset GEM_HOME' >> /root/.bashrc;
echo 'unset GEM_PATH' >> /root/.bashrc;

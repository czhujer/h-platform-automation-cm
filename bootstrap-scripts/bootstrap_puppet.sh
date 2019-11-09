#!/bin/bash

  # Update rubygems, and pull down facter and then puppet...
  #gem update --system
  #gem update --system --no-ri --no-rdoc --install-dir /usr/local/share/gems -q
  gem update --system --no-ri --no-rdoc -q # --install-dir /usr/share/gems

  gem install json_pure --no-ri --no-rdoc #--install-dir /usr/share/gems
  gem install facter --no-ri --no-rdoc #--install-dir /usr/share/gems
  #gem install libshadow --no-ri --no-rdoc #--install-dir /usr/share/gems
  gem install puppet-module --no-ri --no-rdoc #--install-dir /usr/share/gems
  gem install ruby-augeas --no-ri --no-rdoc #--install-dir /usr/share/gems
  gem install syck --no-ri --no-rdoc #--install-dir /usr/share/gems
  gem install puppet --no-ri --no-rdoc -v5.5.10 #--install-dir /usr/share/gems

  # install r10k
  gem install --no-rdoc --no-ri r10k -v3.1.0 #--install-dir /usr/share/gems

  #remove old gems
  gem uninstall puppet --version '<5.5.10' -a
  gem uninstall r10k --version '<3.1.0' -a

  if [ ! -L /etc/puppetlabs/code/modules ]; then
    rm -rf /etc/puppetlabs/code/modules;
    mkdir -p /etc/puppetlabs/code;
    ln -s /etc/puppet/modules/ /etc/puppetlabs/code/modules
  fi;

  #fix hiera
  mkdir /etc/puppetlabs/puppet; cd /etc/puppetlabs/puppet && ln -s /etc/puppet/hiera.yaml ./
  ln -s /etc/puppet/hieradata /etc/puppetlabs/puppet

# Create necessary Puppet directories...
mkdir -p /etc/puppet /var/lib /var/log /var/run /etc/puppet/manifests /etc/puppet/modules /etc/puppet/hieradata

# create hiera config
cat <<EOF > /etc/puppet/hiera.yaml
---
version: 5
defaults:
  datadir: hieradata
  data_hash: yaml_data
hierarchy:
  - name: "Per-node data (yaml version)"
    path: "node--%{trusted.certname}.yaml" # Add file extension.
    # Omitting datadir and data_hash to use defaults.

EOF

# create custom facts for facter
$sudo mkdir -p /etc/facter/facts.d

#$sudo yum -y erase gcc-c++ readline-devel zlib-devel libxml2-devel libyaml-devel libxslt-devel libffi-devel openssl-devel augeas-devel

#!/bin/bash

# Install dependencies for RVM and Ruby...
apt-get install curl gnupg2 dirmngr libaugeas-dev git net-tools -y

# import signing key
if which gpg2 &>/dev/null; then
  gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
elif which gpg &>/dev/null; then
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
else
  "ERROR: add gpg failed";
fi

# Get and install RVM
curl -L https://get.rvm.io | bash -s stable

# Source rvm.sh so we have access to RVM in this shell
source /etc/profile.d/rvm.sh

# update rvm
rvm get stable && rvm cleanup all

source /etc/profile.d/rvm.sh

# Install Ruby
rvm install ruby-2.5.5
rvm alias create default ruby-2.5.5

source /etc/profile.d/rvm.sh

#mkdir -p /usr/local/share/gems && mkdir -p /usr/local/rvm/gems && ln -s /usr/local/share/gems /usr/local/rvm/gems/ruby-2.4.3

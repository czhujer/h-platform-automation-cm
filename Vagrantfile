# -*- mode: ruby -*-
# vi: set ft=ruby :

# based on: https://github.com/czhujer/vagrant-kubernetes-sandbox/blob/master/Vagrantfile
#
# cheat sheet https://gist.github.com/czhujer/428adb509eeabba7c8f6a0f2dea916c1
#

Vagrant.require_version ">= 2.0.0"

servers = {"vagrant" => {"hpa-hq1" => "vm", "hpa-pxm1" => "vm"}}

Vagrant.configure('2') do |config|
  #config.vm.box = 'centos/7'

  config.vm.provider :libvirt do |v|
    v.memory = 1024
    v.cpus = 2
  end

  servers['vagrant'].each do |name, server_config|
    config.vm.define name do |host|
      if name == "hpa-hq1"
          host.vm.box = "centos/7"
      elsif name == "hpa-pxm1"
          host.vm.box = "debian/stretch64"
      end

      if name == "hpa-pxm1"
        config.vm.provision :shell, :inline => "apt-get update && apt-get install -y sshfs", :privileged => true
      end

      config.vm.synced_folder '.', '/vagrant', type: 'sshfs'
      host.vm.hostname = name

    end
  end

  # run ruby and puppet bootstrap
  config.vm.provision :shell, :inline => "echo 'starting bootstrap ruby and puppet...'"
  servers['vagrant'].each do |name, server_config|
    config.vm.define name do |host|
      if name == "hpa-hq1"
        config.vm.provision :shell, path: 'bootstrap-scripts/bootstrap_ruby.sh', :privileged => true
        config.vm.provision :shell, path: 'bootstrap-scripts/bootstrap_puppet.sh', :privileged => true
      elsif name == "hpa-pxm1"
        config.vm.provision :shell, path: 'bootstrap-scripts/bootstrap_ruby_debian.sh', :privileged => true
        config.vm.provision :shell, path: 'bootstrap-scripts/bootstrap_puppet.sh', :privileged => true
      end
    end
  end

  #
  # run r10k and puppet apply
  #

  servers['vagrant'].each do |name, server_config|
    config.vm.define name do |host|
      if name == "hpa-hq1"

        # fix PKI
        host.vm.provision :shell, :inline => "echo 'generate pki certs for webserver..'"
        host.vm.provision :shell, path: 'scripts/pki-make-dummy-cert.sh', args: ["localhost"], :privileged => true

        host.vm.provision :shell, :inline => "echo 'starting r10k install .. and puppet apply...'"

        host.vm.provision :shell, :inline => "cd /vagrant && cp r10k-puppetfiles/Puppetfile-jenkins-server /etc/puppet/Puppetfile", :privileged => true
        host.vm.provision :shell, :inline => "source /opt/rh/rh-ruby25/enable; cd /etc/puppet && r10k puppetfile install --force --puppetfile /etc/puppet/Puppetfile", :privileged => true

        #host.vm.provision :shell, :inline => "source /opt/rh/rh-ruby25/enable; facter", :privileged => true

        host.vm.provision :shell, :inline => "cd /vagrant && cp configs-servers/hpa-hq1/*.pp /etc/puppet/manifests/", :privileged => true
        host.vm.provision :shell, :inline => "source /opt/rh/rh-ruby25/enable; puppet apply --color=false --detailed-exitcodes /etc/puppet/manifests; retval=$?; if [[ $retval -eq 2 ]]; then exit 0; else exit $retval; fi;", :privileged => true
      elsif name == "hpa-pxm1"
        # fix PKI
        host.vm.provision "pki", type: "shell", path: 'scripts/pki-make-dummy-cert-debian.sh', args: ["localhost"], :privileged => true

        # fix hostname for proxmox
        host.vm.provision "fix-hosts", type: "shell", :inline => "sudo sed -i \"/\\b\hpa-pxm1\\b/d\" /etc/hosts; sudo echo \"$(hostname -I | cut -d ' ' -f 1 |tr -d '\n')\t\t#{name}\" >> /etc/hosts"

        host.vm.provision "copy-r10k-files", type: "shell", :inline => "cd /vagrant && cp r10k-puppetfiles/Puppetfile-proxmox-master /etc/puppet/Puppetfile", :privileged => true

        host.vm.provision "run-r10k", type: "shell", :inline => "source /etc/profile.d/rvm.sh; cd /etc/puppet && r10k puppetfile install --force --puppetfile /etc/puppet/Puppetfile", :privileged => true

        #host.vm.provision :shell, :inline => "source /opt/rh/rh-ruby25/enable; facter", :privileged => true

        host.vm.provision "copy-puppet-files", type: "shell", :inline => "cd /vagrant && cp configs-servers/hpa-pxm1/*.pp /etc/puppet/manifests/", :privileged => true
        host.vm.provision "run-puppet", type: "shell", :inline => "source /etc/profile.d/rvm.sh; puppet apply --color=false --detailed-exitcodes /etc/puppet/manifests; retval=$?; if [[ $retval -eq 2 ]]; then exit 0; else exit $retval; fi;", :privileged => true

      end
    end
  end

end

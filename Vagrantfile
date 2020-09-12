# -*- mode: ruby -*-
# vi: set ft=ruby :

# based on: https://github.com/czhujer/vagrant-kubernetes-sandbox/blob/master/Vagrantfile
#
# cheat sheet https://gist.github.com/czhujer/428adb509eeabba7c8f6a0f2dea916c1
#

Vagrant.require_version ">= 2.0.0"

servers = {
    "vagrant" => {
            "hpa-hq1" => "vm",
            "hpa-pxm1" => "vm",
            "hpa-f-proxy1" => "vm"
    }
}

Vagrant.configure('2') do |config|

  servers['vagrant'].each do |name, server_config|
    dir = File.expand_path("..", __FILE__)
#    puts "DIR_cm: #{dir}"

    config.vm.define name do |host|
      host.vm.provider :libvirt do |v|
        v.memory = 1536
        v.cpus = 2
      end

      if name == "hpa-hq1"
          host.vm.box = "centos/8"
      elsif name == "hpa-pxm1"
          host.vm.box = "debian/stretch64"

          # Expose http/s port
          host.vm.network "forwarded_port", guest: 80, host: 8180, auto_correct: true
          host.vm.network "forwarded_port", guest: 443, host: 8143, auto_correct: true
          host.vm.network "forwarded_port", guest: 8006, host: 8106, auto_correct: true
      elsif name == "hpa-f-proxy1"
          host.vm.box = "generic/ubuntu2004"

          host.vm.provider :libvirt do |v|
            v.memory = 512
            v.cpus = 2
          end
      end

      if name == "hpa-pxm1" # or name == "hpa-f-proxy1"
        host.vm.provision :shell, :inline => "apt-get update && apt-get install -y sshfs", :privileged => true
      end

      host.vm.synced_folder dir, '/vagrant', type: 'sshfs'
      host.vm.hostname = name

    end
  end

  # bootstrap ruby&puppet or docker&docker
  servers['vagrant'].each do |name, server_config|
    dir = File.expand_path("..", __FILE__)
#    puts "DIR_cm: #{dir}"

    config.vm.define name do |host|
      if name == "hpa-hq1"
        host.vm.provision :shell, :inline => "echo 'starting bootstrap ruby and puppet...'"
        host.vm.provision :shell, path: File.join(dir,'bootstrap-scripts/bootstrap_ruby.sh'), :privileged => true
        host.vm.provision :shell, path: File.join(dir,'bootstrap-scripts/bootstrap_puppet.sh'), :privileged => true
      elsif name == "hpa-pxm1"
        host.vm.provision :shell, :inline => "echo 'starting bootstrap ruby and puppet...'"
        host.vm.provision :shell, path: File.join(dir,'bootstrap-scripts/bootstrap_ruby_debian.sh'), :privileged => true
        host.vm.provision :shell, path: File.join(dir,'bootstrap-scripts/bootstrap_puppet.sh'), :privileged => true
      elsif name == "hpa-f-proxy1"
        host.vm.provision "docker-install", type: "shell", path: File.join(dir,'bootstrap-scripts//bootstrap-docker.sh'), privileged: false
      end
    end
  end

$script_compose_status = <<SCRIPT3
echo "Showing status of traefik-stack compose..."
sleep 120
cd /etc/docker/compose/traefik-stack && docker-compose ps
SCRIPT3

  # copy and run docker-compose
  servers['vagrant'].each do |name, server_config|
    dir = File.expand_path("..", __FILE__)

    config.vm.define name do |host|
      if name == "hpa-f-proxy1"

        host.vm.provision "compose-files",
          type: "shell",
          :inline => "mkdir -p /etc/docker/compose/traefik-stack && cp /vagrant/configs-servers/hpa-f-proxy1/docker-files/traefik-stack.yaml /etc/docker/compose/traefik-stack/docker-compose.yaml",
          :privileged => true

        host.vm.provision "compose-exec",
          type: "shell",
          path: File.join(dir,'bootstrap-scripts/docker-compose-exec.sh'),
          :privileged => true

        host.vm.provision "status", type: "shell", inline: $script_compose_status, privileged: false

        # Expose http/s port
#        host.vm.network "forwarded_port", guest: 8080, host: 8081, auto_correct: true
#
#        host.vm.provider :libvirt do |v|
#          v.memory = 2048
#          v.cpus = 2
#        end

      end
    end
  end

  #
  # run r10k and puppet apply
  #

  servers['vagrant'].each do |name, server_config|
    dir = File.expand_path("..", __FILE__)
#    puts "DIR_cm: #{dir}"

    config.vm.define name do |host|
      if name == "hpa-hq1"
        # fix PKI
        host.vm.provision :shell, :inline => "echo 'generate pki certs for webserver..'"
        host.vm.provision :shell, path: File.join(dir,'scripts/pki-make-dummy-cert.sh'), args: ["localhost"], :privileged => true

        host.vm.provision :shell, :inline => "echo 'starting r10k install .. and puppet apply...'"

        host.vm.provision "copy-r10k-files", type: "shell", :inline => "cd /vagrant && cp configs-servers/hpa-hq1/Puppetfile /etc/puppet/Puppetfile", :privileged => true
        host.vm.provision "run-r10k", type: "shell", :inline => "cd /etc/puppet && r10k puppetfile install --force --puppetfile /etc/puppet/Puppetfile", :privileged => true

        host.vm.provision "copy-puppet-files", type: "shell", :inline => "cd /vagrant && cp configs-servers/hpa-hq1/*.pp /etc/puppet/manifests && mkdir -p /root/docker-compose && cp -r docker-compose /root", :privileged => true
        host.vm.provision "run-puppet", type: "shell", :inline => "puppet apply --color=false --detailed-exitcodes /etc/puppet/manifests; retval=$?; if [[ $retval -eq 2 ]]; then exit 0; else exit $retval; fi;", :privileged => true
      elsif name == "hpa-pxm1"
        # fix PKI
        host.vm.provision "pki", type: "shell", path: File.join(dir,'scripts/pki-make-dummy-cert-debian.sh'), args: ["localhost"], :privileged => true

        # fix hostname for proxmox
        host.vm.provision "fix-hosts", type: "shell", :inline => "sudo sed -i \"/\\b\hpa-pxm1\\b/d\" /etc/hosts; sudo echo \"$(hostname -I | cut -d ' ' -f 1 |tr -d '\n')\t\t#{name}\" >> /etc/hosts"

        host.vm.provision "copy-r10k-files", type: "shell", :inline => "cd /vagrant && cp r10k-puppetfiles/proxmox-master/Puppetfile /etc/puppet/Puppetfile", :privileged => true
        host.vm.provision "run-r10k", type: "shell", :inline => "source /etc/profile.d/rvm.sh; cd /etc/puppet && r10k puppetfile install --force --puppetfile /etc/puppet/Puppetfile", :privileged => true

        host.vm.provision "copy-puppet-files", type: "shell", :inline => "cd /vagrant && cp configs-servers/hpa-pxm1/*.pp /etc/puppet/manifests/", :privileged => true
        host.vm.provision "run-puppet", type: "shell", :inline => "source /etc/profile.d/rvm.sh; puppet apply --color=false --detailed-exitcodes /etc/puppet/manifests; retval=$?; if [[ $retval -eq 2 ]]; then exit 0; else exit $retval; fi;", :privileged => true

      end
    end
  end

end

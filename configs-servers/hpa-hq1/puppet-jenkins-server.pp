#
# jenkins server part
#

#class { 'jenkins':
#    configure_firewall => false,
#    install_java       => false,
#    lts                => false,
#    cli                => false,
#    cli_tries  => 2,
#    cli_ssh_keyfile => '/root/.ssh/id_rsa_jenkins_user',
#   config_hash => {
#    'HTTPS_PORT' => { 'value' => '8081' },
#  },
#  #cli_ssh_keyfile => '/root/.ssh/id_rsa_jenkins_user',
#    #service_provider    => dummy,
#}

#class {'jenkins::cli_helper':
#    ssh_keyfile => '/root/.ssh/id_rsa_jenkins_user',
#}

#class { 'jenkins::security':
#    security_model => 'full_control',
#}

#jenkins::job { 'update-git-repo-zabbix-agent-v1.0.0-1':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/update-git-repo-zabbix-agent.xml"),
#}

#jenkins::job {'fetch-git-repo-with-sugarcrm-stack-puppet-module-over-labels':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/fetch-git-repo-with-sugarcrm-stack-puppet-module-over-labels.xml"),
#}

#jenkins::job {'fetch-git-repo-with-sugarcrm-stack-puppet-module-v0.2':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/fetch-git-repo-with-sugarcrm-stack-puppet-module.xml"),
#}

#jenkins::job {'fetch-git-repo-cm-sf-infrastructure':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/fetch-git-repo-cm-sf-infrastructure.xml"),
#}

#jenkins::job {'fetch-git-repo-cm-sf-infrastructure-over-labels':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/fetch-git-repo-cm-sf-infrastructure-over-labels.xml"),
#}

#jenkins::job {'fetch-git-repo-cm-topagri':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/fetch-git-repo-cm-topagri.xml"),
#}

#jenkins::job {'fetch-git-repo-cm-heureka':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/fetch-git-repo-cm-heureka.xml"),
#}

#jenkins::job {'fetch-git-repo-cm-sf-sugarcrm-server':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/fetch-git-repo-cm-sf-sugarcrm-server.xml"),
#}

#jenkins::job {'create-sugacrm-stack-env-v0.5':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/create-sugacrm-stack-env.xml"),
#}

#jenkins::job {'prepare-env-for-git-fetching-v0.3':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-env-for-git-fetching.xml"),
#}

#jenkins::job {'prepare-env-for-sugarcrmstack':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-env-for-sugarcrmstack.xml"),
#}

#jenkins::job {'prepare-env-for-sugarstack':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-env-for-sugarstack.xml"),
#}

#jenkins::job {'centos-update-all-packages':
#  config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/centos-update-all-packages.xml"),
#}

#t jenkins::job {'centos-update-packages-for-sugarcrmstack':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/centos-update-packages-for-sugarcrmstack.xml"),
#t }

#t jenkins::job {'centos-update-specific-packages':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/centos-update-specific-packages.xml"),
#t }

#t jenkins::job {'prepare-sugarcrm-7.6.0.0-Pro':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-sugarcrm-7.6.0.0-Pro.xml"),
#t }

#t jenkins::job {'prepare-sugarcrm-7.6.1.0-Pro':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-sugarcrm-7.6.1.0-Pro.xml"),
#t }

#t jenkins::job {'prepare-sugarcrm-7.6.0.0-Pro-force':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-sugarcrm-7.6.0.0-Pro-force.xml"),
#t }

#t jenkins::job {'prepare-sugarcrm-7.6.0.0-Ent':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-sugarcrm-7.6.0.0-Ent.xml"),
#t }

#t jenkins::job {'prepare-sugarcrm-7.6.0.0-Ent-force':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-sugarcrm-7.6.0.0-Ent-force.xml"),
#t }

#t jenkins::job {'prepare-sugarcrm-DEVEL':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-sugarcrm-DEVEL.xml"),
#t }

#t jenkins::job {'prepare-suitecrm-7.4.3':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/prepare-suitecrm-7.4.3.xml"),
#t }

#t jenkins::job {'restore-sugarcrm-from-backup':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/restore-sugarcrm-from-backup.xml"),
#t }

#t jenkins::job {'run-puppet-manifests-on-sugar-servers':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-on-sugar-servers.xml"),
#t }

#t jenkins::job {'run-puppet-manifests-on-sugar-servers-over-labels':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-on-sugar-servers-over-labels.xml"),
#t }

#t jenkins::job { 'run-puppet-manifests-w-repo-update-and-w-prepare-env-for-infra-servers':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-w-repo-update-and-w-prepare-env-for-infra-servers.xml"),
#t }

#t jenkins::job { 'run-puppet-manifests-w-repo-update-and-w-prepare-env-for-sugar-servers':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-w-repo-update-and-w-prepare-env-for-sugar-servers.xml"),
#t }

#t jenkins::job { 'run-puppet-manifests-with-repo-update-for-infra-servers':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-with-repo-update-for-infra-servers.xml"),
#t }

#t jenkins::job { 'run-puppet-manifests-with-repo-update-for-infra-servers-old':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-with-repo-update-for-infra-servers-old.xml"),
#t }

#t jenkins::job { 'run-puppet-manifests-with-repo-update-for-sugar-servers-heureka':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-with-repo-update-for-sugar-servers-heureka.xml"),
#t }

#t jenkins::job { 'run-puppet-manifests-with-repo-update-for-sugar-servers-topagri':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-with-repo-update-for-sugar-servers-topagri.xml"),
#t }

#t jenkins::job { 'run-puppet-manifests-with-repo-update-for-sugar-servers-v1.2':
#t   config => template("/root/cm-sf-infrastructure/templates-jenkins-jobs/run-puppet-manifests-with-repo-update-for-sugar-servers.xml"),
#t }

create_resources(jenkins::credentials, hiera('jenkins_credentials', {}))


jenkins::plugin {'authorize-project':
}

jenkins::plugin {'build-token-root':
}

jenkins::plugin {'build-monitor-plugin':
}

jenkins::plugin { 'groovy-postbuild':
}

jenkins::plugin { 'text-finder':
}

jenkins::plugin { 'rvm':
}
jenkins::plugin { 'ruby-runtime':
}

jenkins::plugin { 'postbuild-task':
}

jenkins::plugin { 'seleniumhtmlreport':
}

#jenkins::plugin { 'dynamicparameter':
#}

jenkins::plugin { 'deployment-notification':
}

jenkins::plugin { 'envinject':
}

jenkins::plugin { 'token-macro':
}

jenkins::plugin { 'conditional-buildstep':
}

#jenkins::plugin { 'maven-plugim':
#}

jenkins::plugin { 'parameterized-trigger':
}

jenkins::plugin { 'jenkins-multijob-plugin':
}

jenkins::plugin { 'nodelabelparameter':
}

jenkins::plugin { 'puppet':
}

#jenkins::plugin { 'puppet-jenkinstracking':
#}

jenkins::plugin { 'git':
}

jenkins::plugin { 'github':
}

jenkins::plugin { 'github-oauth':
}

#jenkins::plugin { 'copy-to-slave':
#}

jenkins::plugin { 'ssh-slaves':
}

jenkins::plugin { 'ssh-credentials':
}

jenkins::plugin { 'swarm':
}

jenkins::plugin { 'slack':
}

jenkins::plugin { 'promoted-builds':
}

#jenkins::plugin { 'fingerprints':
#}

jenkins::plugin { 'copyartifact':
}

jenkins::plugin { 'log-parser':
}

file { '/var/lib/jenkins/userContent/parsing_rules':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '755',
}

$puppet_parse_c = 'error /^Error:/
ok /^Info:/
info /^Notice: Finished/
warning /^Warning:/
info /^Notice:/
'

file { '/var/lib/jenkins/userContent/parsing_rules/puppet.parse':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '644',
    content => $puppet_parse_c,
    require => File["/var/lib/jenkins/userContent/parsing_rules"],
}

package {'jq':
  ensure  => 'installed',
  #require => Package['epel-release'],
}

#
# DOCS
#
# https://forge.puppetlabs.com/rtyler/jenkins
# https://wiki.jenkins-ci.org/display/JENKINS/Puppet+Plugin

#!/bin/bash

#yum install perl perl-YAML-Tiny perl-CPAN -y -q
yum install perl perl-YAML-Tiny perl-App-cpanminus perl-Test-Simple -y -q

cpanm install Crypt::RandPasswd

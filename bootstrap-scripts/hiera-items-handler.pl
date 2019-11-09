#!/usr/bin/perl

#
# Docs
#
# https://github.com/ingydotnet/json-bash
# https://github.com/0k/shyaml
# http://search.cpan.org/~ingy/YAML-Perl-0.02/lib/YAML/Perl.pod
# https://docs.puppetlabs.com/hiera/1/complete_example.html
# https://docs.puppetlabs.com/hiera/1/configuring.html#example-config-file
# http://search.cpan.org/dist/YAML-Tiny/lib/YAML/Tiny.pm
# http://search.cpan.org/~neilb/Crypt-RandPasswd-0.06/lib/Crypt/RandPasswd.pm

use strict;

use YAML::Tiny;

use Crypt::RandPasswd;

use Digest::SHA1 qw(sha1 sha1_hex);

my $gen_pass_min_len = "8";
my $gen_pass_max_len = "8";

#load fqdn
my $facter_fqdn = $ARGV[0];

if ($facter_fqdn eq ""){
  $facter_fqdn = `source /opt/rh/rh-ruby25/enable; facter fqdn 2>/dev/null`;

  #trim whitespaces
  $facter_fqdn =~ s/^\s+|\s+$//g;
}

my $folder = $ARGV[1];
my $file;

if ($folder eq ""){
  $file = "/etc/puppet/hieradata/node--".$facter_fqdn.".yaml";
}
else{
  $file = $folder . "/node--".$facter_fqdn.".yaml";
}

#my $file = "/srv/crm-test6/hiera_data/node--".$facter_fqdn.".yaml";

if (-f $file) {
  print "File Exists..";
} else {
  print "File does not exist..";
  open my $fh, ">>", $file or die "can open file $!";
}

# Open the config
my $yaml = YAML::Tiny->read($file);

# Get a reference to the first document
my $config = $yaml->[0];

#
# read properties directly
#

#zabbixagent
my $timezone_timezone = $yaml->[0]->{'timezone::timezone'};
my $mysql_server_restart = $yaml->[0]->{'mysql::server::restart'};
my $mysql_server_root_password = $yaml->[0]->{'mysql::server::root_password'};

my $owncloud_db_user = $yaml->[0]->{'owncloud::db_user'};
my $owncloud_db_pass = $yaml->[0]->{'owncloud::db_pass'};

my $owncloud_ssl = $yaml->[0]->{'owncloud::ssl'};
my $owncloud_ssl_cert = $yaml->[0]->{'owncloud::ssl_cert'};
my $owncloud_ssl_key = $yaml->[0]->{'owncloud::ssl_key'};

my $owncloud_admin_user = $yaml->[0]->{'owncloud::admin_user'};
my $owncloud_admin_pass = $yaml->[0]->{'owncloud::admin_pass'};

my $prometheus_mysqld_exporter_cnf_password = $yaml->[0]->{'prometheus::mysqld_exporter::cnf_password'};
my $prometheus_mysqld_exporter_cnf_user = $yaml->[0]->{'prometheus::mysqld_exporter::cnf_user'};

sub replace_special_chars {
  my $string = $_[0];
  $string =~ tr/"/g1/;
  $string =~ tr/'/x2/;
  $string =~ tr/`/a3/;
  $string =~ tr/~/m4/;
  $string =~ tr/|/n5/;
  $string =~ tr/$/k6/;
  $string =~ tr/</u7/;
  $string =~ tr/>/w0/;
  $string =~ tr/?/u4/;
  $string =~ tr/!/P2/;
  $string =~ tr/\//h8/;
  $string =~ tr/\\/o2/;
  $string =~ tr/%/f1/;

  return $string;
}

#
# generate content
#
if ( $timezone_timezone eq ""){
    $yaml->[0]->{'timezone::timezone'} = 'Europe/Prague';
}

if ( $mysql_server_restart eq ""){
#    $yaml->[0]->{'mysql::server::restart'} = true;
}

if ( $mysql_server_root_password eq ""){
    print "generating password for element: \n\t \"mysql::server::root_password\"... \t";
    $mysql_server_root_password = Crypt::RandPasswd->chars($gen_pass_min_len, $gen_pass_max_len);
    $mysql_server_root_password = replace_special_chars($mysql_server_root_password);
    print $mysql_server_root_password . "\n";

    $yaml->[0]->{'mysql::server::root_password'} = $mysql_server_root_password;
}

if ( $owncloud_db_user eq ""){
    $yaml->[0]->{'owncloud::db_user'} = 'owncloud';
}

if ( $owncloud_db_pass eq ""){
    print "generating password for element: \n\t \"owncloud::db_pass\"... \t";
    $owncloud_db_pass = Crypt::RandPasswd->chars($gen_pass_min_len, $gen_pass_max_len);
    $owncloud_db_pass = replace_special_chars($owncloud_db_pass);
    print $owncloud_db_pass . "\n";

    $yaml->[0]->{'owncloud::db_pass'} = $owncloud_db_pass;
}

if ( $owncloud_ssl eq ""){
#    $yaml->[0]->{'owncloud::ssl'} = true;
}

if ( $owncloud_ssl_cert eq ""){
    $yaml->[0]->{'owncloud::ssl_cert'} = '/etc/pki/tls/certs/localhost.crt';
}

if ( $owncloud_ssl_key eq ""){
    $yaml->[0]->{'owncloud::ssl_key'} = '/etc/pki/tls/private/localhost.key';
}

if ( $owncloud_admin_user eq ""){
    $yaml->[0]->{'owncloud::admin_user'} = 'admin';
}

if ( $owncloud_admin_pass eq ""){
    print "generating password for element: \n\t \"owncloud::admin_pass\"... \t";
    $owncloud_admin_pass = Crypt::RandPasswd->chars($gen_pass_min_len, $gen_pass_max_len);
    $owncloud_admin_pass = replace_special_chars($owncloud_admin_pass);
    print $owncloud_admin_pass . "\n";

    $yaml->[0]->{'owncloud::admin_pass'} = $owncloud_admin_pass;
}

if ( $prometheus_mysqld_exporter_cnf_user eq ""){
    $yaml->[0]->{'prometheus::mysqld_exporter::cnf_user'} = "mysqld-exporter";
}

if ( $prometheus_mysqld_exporter_cnf_password eq ""){

    print "generating password for element: \n\t \"prometheus::mysqld_exporter::cnf_password\"... \t";
    $prometheus_mysqld_exporter_cnf_password = Crypt::RandPasswd->chars($gen_pass_min_len, $gen_pass_max_len);
    $prometheus_mysqld_exporter_cnf_password = replace_special_chars($prometheus_mysqld_exporter_cnf_password);
    print $prometheus_mysqld_exporter_cnf_password . "\n";

    $yaml->[0]->{'prometheus::mysqld_exporter::cnf_password'} = $prometheus_mysqld_exporter_cnf_password;
}

#writing changes
print "\nwriting changes into file: \"".$file . "\"...\n";
$yaml->write($file);
print "DONE\n";

exit 0;

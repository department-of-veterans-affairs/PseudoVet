#!/usr/bin/perl
# DIFR Custom Setup Utility
# 2015-09-16 BCIV

# branding
print "Dynamic Interface For Records (DIFR) Vagrant Setup\n";
print "Copyright 2015 BCIV through EtherFeat LLC\n";
print "2015-09-16 build 0.1.1\n";

# make sure user is root
my $login = (getpwuid $>);
die "This script must run as root or sudo" if $login ne 'root';

my $wwwroot='/var/www';
my $app_title='difr';
my $domain_name='localhost';
# create path under wwwroot and copy files there
my $app_name='app';
# create difr instance folder and copy clean instance  
#system("mkdir -p $wwwroot/difr/$app_name");
#if(-d "$wwwroot/difr/$app_name"){
#  my $cmd="cp -R /vagrant/difr/* $wwwroot/difr/$app_name/";
#  system($cmd);
#  print "Application difr instance created at: $wwwroot/difr/$app_name\n";
#}
my  $public="$wwwroot/html";
#system("mkdir -p $public");
#my $cmd="cp -R /vagrant/public/* $public/";
#print "$cmd\n";
#system($cmd);
my $dbadmin_username='root';
my $dbadmin_password='difr1!';
my $dbserver_hostname='localhost';
my $dbname='difr';
my $dbapp_username='difr';
my $dbapp_password='difr1!';
my $email_support='support\@localhost';
print "Creating database...\n";
my $cmd="mysql -u $dbadmin_username -p$dbadmin_password -h $dbserver_hostname -e \"create database $dbname\"";
print "$cmd\n";
system($cmd);

print "Populating $dbname database...\n";
$cmd="mysql -u $dbadmin_username -p$dbadmin_password -h $dbserver_hostname $dbname < /vagrant/difr/database/difr.sql";
print "$cmd\n";
system($cmd);

print "Giving $dbapp_username access...\n";
$cmd="mysql -u $dbadmin_username -p$dbadmin_password -h $dbserver_hostname -e \"use $dbname; grant all on $dbname.\* to $dbapp_username\@localhost identified by '$dbapp_password'\"";
print "$cmd\n";
system($cmd);

my $email_support_escaped=$email_support; $email_support_escaped=~s/\@/\\\@/;
# create configuration file based on information above
print "Creating app.config file based on settings supplied by this installer...\n";
open(my $fh, '>', "$wwwroot/$app_name/app.config") or die "Cannot create configuration, $wwwroot/$app_name/app.config : $!\n";
print $fh "\$g->{protocol}='https'; # https or http\n";
print $fh "\$g->{domainname}='$domain_name';\n";
print $fh "\$g->{sitename}='$app_title';\n";
print $fh "\$g->{site_slogan}='';\n";
print $fh "\$g->{site_logo}=\"http://$g->{domainname}/images/logo.gif\";\n";
print $fh "\$g->{email_support}=\"$email_support_escaped\";\n";
print $fh "\$g->{email_support_display}=\"$email_support\";\n";
print $fh "\$g->{email_sales}=\"sales\\\@$g->{domainname}\";\n";
print $fh "\$g->{appname}='$app_name';\n";
print $fh "\$g->{themes}='themes';\n";
print $fh "\$g->{default_theme}=\"bootstrap\";\n";
print $fh "\$g->{modpath}=\"../$app_name/modules\";\n";
print $fh "\$g->{tempfiles}=\"../$app_name/temp\";\n";
print $fh "\$g->{sqlconf}=\"../$app_name/app.conn\";\n";
print $fh "\$g->{modhome}='interface_preferences';\n";
print $fh "\$g->{scriptname}=\"app.pl\";\n";
print $fh "\$g->{countryfile}='lib/country-codes.txt';\n";
close($fh);

# create legacy conn file for mysql connection
print "Creating legacy app.conn file (soon to be deprecated)...\n";
open(my $fh, '>', "$wwwroot/$app_name/app.conn") or die "Cannot create conn file : $!\n";
print $fh "$dbname,$dbserver_hostname,$dbapp_username,$dbapp_password";
close($fh);

print "Installation complete!!\n\n";

print "Access your installation here: http://$domain_name/$subfolder\n\n";

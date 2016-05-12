#!/bin/bash -xi

# set username
myusername=vagrant 
LOG=~/vagrant-install.log

# configure selinux ###################
#
echo configuring ipv4 firewall
echo -----------------------
sudo service iptables stop
sudo cp /vagrant/provision/iptables /etc/sysconfig/
sudo service iptables start 

# install EPEL and REMI Repos ##################
#
echo installing epel-release and remi for CentOS/RHEL 6
echo --------------------------------------------------
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
# sed -i s'/enabled=1/enabled=0/' /etc/yum.repos.d/remi.repo
sudo cp /vagrant/provision/remi.repo /etc/yum.repos.d/
sudo yum -y install vim zip unzip wget dos2unix

# install VistA with Intersystems' Cache' database
#sudo chmod a+x provision/install-vista.sh
dos2unix /vagrant/provision/install-vista.sh 
sudo sh /vagrant/provision/install-vista.sh

# install PseudoVet Proof Of Concept prerequisites
dos2unix /vagrant/provision/install-pseudovet.sh
sudo sh /vagrant/provision/install-pseudovet.sh

## EWD.js and Federator installation ############################

## install Nodejs and Development Tools such as gcc & make
#sudo yum -y groupinstall 'Development Tools'
#sudo yum -y install nodejs npm
#
#sudo mkdir /var/log/ewd 
#sudo touch /var/log/ewd/federatorCPM.log
#sudo touch /var/log/ewd/ewdjs.log
#sudo chown -R $myusername:$myusername /var/log/ewd
#
#cd /vagrant/EWDJS
#sudo cp -R ewdjs /opt/
#sudo chown -R $myusername:$myusername /opt/ewdjs
#cd /opt/ewdjs 
#npm install ewdjs 
#npm install ewd-federator
##sudo npm install -g inherits@2.0.0
##sudo npm install -g node-inspector
#
## get database interface from cache version we are running
#sudo cp /srv/bin/cache0100.node /opt/ewdjs/node_modules/cache.node
#
## start EWD and EWD Federator
#cd /opt/ewdjs
#
## add ewdfederator access to EWD
#node registerEWDFederator.js
#
## start EWD and Federator 
#sudo dos2unix startEverything.sh 
#sudo chmod a+x startEverything.sh 
#sudo ./startEverything.sh 


# demo configuration fix user in file
# username='vagrant'
# set user in parameters file to match $myusername
# sed -i -e "s/security_settings.manager_user: vagrant/security_settings.manager_user: $myusername/" $cacheInstallerPath/parameters.isc

## Install Apache, PHP, and other tidbits ##############
##
#echo installing apache, php, and other tidbits
#sudo yum -y install parted vim zip unzip wget drush httpd php php-gd php-mcrypt php-curl
#sudo chkconfig httpd on
#
## Install Perl modules
#sudo yum -y install "perl(Expect)"
#
## install Nodejs and Development Tools such as gcc & make
#sudo yum -y groupinstall 'Development Tools'
#sudo yum -y install nodejs npm
## sudo npm -g install bower
#
## copy php.ini from provision folder to prepare for Drupal 7
## 'expose_php' and 'allow_url_fopen' will be set to 'Off'
#sudo cp /vagrant/provision/php.ini /etc/
#
## Change 'AllowOverride None' to 'All' in httpd.conf 
#sudo cp /vagrant/provision/httpd.conf /etc/httpd/conf/
#sudo service httpd start
#
## Install MySQL ######################
##
#echo install mysql
#echo -------------
#cd
#wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
#sudo rpm -Uvh mysql-community-release-el6-5.noarch.rpm
#sudo yum -y install dos2unix mysql mysql-server php-mysql php-soap php-mbstring php-dom php-xml rsync
#sudo rpm -qa | grep mysql
#sudo chkconfig mysqld on
#sudo service mysqld start
#export DATABASE_PASS='raptor1!'
#mysqladmin -u root password "$DATABASE_PASS"
#mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
#mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
#mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
#mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
#
## set up database for Drupal 7
#mysql -u root -p"$DATABASE_PASS" -h localhost -e "create database raptor500;"
## add standard tables from a clean installation of Drupal 7
#mysql -u root -p"$DATABASE_PASS" -h localhost raptor500 < /vagrant/provision/drupal.sql
## add RAPTOR database user and assign access
#mysql -u root -p"$DATABASE_PASS" -h localhost -e "create user raptoruser@localhost identified by '$DATABASE_PASS';"
#mysql -u root -p"$DATABASE_PASS" -h localhost -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON raptor500.* TO raptoruser@localhost;"
#mysql -u root -p"$DATABASE_PASS" -h localhost -e "FLUSH PRIVILEGES;"

## I'm sure ownership is borked from all the sudo commands...
#sudo chown -R apache:apache /var/www
#
## restart apache so all php modules are loaded...
#sudo service httpd restart

echo CSP is here: http://192.168.33.11:57772/csp/sys/UtilHome.csp
echo username: cache password: innovate 
echo See Readme.md from root level of this repository... 
echo EWD Monitor: http://192.168.33.11:8082/ewd/ewdMonitor/ password: innovate 
echo EWD: http://192.168.33.11:8082/ewdjs/EWD.js ewdBootstrap3.js 
echo EWD Federator: http://192.168.33.11:8081/EwdVista/pseudovet/
echo password: innovate 
echo PseudoVet is now installed
echo Browse to: http://192.168.33.11/
echo to kill EWD and Federator sudo sh /opt/ewdjs/killEverything.sh 
echo vista access/verify innovat3/innovat3.

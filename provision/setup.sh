#!/bin/bash -xi

# set username
myusername=$USER
# set up base box through vagrant file with these commands
cacheInstallerPath=/vagrant/provision/cache 
cacheInstaller=cache-2014.1.3.775.14809-lnxrhx64.tar.gz
parametersIsc=parameters.isc 
cacheDatabase=/VISTA.zip
cacheInstallTargetPath=/srv 
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

# Install Apache, PHP, and other tidbits ##############
#
echo installing apache, php, and other tidbits
sudo yum -y install parted vim zip unzip wget drush httpd php php-gd php-mcrypt php-curl
sudo chkconfig httpd on

# install Nodejs and Development Tools such as gcc & make
sudo yum -y groupinstall 'Development Tools'
sudo yum -y install nodejs npm
# sudo npm -g install bower

# copy php.ini from provision folder to prepare for Drupal 7
# 'expose_php' and 'allow_url_fopen' will be set to 'Off'
sudo cp /vagrant/provision/php.ini /etc/

# Change 'AllowOverride None' to 'All' in httpd.conf 
sudo cp /vagrant/provision/httpd.conf /etc/httpd/conf/
sudo service httpd start

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

# I'm sure ownership is borked from all the sudo commands...
sudo chown -R apache:apache /var/www

# restart apache so all php modules are loaded...
sudo service httpd restart

# VistA Installation 
sudo groupadd cacheserver

# get cache installer
if [ -e "$cacheInstallerPath/$cacheInstaller" ]
then
  echo "Already have installer for Cache'..."
else
  echo "downloading Cache' installer..."
  wget --progress=bar:force -P $cacheInstallerPath/ http://vaftl.us/vagrant/cache-2014.1.3.775.14809-lnxrhx64.tar.gz
fi

if [ -e "$cacheInstallerPath/$cacheInstaller" ]
then
  echo "Installing Cache from: $cacheInstaller"
  # install from tar.gz 
  sudo mkdir -p $cacheInstallTargetPath/tmp
  cd $cacheInstallTargetPath/tmp
  sudo cp $cacheInstallerPath/$cacheInstaller .
  sudo tar -xzvf $cacheInstaller
  # set user in parameters file to match $myusername
  sed -i -e 's/vagrant/$myusername/' $cacheInstallerPath/parameters.isc
  # install from parameters file
  sudo $cacheInstallTargetPath/tmp/package/installFromParametersFile $cacheInstallerPath/parameters.isc
else
  echo "You are missing: $cacheInstaller"
  echo "You cannot provision this system until you have downloaded Intersystems Cache"
  echo "in 64-bit tar.gz format and placed it under the provision/cache folder."
  exit 
fi

# add vista and vagrant to cacheusr group
sudo usermod -a -G cacheusr $myusername

## add disk to store CACHE.DAT was sdb 
#parted /dev/sdb mklabel msdos
#parted /dev/sdb mkpart primary 0 100%
#mkfs.xfs /dev/sdb1
#mkdir /srv
#echo `blkid /dev/sdb1 | awk '{print$2}' | sed -e 's/"//g'` /srv   xfs   noatime,nobarrier   0   0 >> /etc/fstab
#mount /srv

# check for cache.dat and put it where it goes
if [ -e "$cacheInstallerPath/CACHE.DAT" ]
then
  echo "CACHE.DAT is in local repo copying it to $cacheInstallTargetPath/mgr/VISTA/ ..."
  sudo cp $cacheInstallerPath/CACHE.DAT $cacheInstallTargetPath/mgr/VISTA/
else
  sudo mkdir -p $cacheInstallTargetPath/mgr/VISTA 
  sudo chown -R $myusername:cacheusr $cacheInstallTargetPath/mgr/VISTA
  sudo mkdir -p $cacheInstallTargetPath/mgr/VISTA
  echo "Copying CACHE.DAT to /srv/mgr/"
  wget --progress=bar:force -P $cacheInstallTargetPath/mgr/VISTA/ http://vaftl.us/vagrant/CACHE.DAT 
  echo "This will take a while... Get some coffee or a cup of tea..."
  sudo cp $cacheInstallTargetPath/mgr/VISTA/CACHE.DAT $cacheInstallerPath/
fi

sudo chown -R $myusername:cacheusr /srv
sudo chmod g+wx /srv/bin
sudo ccontrol stop cache quietly

echo "Setting permissions on database."
sudo chmod 775 /srv/mgr/VISTA 
sudo chmod 660 /srv/mgr/VISTA/CACHE.DAT
sudo chown -R $myusername:cacheusr /srv/mgr/VISTA 

# copy cache configuration
echo "Copying cache.cpf"
sudo cp $cacheInstallerPath/cache.cpf $cacheInstallTargetPath/

# start cache 
sudo ccontrol start cache

# enable cache' os authentication and %Service_CallIn required by EWD.js 
csession CACHE -U%SYS <<EOE
$myusername
innovate
s rc=##class(Security.System).Get("SYSTEM",.SP),d=SP("AutheEnabled") f i=1:1:4 s d=d\2 i i=4 s r=+d#2
i 'r s NP("AutheEnabled")=SP("AutheEnabled")+16,rc=##class(Security.System).Modify("SYSTEM",.NP)

n p
s p("Enabled")=1
D ##class(Security.Services).Modify("%Service_CallIn",.p)

h
EOE

# install VEFB_1_2 ~RAPTOR Specific KIDS into VistA
# todo: this doesn't work because it doesn't see device(0) ~something with c-vt320? vt320 doesn't 
# work either...
cp /vagrant/OtherComponents/VistAConfig/VEFB_1_2.KID /srv/mgr/
csession CACHE -UVISTA "^ZU" <<EOI
c-vt320
^^load a distribution
/srv/mgr/VEFB_1_2.KID
yes
^^install package
VEFB 1.2
no
no

^
^
h
EOI

# EWD.js and Federator installation ############################
sudo mkdir /var/log/ewd 
sudo touch /var/log/ewd/federatorCPM.log
sudo touch /var/log/ewd/ewdjs.log
sudo chown -R $myusername:$myusername /var/log/ewd

cd /vagrant/EWDJS
sudo cp -R ewdjs /opt/
sudo chown -R $myusername:$myusername /opt/ewdjs
cd /opt/ewdjs 
npm install ewdjs 
npm install ewd-federator
#sudo npm install -g inherits@2.0.0
#sudo npm install -g node-inspector

# get database interface from cache version we are running
sudo cp /srv/bin/cache0100.node /opt/ewdjs/node_modules/cache.node

# start EWD and EWD Federator
cd /opt/ewdjs

# add ewdfederator access to EWD
node registerEWDFederator.js

# start EWD and Federator 
sudo dos2unix startEverything.sh 
sudo chmod a+x startEverything.sh 
sudo ./startEverything.sh 

# user notifications 
echo VistA is now installed.  

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

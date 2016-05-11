#!/bin/bash -xi

# set username
myusername=vagrant 
LOG=~/pseudovet-install.log
#$USER
# set up base box through vagrant file with these commands
cacheInstallerPath=/vagrant/provision/cache 
cacheInstaller=cache-2014.1.3.775.14809-lnxrhx64.tar.gz
parametersIsc=parameters.isc 
cacheDatabase=VISTA.zip
cacheInstallTargetPath=/srv 

# install prerequisites
sudo yum -y install wget dos2unix

# VistA Installation 
sudo groupadd cacheserver

# add user to cacheusr group
sudo usermod -a -G cacheusr $myusername
sudo usermod -a -G cacheserver $myusername

# get cache installer
if [ -e "$cacheInstallerPath/$cacheInstaller" ]; then
  echo "Already have installer for Cache'..."
else
  echo "downloading Cache' installer..."
  wget --progress=bar:force -P $cacheInstallerPath/ http://vaftl.us/vagrant/cache-2014.1.3.775.14809-lnxrhx64.tar.gz
fi

if [ -e "$cacheInstallerPath/$cacheInstaller" ]; then
  echo "Installing Cache from: $cacheInstaller" >> $LOG
else
  echo "You are missing: $cacheInstaller" >> $LOG
  echo "You cannot provision this system until you have downloaded Intersystems Cache"
  echo "in 64-bit tar.gz format and placed it under the provision/cache folder."
  exit 
fi   
  
# install from tar.gz 
sudo mkdir -p $cacheInstallTargetPath/tmp
cd $cacheInstallTargetPath/tmp
sudo cp $cacheInstallerPath/$cacheInstaller .
sudo tar -xzvf $cacheInstaller

# set user in parameters file to match $myusername
if [ "$myusername" == "vagrant" ]; then 
  echo "no username change for cache installation..." >> $LOG
else 
  sed -i -e "s/ vagrant/ $myusername/" $cacheInstallerPath/parameters.isc
fi 

# install from parameters file
sudo cp $cacheInstallerPath/parameters.isc ~/
sudo $cacheInstallTargetPath/tmp/package/installFromParametersFile ~/parameters.isc

echo "enable Cache OS authentication and %Service_CallIn required by EWD.js" 
csession CACHE -U%SYS <<EOE
vagrant
innovate
s rc=##class(Security.System).Get("SYSTEM",.SP),d=SP("AutheEnabled") f i=1:1:4 s d=d\2 i i=4 s r=+d#2
i 'r s NP("AutheEnabled")=SP("AutheEnabled")+16,rc=##class(Security.System).Modify("SYSTEM",.NP)

n p
s p("Enabled")=1
D ##class(Security.Services).Modify("%Service_CallIn",.p)

h
EOE

ccontrol list
echo "Stopping Cache' before adding VistA database..."
sudo ccontrol stop cache quietly
ccontrol list

# check for cache.dat and put it where it goes
sudo mkdir -p $cacheInstallTargetPath/mgr/VISTA 
sudo chown -R $myusername:cacheusr $cacheInstallTargetPath/mgr/VISTA

echo "Adding VistA database..."
#echo "check if we already have CACHE.DAT in $cacheInstallerPath and copy if not..." 
if [ -e "$cacheInstallerPath/CACHE.DAT" ]; then
  sudo cp $cacheInstallerPath/CACHE.DAT $cacheInstallTargetPath/mgr/VISTA/CACHE.DAT
else
  wget --progress=bar:force -P $cacheInstallTargetPath/mgr/VISTA/ http://vaftl.us/vagrant/CACHE.DAT 
fi

echo "Setting permissions on VISTA database."
sudo chmod 775 /srv/mgr/VISTA 
sudo chmod 660 /srv/mgr/VISTA/CACHE.DAT
sudo chown -R $myusername:cacheusr /srv/mgr/VISTA 

# copy cache configuration
echo "Copying cache.cpf"
sudo cp $cacheInstallerPath/cache.cpf $cacheInstallTargetPath/

# start cache 
sudo ccontrol start cache
ccontrol list

# troubleshoot HOME DEVICE (00) DOES NOT EXIST IN THE DEVICE FILE
# csession CACHE -UVISTA <<EOI

# install VEFB_1_2 ~EWD Specific KIDS into VistA
# todo: this doesn't work because it doesn't see device(0) ~something with c-vt320? vt320 doesn't 
# work either...
#cp /vagrant/provision/VistAConfig/VEFB_1_2.KID /srv/mgr/
#csession CACHE -UVISTA "^ZU" <<EOI
#innovat3
#innovat3.
#^^load a distribution
#/srv/mgr/VEFB_1_2.KID
#yes
#^^install package
#VEFB 1.2
#no
#no
#
#^
#^
#h
#EOI

echo "Create a vista SSH user with Innovat3! password..." 
# create encrypted password 
pass=$(perl -e 'print crypt("Innovat3!", "salt")' )
sudo useradd -m -p $pass vista 
echo "Add vista user to cacheusr group..."
sudo usermod -a -G cacheusr vista
# set vista user to log be prompted for access/verify upon login
sudo cp /vagrant/provision/cache/.bashrc /home/vista/.bashrc 
sudo chmod u+x /home/vista/.bashrc 
sudo chown vista:vista /home/vista/.bashrc
csession CACHE -U%SYS <<EOI 
D ^SECURITY
1
1
vista
vista user
 
vista
vista
Yes
No
No
2040-01-01
%All

VISTA
^ZU

Yes

8
14
h 
EOI

# user notifications 
echo VistA is now installed. 

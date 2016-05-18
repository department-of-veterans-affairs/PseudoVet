#!/bin/bash -xi

cacheInstallerPath=/vagrant/provision/cache 
cacheInstallTargetPath=/srv

ccontrol list
echo "Stopping Cache' before resetting VistA database..."
sudo ccontrol stop cache quietly
ccontrol list

# check for cache.dat and put it where it goes
sudo mkdir -p $cacheInstallTargetPath/mgr/VISTA 
sudo chown -R $myusername:cacheusr $cacheInstallTargetPath/mgr/VISTA

echo "deleting old CACHE.DAT..."
sudo rm $cacheInstallTargetPath/mgr/VISTA/CACHE.DAT 

echo "copying fresh VistA database..."
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

# start cache 
sudo ccontrol start cache
ccontrol list

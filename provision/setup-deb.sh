#!/bin/bash -xi
# set up base box through vagrant file with these commands

echo in setup-deb.sh for debian based os...
sudo apt-get update
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password difr1!'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password difr1!'
sudo apt-get -y install mysql-server
sudo apt-get install -y libapache2-mod-perl2 libcgi-pm-perl vim zip unzip wget curl expect
sudo service apache2 stop
cp /vagrant/provision/default-ssl /etc/apache2/sites-available/
# sudo mkdir /var/www/html
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/difr /var/www
fi
# cp /vagrant/provision/test.pl /var/www/html/
# sudo chmod a+x /var/www/html/test.pl
sudo a2enmod ssl
sudo a2ensite default-ssl
sudo service apache2 start
curl -Gk https://localhost/test.pl
cd /vagrant/
perl provision/install-difr.pl
echo open your browser to http://localhost:8081/app.pl

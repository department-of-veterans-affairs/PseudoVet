#!/bin/bash -xi

# set username
myusername=vagrant 
LOG=~/pseudovet-install.log

## install Nodejs and Development Tools such as gcc & make
sudo yum -y groupinstall 'Development Tools'
sudo yum -y install nodejs npm

# Install Perl modules
sudo yum -y install "perl(Expect)"

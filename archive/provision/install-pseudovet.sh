#!/bin/bash -xi

# set username
myusername=vagrant 
LOG=~/pseudovet-install.log

## install Nodejs and Development Tools such as gcc & make
sudo yum -y groupinstall 'Development Tools'
sudo yum -y install nodejs npm

# Install Perl modules
sudo yum -y install "perl(Expect)"

# Install Ruby, Ruby Gems, expect...
sudo yum -y install gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel
sudo yum -y install ruby-rdoc ruby-devel

sudo yum -y install rubygems ruby-json

sudo gem update

sudo gem update --system

sudo gem install expect
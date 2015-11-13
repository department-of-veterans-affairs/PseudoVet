#!/bin/bash -xi
# set up base box through vagrant file with these commands

echo in setup.sh 
echo installing epel-release
sudo yum install epel-release
echo finished with epel-release
echo installing zip unzip wget...
sudo yum install zip unzip wget
echo finished with installing zip unzip wget
# echo disabling selinux...

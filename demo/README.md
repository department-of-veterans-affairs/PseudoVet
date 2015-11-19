# PseudoVet Proof Of Concept
![PseudoVet Logo](https://github.com/VHAINNOVATIONS/PseudoVet/blob/master/branding/PseudoVet.png)

# Prerequisites to run the appointment-schedule.pl automation script:

# VistA Instance
There must be a VistA server that you have access to.  This script was written to 
work against eHMP's SILVER Image of VistA as of 20151118

## Linux OS Level Requirements of VistA Server
The Intersystems Cache' 'csession' command must be accessible for use by 
the user account that is logged into to access VistA as a terminal application
so that it is not necessary to use the sudo command to use csession.

This is accomplished by added the user to the cacheserver group

```
sudo usermod -a -G cacheserver <username>
```

Typically, this will not work:
```
sudo chgrp users /usr/local/etc/cachesys/csession
```

## .bashrc auto prompt for access/verify code
The account that the script SSH's into must additionally be configured to 
automatically prompt for the access/verify pair.

This is accomplished by adding to the user accounts hidden .bashrc file.  
Here is an example on how that is accomplished:

notes about 'csession' command:
- 'cache' is the name of the cache instance used in the example
- 'vista' is the name of the namespace we are accessing.  
- '^ZU' is the command that prompts for access/verify codes.

*You can run ccontrol list to see the names of cache instances.

```
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]
then
  . /etc/bashrc
fi

# User specific aliases and functions
if ( tty -s )
then
  csession cache -U vista "^ZU"
  exit
fi
```
## VistA Menu/Key Requirements
Additionally, the access and verify code used to log into VistA must have 
options and keys assigned necessary to use the APPOINTMENT MENU's, MAKE 
APPOINTMENT OPTION

## Configuration file
See the sample.demo.config file under the ../config folder
- copy the sample.demo.config file to demo.config (new file)
- edit the variables in the file to match your environment

# To run from Mac OS X
To run from Mac OS X, you must install the Perl Expect module

To setup and schedule an appointment against the demo.config settings:
```
sudo perl -MCPAN -e "shell"
install expect
cd demo
perl appointment-schedule.pl
```
*Once expect is installed you only need to run the last line:
```
perl appointment-schedule.pl
```

# To run from Vagrant under Windows
Follow instructions in the README.md from https://github.com/VHAINNOVATIONS/PseudoVet
or from the cloned or forked PseudoVet repository

From 'vagrant ssh' run the following command:
```
cd /vagrant/demo
perl appointment-schedule.pl
```

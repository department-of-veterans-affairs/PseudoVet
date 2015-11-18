# Prerequisites to run the appointment-schedule.pl automation script:

# VistA Instance
There must be a VistA server that you have access to.  This script was written to 
work against eHMP's SILVER Image of VistA as of 20151118

# Linux OS Level Requirements
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

# .bashrc auto prompt for access/verify code
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
# VistA Requirements
Additionally, the access and verify code used to log into VistA must have 
options and keys assigned necessary to use the APPOINTMENT MENU's, MAKE 
APPOINTMENT OPTION

--
Will BC Collins IV, VHA Innovation Laboratory
william.collins@va.gov
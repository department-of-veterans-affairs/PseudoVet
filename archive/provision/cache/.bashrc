# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]
then
  . /etc/bashrc
fi

# User specific aliases and functions
if ( tty -s )
then
  csession cache
  exit
fi

# change to: csession cacheinv -UVISTA "^ZU"
# if OS auth is not working

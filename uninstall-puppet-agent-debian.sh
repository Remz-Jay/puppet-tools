#!/bin/bash
/etc/init.d/puppet stop
apt-get remove -y --auto-remove puppet
# dpkg --get-selections | grep deinstall | sed 's/deinstall/\lpurge/' | dpkg --set-selections; dpkg -Pa
aptitude --purge-unused purge puppet


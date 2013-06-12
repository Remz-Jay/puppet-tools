#!/bin.bash
if command -v wget > /dev/null 2>&1; then
	echo wget is already installed;
else
	apt-get install wget;
fi
wget http://apt.puppetlabs.com/puppetlabs-release-`lsb_release -sc`.deb
dpkg -i puppetlabs-release-`lsb_release -sc`.deb
apt-get update
apt-get install puppet
if grep -q "84\.53\.103\.71" /etc/hosts; then 
	echo puppet master is already in hosts file; 
else 
	echo "84.53.103.71    puppet.maxserv.com puppet" >> /etc/hosts;
	echo puppet master added to hosts file; 
fi
puppet agent --test
sed -i 's/START=no/START=yes/g' /etc/default/puppet
/etc/init.d/puppet start

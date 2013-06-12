#!/bin/bash
if pgrep puppet > /dev/null 2>&1; then 
	echo puppet is already running, not good, bye.; 
	exit 1;
else 
	echo puppet is not running, good.;
	if dpkg -l puppet >/dev/null 2>&1; then 
		echo puppet is already installed, not good, bye.; 
		exit 1; 
	else 
		echo puppet is not yet installed, good.; 
	fi
fi
if command -v wget > /dev/null 2>&1; then
	echo wget is already installed;
else
	echo installing prerequisite wget;
	apt-get install wget;
fi
if command -v lsb_release > /dev/null 2>&1; then
	echo "installing for:";
	lsb_release -a
else
	apt-get install lsb-release -y
fi
wget http://apt.puppetlabs.com/puppetlabs-release-`lsb_release -sc`.deb
dpkg -i puppetlabs-release-`lsb_release -sc`.deb
apt-get update
apt-get install puppet -y
if grep -q "84\.53\.103\.71" /etc/hosts; then 
	echo puppet master is already in hosts file; 
else 
	echo "84.53.103.71    puppet.maxserv.com puppet" >> /etc/hosts;
	echo puppet master added to hosts file; 
fi
puppet agent --waitforcert 60 --test
sed -i 's/START=no/START=yes/g' /etc/default/puppet
/etc/init.d/puppet start

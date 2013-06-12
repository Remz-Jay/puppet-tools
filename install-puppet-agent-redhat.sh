#!/bin/bash
if pgrep puppet > /dev/null 2>&1; then 
	echo puppet is already running, not good, bye.; 
	exit 1;
else 
	echo puppet is not running, good.;
	if rpm -qa | grep puppet > /dev/null 2>&1; then 
		echo puppet is already installed, not good, bye.; 
		exit 1; 
	else 
		echo puppet is not yet installed, good.; 
	fi
fi

if [ ! -f /etc/system-release-cpe ]; then
	echo "Cannot determine OS release/version, not good.";
	exit 1;
else
	echo "Installing for: `cat /etc/system-release-cpe`";
fi

rpm -ivh http://yum.puppetlabs.com/el/`cat /etc/system-release-cpe | cut -d: -f5`/products/i386/puppetlabs-release-`cat /etc/system-release-cpe | cut -d: -f5`-7.noarch.rpm
yum clean all
yum install puppet -y
if grep -q "84\.53\.103\.71" /etc/hosts; then 
	echo puppet master is already in hosts file; 
else 
	echo "84.53.103.71    puppet.maxserv.com puppet" >> /etc/hosts;
	echo puppet master added to hosts file; 
fi
puppet agent --waitforcert 60 --test
/etc/init.d/puppet start

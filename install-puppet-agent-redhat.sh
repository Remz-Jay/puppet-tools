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
MINOR=7
if [ ! -f /etc/system-release-cpe ]; then
	if command -v lsb_release > /dev/null 2>&1; then
			echo "installing for:";
			lsb_release -a;
			VERSION=`lsb_release -sr | cut -d. -f1`;
			MINOR=`lsb_release -sr | cut -d. -f1`;
	else
			echo "Cannot determine OS release/version, not good.";
			exit 1;
	fi
else
	echo "Installing for: `cat /etc/system-release-cpe`";
	VERSION=`cat /etc/system-release-cpe | cut -d: -f5`
fi

rpm -ivh http://yum.puppetlabs.com/el/${VERSION}/products/i386/puppetlabs-release-${VERSION}-${MINOR}.noarch.rpm
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

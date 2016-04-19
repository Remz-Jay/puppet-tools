#!/bin/bash

# PUPPET INSTALL/RUN DETECTION
if pgrep puppet > /dev/null 2>&1; then 
	echo puppet is already running, not good, bye.; 
	exit 1;
else 
	echo puppet is not running, good.;
	if rpm -qa | grep "puppet-" > /dev/null 2>&1; then 
		echo puppet is already installed, not good, bye.; 
		exit 1; 
	else 
		echo puppet is not yet installed, good.; 
	fi
fi

# VERSION DETECTION
MINOR=11
if command -v lsb_release > /dev/null 2>&1; then
			echo "installing for:";
			lsb_release -a;
			VERSION=`lsb_release -sr | cut -d. -f1`;
			MINOR=`lsb_release -sr | cut -d. -f2`;
else
		if [ ! -f /etc/system-release-cpe ]; then
			echo "Cannot determine OS release/version, not good.";
			exit 1;
		else
			echo "Installing for: `cat /etc/system-release-cpe`";
			VERSION=`cat /etc/system-release-cpe | cut -d: -f5`
		fi
fi

# CLOUD-INIT HOSTNAME PRESERVATION
if [ -f /etc/cloud/cloud.cfg ]; then
        echo "Cloud-init found."
        echo "Removing existing preserve_hostname setting."
        sed -i '/preserve_hostname/d' /etc/cloud/cloud.cfg
        echo "Inserting new preserve_hostname setting."
        sed -i "6a\
preserve_hostname: true" /etc/cloud/cloud.cfg
else
        echo "No cloud-init found. Done."
fi

# HOSTNAME 
echo "Current hostname is set to `hostnamectl status --static`."
read -n 1 -p "Do you want to change it before running puppet? [Y/n]: " "changehostname"
echo ""
if [ "$changehostname" == "y" ] || [ "$changehostname" == "Y" ]; then
	read -p "What is the new hostname?: " "newhost"
  echo ""
  hostnamectl set-hostname $newhost
  echo "Changed hostname to $newhost. Done!"
else
	echo "Not changing hostname. Done."
fi

# INSTALL PUPPET
rpm -ivh http://yum.puppetlabs.com/el/${VERSION}/products/`uname -i`/puppetlabs-release-${VERSION}-${MINOR}.noarch.rpm
yum clean all
yum install puppet -y

# CONFIGURE PUPPET MASTER HINTS
if grep -q "84\.53\.103\.71" /etc/hosts; then
	echo removing reference to old puppet master;
	sed -i '/84.53.103.71/d' /etc/hosts
fi
if grep -q "149\.210\.174\.225" /etc/hosts; then
	echo puppet master is already in hosts file;
else
	echo "149.210.174.225    puppet.maxserv.com puppet" >> /etc/hosts;
	echo puppet master added to hosts file;
fi

# BOOTSTRAP AGENT
puppet agent --waitforcert 60 --test
if [ -f /etc/init.d/puppet ]; then
	/etc/init.d/puppet start
else
	/bin/systemctl start puppet
fi

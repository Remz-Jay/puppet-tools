#!/bin/bash
if ruby -v | grep "1.8" > /dev/null 2>&1; then 
	echo Ruby is 1.8, upgrading.; 
	yum install -y centos-release-scl;
	yum install -y ruby193;
	yum install -y ruby193-ruby-devel;
	echo "-----> Enabling ruby193";
	source /opt/rh/ruby193/enable;
	echo "/opt/rh/ruby193/root/usr/lib64" | tee -a /etc/ld.so.conf;
	ldconfig;
	ln -sf /opt/rh/ruby193/root/usr/bin/ruby /usr/bin/ruby;
	ln -sf /opt/rh/ruby193/root/usr/bin/gem /usr/bin/gem;
	if ruby -v | grep "1.9" > /dev/null 2>&1; then
		echo Now running Ruby 1.9, good. Upgrading Puppet gems.;
		gem install facter
		gem install json_pure -v 1.8.3
		gem install puppet -v 3.8.7
		yum install -y facter
		yum install -y puppet
		gem uninstall puppet -v 4.8.1
		puppet -V
	else
		echo Still not running Ruby 1.9. Something went wrong. HALP!;
		exit 1;
	fi
else 
	echo Ruby is not 1.8. Dont know what to do. Exit.;
	exit 1;
fi

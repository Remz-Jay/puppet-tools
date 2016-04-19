#!/bin/bash
env ASSUME_ALWAYS_YES=YES pkg bootstrap

# PUPPET INSTALL/RUN DETECTION
if pgrep ruby21 > /dev/null 2>&1; then
        echo puppet is already running, not good, bye.;
        exit 1;
else
        echo puppet is not running, good.;
        if pkg info -Ix puppet38 > /dev/null 2>&1; then
                echo puppet is already installed, not good, bye.;
                exit 1;
        else
                echo puppet is not yet installed, good.;
        fi
fi

# INSTALL PUPPET
pkg install -y puppet38

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

# ENABLE PUPPET AS A SERVICE
if grep -q 'puppet_enable="YES"' /etc/rc.conf; then
        echo "Puppet Agent is already enabled in rc.conf. Skipping.";
else
        echo 'puppet_enable="YES"' >> /etc/rc.conf;
        echo "Puppet Agent Service added to rc.conf, starting now."
        service puppet start;
fi

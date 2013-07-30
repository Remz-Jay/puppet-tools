#!/sbin/env bash

CONFPATH="/etc/sysconfig/network-scripts"

MYNUM=$(ifconfig MGT | grep -o -E 'addr\:(10\.){3}[[:xdigit:]]{1,3}' | cut -d. -f4)
MAC0=$(ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
MAC1=$(ifconfig eth1 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')

echo $MYNUM
echo $MAC0
echo $MAC1
#exit

mkdir /sbin2
mount /dev/shm -t tmpfs /sbin2
cp -R /sbin/* /sbin2/
mv /sbin /sbin3
/sbin2/ln -s /sbin2 /sbin

echo -e "alias bond0 bonding
options bond0 miimon=100 mode=1">>/etc/modprobe.d/bonding.conf

echo -e "DEVICE=bond0
TYPE=BOND
BONDING_OPTS=\"miimon=100 mode=1\"
BOOTPROTO=static
IPADDR=10.10.10.${MYNUM}
NETMASK=255.255.255.0">$CONFPATH/ifcfg-bond0

echo -e "DEVICE=eth0
HWADDR=${MAC0}
MASTER=bond0
SLAVE=yes">>$CONFPATH/ifcfg-eth0

echo -e "DEVICE=eth1
HWADDR=${MAC1}
MASTER=bond0
SLAVE=yes">>$CONFPATH/ifcfg-eth1

#echo -e "VLAN=yes
#VLAN_NAME_TYPE=VLAN_PLUS_VID_NO_PAD
#DEVICE=vlan3
#PHYSDEV=bond0
#BOOTPROTO=static
#ONBOOT=yes
#TYPE=Ethernet
#IPADDR=10.10.10.${MYNUM}
#NETMASK=255.255.255.0">>$CONFPATH/ifcfg-vlan3

echo -e "VLAN=yes
VLAN_NAME_TYPE=VLAN_PLUS_VID_NO_PAD
DEVICE=vlan4
PHYSDEV=bond0
BOOTPROTO=static
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.20.20.${MYNUM}
NETMASK=255.255.255.0">>$CONFPATH/ifcfg-vlan4

echo -e "VLAN=yes
VLAN_NAME_TYPE=VLAN_PLUS_VID_NO_PAD
DEVICE=vlan5
PHYSDEV=bond0
BOOTPROTO=static
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.30.30.${MYNUM}
NETMASK=255.255.255.0">>$CONFPATH/ifcfg-vlan5

ifconfig MGT down
rm $CONFPATH/ifcfg-MGT
service network restart

rm /sbin
/sbin2/mv /sbin3 /sbin
umount /sbin2

#ifdown MGT
#ifdown eth0
#ifdown eth1
#ifup eth0
#ifup eth1
#ifup bond0
#ifup vlan3
#ifup vlan4
#ifup vlan5

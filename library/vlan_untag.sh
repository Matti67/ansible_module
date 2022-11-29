#!/bin/bash
#script_path1=
read -p "enter an IP address:" ip
echo "your IP is: $ip"
read -p "enter the vlan ID to get untagged ports:" vlan
echo "the entered vlan: $vlan"
#ip=$1
export vlan
path="/home/max/ansible/module/procurve"
rm -f $path/untag*;
rm -f $path/vlans;
script_path1="/home/max/ansible/module/library/hex_bin.py";
rm -f $path/int;
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.2\
| sed -n -e 's/^.*STRING: //p' &>> "$path"/int;
#
export list_int=$(cat  /home/max/ansible/module/procurve/int |tr "\n" " ");
echo $list_int
#the followings mib's object identifier it is used 
#for retrieve the list of ports untagged per vlan
#use instead the oid: .1.3.6.1.2.1.17.7.1.4.3.1.2 if you need 
#to retrieve the list of ports tagged per vlan
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.17.7.1.4.3.1.4 | tr -d "\n" &>> "$path"/untag;
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.17.7.1.4.3.1.4\
| sed -n -e 's/^.*\.\([0-9]\{1,4\}\)\( = Hex-STRING: \)\(.*$\)/\1/p' &>> "$path"/vlans;
cat procurve/untag | sed -n -e\
"s/SNMPv2-SMI::mib-2.17.7.1.4.3.1.4.[0-9]\{1,4\} = Hex-STRING:/;/g"p &>>procurve/untag2
cat procurve/untag2 | sed -n -e 's/^.//p' &>>procurve/untag3
python3.6 $script_path1;
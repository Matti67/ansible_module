#!/bin/bash
ip=$1
path="/home/max/ansible/module/procurve"
rm -f $path/int
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.2\
 | sed -n -e 's/^.*STRING: //p' &>> "$path"/int; 
#
export list_int=$(cat  /home/max/ansible/module/procurve/int |tr "\n" " ");
echo $list_int
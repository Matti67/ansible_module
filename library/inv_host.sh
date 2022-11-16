#!/bin/bash
#script name: /home/massimiliano/serial-hp3c.sh
path="/home/max/ansible/module"
notav="n/a"
file=/home/massimiliano/ip_hp3c
file1=$(cat  /home/massimiliano//ip_hp3c |tr "\n" " ")
#path="/home/massimiliano/Hp3C_Int/assets"
read -p 'Net: ' almanet
read -p 'firstip: ' firstip
read -p 'lastip: ' lastip
echo the almanet net is: $almanet and range is: $almanet.$firstip-$lastip
#echo Thankyou $uservar we now have your login details
fileItem=($file1)
#Lenght=${#fileItem[@]}
range=$(($lastip-$firstip))
echo "$range"
Lenght=$(($firstip+$range))
echo "$Lenght"
quote="\""
#COUNT=0
#oid=7
i=0
#while read -r ip; do
for (( i = $firstip; i < $Lenght; ++ i ));
do
# $COUNT = 0 
# $J<=$oid
#   $COUNT = 0 
#    K=$(expr 22 + $J);
#
#    echo "$K";
 #ping -c 1 ${fileItem[$i]} &> /dev/null
 ping -c 1 $almanet.$i &> /dev/null
 if [ "$?" = 0 ]
 then
	 hostname=$(snmpget -v 2c -c pubrim $almanet.$i sysName.0 | sed -n -e 's/^.*STRING: //p')	 
#echo "${fileItem[$i]} , $(snmpget -v 2c -c pubrim ${fileItem[$i]} .1.3.6.1.4.1.25506.2.6.1.2.1.1.2.2 | sed -n -e 's/^.*STRING: //p')" &>> "$path"/ser1;
#echo "$(snmpget -v 2c -c pubrim ${fileItem[$i]} .1.3.6.1.4.1.25506.2.6.1.2.1.1.2.2 | sed -n -e 's/^.*STRING: //p')" &>> "$path"/ser1;
#var=$(echo $hostname: $almanet.$i | sed -e 's/: /&"/g')
#var1=$(echo $var | sed -e 's/$/"/g')
#echo $var1 &>> "$path"/inventory_ue4.yml;
echo $hostname: &>> "$path"/inventory.yml;
echo $hostname: &>> "$path"/host_vars/$hostname.yml;
#echo ansible_host: $almanet.$i | sed -e 's/ \(1.*$\)/ "\1"/g' &>> "$path"/inventory_ue4.yml;
echo ansible_host: $almanet.$i | sed -e 's/\(^\)\(.*\) \(1.*$\)/  \1\2 "\3"/g' &>> "$path"/inventory.yml;
#    J=$(expr $J + 1);
#    COUNT=$(expr $COUNT + 1);
 else
#notav="n/a"	 
echo "$notav",$almanet.$i &>> "$path"/ser1;
 fi  
done


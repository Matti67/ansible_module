#!/bin/bash
COUNT=0
oid=7
MOD=0
val=0
initial="zero"
ip=$1
#file2=$(cat  /home/max/ansible/procurve/int_up |tr "\n" " ")
path="/home/max/ansible/procurve"
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.2\
 | sed -n -e 's/^.*STRING: //p' &>> "$path"/int; 
file1=$(cat  /home/max/ansible/procurve/int |tr "\n" " ")
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.8\
 | sed -n -e 's/^.*INTEGER: //p' &>> "$path"/int_up; 
file2=$(cat  /home/max/ansible/procurve/int_up |tr "\n" " ")
snmpbulkwalk -v 2c -c pubrim $ip 1.0.8802.1.1.2.1.4.1.1.9\
| sed -n -e 's/^.*\.\(.*\)\.\(.* =.*\).*\(SW\|SWT\|sw\|swt\).*$/\1/p' &>> "$path"/rem_id;
file3=$(cat  /home/max/ansible/procurve/rem_id |tr "\n" " ")
lldpItem=($file3)
Lengthid=${#lldpItem[@]}
file5=$path/rem_id;
while read -r line; do
  intid=$(echo "$line");
  oid=".1.3.6.1.2.1.2.2.1.2."$intid
  snmpget -v 2c -c pubrim $ip $oid\
  | sed -n -e 's/^.*STRING: //p' &>> "$path"/rem_int;
done < "$file5"
'''for (( j = 0; j < Lengthid; ++ j ));
do
  oid=".1.3.6.1.2.1.2.2.1.2.${lldpItem[$j]:0:1}"
  snmpget -v 2c -c pubrim $ip $oid | sed -n -e 's/^.*STRING: //p' &>> "$PATH"/lldp_int
done'''
file4=$(cat  /home/max/ansible/procurve/rem_int |tr "\n" " ")
remItem=($file4)
for del in ${file4[@]}
do
   file1=("${file1[@]/$del}") #Quotes when working with strings
done
Lengthrem=${#remItem[@]}
fileItem=($file1)
intupItem=($file2)
Length=${#fileItem[@]}
echo "$Length";
rm -f $path/rem*;
rm -f $path/int*;
rm -f $path/lldp_i*;
rm -f $path/Eth_int;
rm -f $path/camp*;
#
for (( i = 0; i < Length; ++ i ));
do
#  echo ${files[$i-1]} ${files[$i]} ${files[$i+1]}
#file=/home/max/int
#while read -r line; do
#first statment check if first line character is a number
  if [[ ${fileItem[$i]:0:1} =~ [0-9]  ]]; then
    #second if condition set initial to first line character (if initial==zero)
    if [[ $initial == zero ]]; then
      initial=$fileItem;
      last=${fileItem[$i]};
    else
    if [[ ${fileItem[$i]:0:1} =~ [0-9] && ${fileItem[$i+1]:0:1} =~ [0-9] ]]; then
      last=${fileItem[$i+1]};
    else
      echo "$initial-$last" &>>$path/camp$COUNT;
      COUNT=$(expr $COUNT + 1);
      initial=${fileItem[$i+1]};
      echo "$COUNT" &> $path/Eth_int;
      #
    #elif [[ ${fileItem[$i+1]:0:1} =~ [0-9] && ${fileItem[$i+1]:0:1} =~ [a-zA-Z] ]]; then
        #statements
      #statements
    #now is time to build camp var with elements
 # else
      #  echo "$initial-$last" &>> camp$COUNT;
      #  COUNT=$(expr $COUNT + 1);
      #  initial=${fileItem[$i+1]};
    fi
  fi
# fi
# fi
  elif [[ ${fileItem[$i]:0:1} =~ [a-zA-Z] && ${fileItem[$i]:1:1} =~ [0-9] ]]; then
    if [[ $initial == zero ]]; then
      initial=$fileItem;
      MOD=$(expr $MOD + 1);
    else
     if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:1:1} =~ [0-9] ]]; then
        last=${fileItem[$i+1]};
        MOD=$(expr $MOD + 1);
     else
        if [ $MOD -lt 5  ]; then
          MODItem=($MOD)
          Length2=${#MODItem[@]}
          for ((j = $MOD; j>=0; j-- )); do
            K=$(expr $i - $j);
            if [[ ${intupItem[$K]} == 'up(1)' ]]; then
              lastup=${fileItem[$K]};
              echo "$lastup" &>> $path/camp$COUNT;
              COUNT=$(expr $COUNT + 1);
              echo "$COUNT" &> $path/Eth_int;
            fi
          done
          MOD=0;
          initial=${fileItem[$i+1]};
        else
      #statements
    #now is time to build camp var with elements
          echo "$initial-$last" &>>$path/camp$COUNT;
          COUNT=$(expr $COUNT + 1);
          initial=${fileItem[$i+1]};
          echo "$COUNT" &> $path/Eth_int;
          #MOD=0;
        fi
        MOD=0;  
      #next condition try to verify if next line character is a number if so set last var
     fi
     #MOD=0;
    fi
  elif [[ ${fileItem[$i]:0:1} =~ [tT] && ${fileItem[$i]:1:1} =~ [rR] ]]; then
    if [[ $initial == zero ]]; then
      initial=$fileItem;
    else
      #statements
    #now is time to build camp var with elements
      echo "$initial" &>>$path/camp$COUNT;
      COUNT=$(expr $COUNT + 1);
      initial=${fileItem[$i+1]};
      echo "$COUNT" &> $path/Eth_int;
      #next condition try to verify if next line character is a number if so set last var
     fi
  fi
done

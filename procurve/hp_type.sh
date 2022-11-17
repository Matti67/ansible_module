#!/bin/bash
COUNT=0
oid=7
MOD=0
initial="zero"
ip=$1
val=0
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
file5=$path/rem_id;
lldpItem=($file3)
echo $lldpItem
Lengthid=${#lldpItem[@]}
'''for (( j = 0; j < Lengthid; ++ j ));
do
  idint="${lldpItem[$j]:0:1}"
  oid=".1.3.6.1.2.1.2.2.1.2."$idint
  snmpget -v 2c -c pubrim $ip $oid\
  | sed -n -e 's/^.*STRING: //p' &>> "$path"/rem_int;
done'''
while read -r line; do
  intid=$(echo "$line");
  oid=".1.3.6.1.2.1.2.2.1.2."$intid
  snmpget -v 2c -c pubrim $ip $oid\
  | sed -n -e 's/^.*STRING: //p' &>> "$path"/rem_int;
done < "$file5"
file4=$(cat  /home/max/ansible/procurve/rem_int |tr "\n" " ")
remItem=($file4)
Lengthrem=${#remItem[@]}
fileItem=($file1)
intupItem=($file2)
Length=${#fileItem[@]}
echo "$Length";
#rm -f $path/rem*;
rm -f $path/int*;
rm -f $path/lldp_i*;
rm -f $path/Eth_int;
rm -f $path/camp*;
for (( i = 0; i < Length; ++ i ));
do
#  echo ${files[$i-1]} ${files[$i]} ${files[$i+1]}
#file=/home/max/int
#while read -r line; do
#first statment check if first line character is a number
 if [[ ${fileItem[$i]:0:1} =~ [0-9] ]]; then
   #second if condition set initial to first line character (if initial==zero)
   if [[ $initial == zero ]]; then
     #initial=$fileItem;
     #last=${fileItem[$i]};
     if printf '%s\0' "${remItem[@]}" | grep -Fxq -- ${fileItem[$i]:0:1}; then
       #:
       val=$(expr $val + 1);
     else 
       #last=${fileItem[$i]};
       initial=${fileItem[$i]};
       #val=$(expr $val + 1);
     fi
   # ...
   else
    if [[ ${fileItem[$i]:0:1} =~ [0-9] && ${fileItem[$i+1]:0:1} =~ [0-9] ]]; then
      if printf '%s\0' "${remItem[@]}" | grep -Fxq -- ${fileItem[$i+1]}; then
        if [[ $val == 0 ]]; then
          last=${fileItem[$i]};
          val=$(expr $val + 1);
        else
          val=$(expr $val + 1);
        fi
      else
        if [[ $val == 0 ]]; then
          last=${fileItem[$i+1]};
          #val=$(expr $val + 1);
        else
          echo "$initial-$last" &>>$path/camp$COUNT;
          initial=${fileItem[$i+1]};
          val=0;
        fi
        #COUNT=$(expr $COUNT + 1);
        #last=${fileItem[$i+1]};
      fi
    else
      echo "$initial-$last" &>>$path/camp$COUNT;
      COUNT=$(expr $COUNT + 1);
      initial=${fileItem[$i+1]};
      echo "$COUNT" &> $path/Eth_int;
      val=0
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
  elif [[ ${fileItem[$i]:0:1} =~ [a-zA-Z] && ${fileItem[$i]:1:1} =~ [0-9] ]]; then
    if [[ $initial == zero ]]; then
      if printf '%s\0' "${remItem[@]}" | grep -Fxq -- ${fileItem[$i]}; then
        #:
        val=$(expr $val + 1);
      else
        if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} ]]; then
          last=${fileItem[$i]};
          initial=${fileItem[$i]};
        else
          echo "${fileItem[$i]}" &>>$path/camp$COUNT;
          COUNT=$(expr $COUNT + 1);
          initial=${fileItem[$i+1]};
          last=${fileItem[$i+1]};
          echo "$COUNT" &> $path/Eth_int;
          val=0
        #initial=$fileItem;
        #MOD=$(expr $MOD + 1);
        fi
      fi
    else
      if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:1:1} =~ [0-9] ]]; then
        last=${fileItem[$i+1]};
        if printf '%s\0' "${remItem[@]}" | grep -Fxq -- ${fileItem[$i+1]}; then
          if [[ $val == 0 ]]; then
            last=${fileItem[$i]};
            val=$(expr $val + 1);
          else
            val=$(expr $val + 1);
          fi
        else
          if [[ $val == 0 ]]; then
            last=${fileItem[$i+1]};
            #val=$(expr $val + 1);
          else
            echo "$initial-$last" &>>$path/camp$COUNT;
            COUNT=$(expr $COUNT + 1);
            initial=${fileItem[$i+1]};
            #last=${fileItem[$i+1]};
            val=0;
          fi
        fi
      #fi
      #next condition try to verify if next line character is a number if so set last var
      else
        if [[ $initial == 0 ]]; then
          echo "${fileItem[$i]}" &>>$path/camp$COUNT;
          COUNT=$(expr $COUNT + 1);
          initial=${fileItem[$i+1]};
          echo "$COUNT" &> $path/Eth_int;
        else
          last=${fileItem[$i]};
          echo "$initial-$last" &>>$path/camp$COUNT;
          COUNT=$(expr $COUNT + 1);
          initial=${fileItem[$i+1]};
          echo "$COUNT" &> $path/Eth_int;
        fi
      fi
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

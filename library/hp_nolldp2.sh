#!/bin/bash
COUNT=0
oid=7
MOD=0
val=0
initial="zero"
ip=$1
export ip
sp=" "
trat="-"
echo $ip;
#file2=$(cat  /home/max/ansible/procurve/int_up |tr "\n" " ")
path="/home/max/ansible/module/procurve"
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.2\
 | sed -n -e 's/^.*STRING: //p' &>> "$path"/int; 
file1=$(cat  /home/max/ansible/module/procurve/int |tr "\n" " ")
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.8\
 | sed -n -e 's/^.*INTEGER: //p' &>> "$path"/int_up; 
file2=$(cat  /home/max/ansible/module/procurve/int_up |tr "\n" " ")
snmpbulkwalk -v 2c -c pubrim $ip 1.0.8802.1.1.2.1.4.1.1.9\
| sed -n -e 's/^.*\.\(.*\)\.\(.* =.*\).*\(SW\|SWT\|sw\|swt\).*$/\1/p' &>> "$path"/rem_id;
file3=$(cat  /home/max/ansible/module/procurve/rem_id |tr "\n" " ")
hostname=$(snmpget -v 2c -c pubrim $ip sysName.0 | sed -n -e 's/^.*STRING: //p')
lldpItem=($file3)
Lengthid=${#lldpItem[@]}
file5=$path/rem_id;
while IFS= read -r line; do
  intid=$(echo "$line");
  oid=".1.3.6.1.2.1.2.2.1.2."$intid
  snmpget -v 2c -c pubrim $ip $oid\
  | sed -n -e 's/^.*STRING: //p' &>> "$path"/rem_int;
done < "$file5"
#'''for (( j = 0; j < Lengthid; ++ j ));
#do
#  oid=".1.3.6.1.2.1.2.2.1.2.${lldpItem[$j]:0:1}"
#  snmpget -v 2c -c pubrim $ip $oid\
#   | sed -n -e 's/^.*STRING: //p' &>> "$PATH"/rem_int;
#done'''
file4=$(cat  /home/max/ansible/module/procurve/rem_int |tr "\n" " ")
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
echo $file1
rm -f $path/rem*;
rm -f $path/int*;
rm -f $path/lldp_i*;
rm -f $path/Eth_int;
rm -f $path/camp*;
rm -f $path/add_camp*;
#
verpath=/home/max/ansible/module/host_vars/$hostname.yml;
if [[ -e "$verpath" ]];then
	msg="the file in host_vars folder must not be present yet. Exiting"
	exit 0
else
  #
  touch $verpath;
  echo "---" &>>$verpath;
  echo "loop_protect:" &>>$verpath;
fi
#
for (( i = 0; i < Length; ++ i ));
do
#  echo ${files[$i-1]} ${files[$i]} ${files[$i+1]}
#file=/home/max/int
#while read -r line; do
#first statment check if first line character is a number
  #if ! (( $(grep -c '\/' ${fileItem[$i]:1:1}) == 0 )); then
  #if ! [[ ${fileItem[$i]:1:1} =~ '/' ]]; then
  if [[ ${fileItem[$i]:0:1} =~ [a-zA-Z] && ${fileItem[$i]:1:1} =~ [0-9] ]]; then
    if [[ $initial == zero ]]; then
      if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} ]]; then
        initial=$fileItem;
        last=${fileItem[$i+1]};
        MOD=$(expr $MOD + 1);
      else
        echo "$fileItem" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
        echo "$fileItem" &>>$path/camp$COUNT;
        COUNT=$(expr $COUNT + 1);
        initial=${fileItem[$i+1]};
        last=${fileItem[$i+1]};
        echo "$COUNT" &> $path/Eth_int;
        MOD=0;  
      fi
    else
     if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:1:1} =~ [0-9] ]]; then
        last=${fileItem[$i+1]};
        MOD=$(expr $MOD + 1);
     else
        #'''if [ $MOD -lt 5  ]; then
        #  MODItem=($MOD)
        #  Length2=${#MODItem[@]}
        #  for ((j = $MOD; j>=0; j-- )); do
        #    K=$(expr $i - $j);
        #    if [[ ${intupItem[$K]} == 'up(1)' ]]; then
        #      lastup=${fileItem[$K]};
        #      echo "- $lastup" | sed -e 's/\(^\)\(.*\)/  \1\2/g' &>> $verpath;
        #      COUNT=$(expr $COUNT + 1);
        #      echo "$COUNT" &> $path/Eth_int;
        #    fi
        #  done
        #  MOD=0;
        #  initial=${fileItem[$i+1]};
        #else
      #s#tatements
    #now# is time to build camp var with elements
        #  echo "- $initial-$last" &sed -e 's/\(^\)\(.*\)/  \1\2/g' >>$verpath;
        #  COUNT=$(expr $COUNT + 1);
        #  initial=${fileItem[$i+1]};
        #  echo "$COUNT" &> $path/Eth_int;
        #  #MOD=0;
        #fi'''
        echo "$initial-$last" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
        echo "$initial-$last" &>>$path/camp$COUNT;
        COUNT=$(expr $COUNT + 1);
        initial=${fileItem[$i+1]};
        echo "$COUNT" &> $path/Eth_int;
        MOD=0;  
      #next condition try to verify if next line character is a number if so set last var
     fi
     #MOD=0;
    fi
  #fi
  elif [[ ${fileItem[$i]:0:1} =~ [1-9] && ${fileItem[$i]:1:1} =~ '/' &&  ${fileItem[$i]:2:1} =~ [1-9] ]]; then
    if [[ $initial == zero ]]; then
      if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} ]]; then
        initial=$fileItem;
        last=${fileItem[$i+1]};
        MOD=$(expr $MOD + 1);
      else
        echo "$fileItem" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
        echo "$fileItem" &>>$path/camp$COUNT;
        COUNT=$(expr $COUNT + 1);
        initial=${fileItem[$i+1]};
        last=${fileItem[$i+1]};
        echo "$COUNT" &> $path/Eth_int;
        MOD=0;  
      fi
    else
     if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:2:1} =~ [0-9] ]]; then
        last=${fileItem[$i+1]};
        MOD=$(expr $MOD + 1);
     else
        echo "$initial-$last" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
        echo "$initial-$last" &>>$path/camp$COUNT;
          COUNT=$(expr $COUNT + 1);
          initial=${fileItem[$i+1]};
          echo "$COUNT" &> $path/Eth_int;
        MOD=0;  
      #next condition try to verify if next line character is a number if so set last var
     fi
     #MOD=0;
    fi
  #fi
  elif [[ ${fileItem[$i]:0:1} =~ [1-9] && ${fileItem[$i]:1:1} =~ '/' &&  ${fileItem[$i]:2:1} =~ [a-zA-Z] ]]; then
    if [[ $initial == zero ]]; then
      if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} ]]; then
        initial=$fileItem;
        last=${fileItem[$i+1]};
        MOD=$(expr $MOD + 1);
      else
        echo "$fileItem" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
        echo "$fileItem" &>>$path/camp$COUNT;
        COUNT=$(expr $COUNT + 1);
        initial=${fileItem[$i+1]};
        last=${fileItem[$i+1]};
        echo "$COUNT" &> $path/Eth_int;
        MOD=0;  
      fi
    else
     if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:2:1} =~ [a-zA-Z] ]]; then
        last=${fileItem[$i+1]};
        MOD=$(expr $MOD + 1);
     else
        echo "$initial-$last" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
        echo "$initial-$last" &>>$path/camp$COUNT;
          COUNT=$(expr $COUNT + 1);
          initial=${fileItem[$i+1]};
          echo "$COUNT" &> $path/Eth_int;
        MOD=0;  
      #next condition try to verify if next line character is a number if so set last var
     fi
     #MOD=0;
    fi
  #fi
  elif [[ ${fileItem[$i]:0:1} =~ [0-9]  ]]; then
    #second if condition set initial to first line character (if initial==zero)
    if [[ $initial == zero ]]; then
      initial=$fileItem;
      last=${fileItem[$i]};
    else
    if [[ ${fileItem[$i]:0:1} =~ [0-9] && ${fileItem[$i+1]:0:1} =~ [0-9] ]]; then
      last=${fileItem[$i+1]};
    else
      echo "$initial-$last" | sed -e 's/\(^\)\(.*$\)/  - \1\2/g' &>>$verpath;
      echo "$initial-$last" &>>$path/camp$COUNT;
      COUNT=$(expr $COUNT + 1);
      initial=${fileItem[$i+1]};
      echo "$COUNT" &> $path/Eth_int;
      #
    #elif [[ ${fileItem[$i+1]:0:1} =~ [0-9] && ${fileItem[$i+1]:0:1} =~ [a-zA-Z] ]]; then
        #statements
      #statements
    #now is time to build camp var with elements
#   else
      #  echo "$initial-$last" &>> camp$COUNT;
      #  COUNT=$(expr $COUNT + 1);
      #  initial=${fileItem[$i+1]};
    fi
  fi
  elif [[ ${fileItem[$i]:0:1} =~ [tT] && ${fileItem[$i]:1:1} =~ [rR] ]]; then
    if [[ $initial == zero ]]; then
      initial=$fileItem;
    else
      #statements
    #now is time to build camp var with elements
      echo "$initial" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
      echo "$initial" &>>$path/camp$COUNT;
      COUNT=$(expr $COUNT + 1);
      initial=${fileItem[$i+1]};
      echo "$COUNT" &> $path/Eth_int;
      #next condition try to verify if next line character is a number if so set last var
     fi
  fi
done
file5=$(cat  /home/max/ansible/module/procurve/Eth_int |tr "\n" " ")
Lengtz1=($file5)
echo $Lengtz1;
#fileItem=($file)
#Length=${#fileItem[@]}
#path="/home/max"
virg=","
#camp=camp
for (( i = 0; i < Lengtz1; ++ i ));
do
  camp=$(cat  /home/max/ansible/module/procurve/camp$i)
  COUNT=$(expr $i + 1)
  if [[ $COUNT < $Lengtz1  ]]; then
    #camp += ',';
    echo $camp$virg &>>$path/add_camp;
  else
    echo $camp &>>$path/add_camp;
  fi
done
awk '
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' $path/add_camp &>> $path/add_camp2
tr -d ' ' < $path/add_camp2 > $path/add_camp3
#
#source $script_path2;
ports=$(cat /home/max/ansible/module/procurve/add_camp3)
echo $ports;
echo "ports:" &>>$verpath;
echo "$ports" | sed -e 's/\(^\)\(.*\)/  host_ports: \1\2/g' &>>$verpath;
#echo $ports;
#cat /home/max/ansible/module/templates/temp_aruba &>>$verpath;
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
path="/home/massimiliano/ansible_module/procurve"
rm -f $path/rem*;
rm -f $path/int*;
rm -f $path/lldp_i*;
rm -f $path/Eth_int;
rm -f $path/camp*;
rm -f $path/add_camp*;
rm -f $path/count*;
rm -f $path/ports*;
#file2=$(cat  /home/massimiliano/ansible/procurve/int_up |tr "\n" " ")
#path="/home/massimiliano/ansible_module/procurve"
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.2\
 | sed -n -e 's/^.*STRING: //p' &>> "$path"/int; 
file1=$(cat  /home/massimiliano/ansible_module/procurve/int |tr "\n" " ")
snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.8\
 | sed -n -e 's/^.*INTEGER: //p' &>> "$path"/int_up; 
file2=$(cat  /home/massimiliano/ansible_module/procurve/int_up |tr "\n" " ")
snmpbulkwalk -v 2c -c pubrim $ip 1.0.8802.1.1.2.1.4.1.1.9\
| sed -n -e 's/^.*\.\(.*\)\.\(.* =.*\).*\(SW\|SWT\|sw\|swt\).*$/\1/p' &>> "$path"/rem_id;
file3=$(cat  /home/massimiliano/ansible_module/procurve/rem_id |tr "\n" " ")
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
snmpwalk -v 2c -c pubrim $ip 1.3.6.1.2.1.31.1.1.1.6\
 |  sed -n -e 's/\(^.*\.\)\(.*\)\( = \)\(Counter64: [1-9].*$\)/\2/p' &>> "$path"/counters;
file6=$path/counters;
while IFS= read -r line; do
  intid=$(echo "$line");
  oid=".1.3.6.1.2.1.2.2.1.2."$intid
  snmpget -v 2c -c pubrim $ip $oid\
  | sed -e 's/^.*= STRING: //g'\
  | sed -e 's/^\(.\{12\}\).*//' | sed -e '/^\s*$/d' &>> "$path"/count_int;
done < "$file6"
#file7=$(cat  $path/count_int |tr "\n" " ")
#remcount=($file7)
#'''for (( j = 0; j < Lengthid; ++ j ));
#do
#  oid=".1.3.6.1.2.1.2.2.1.2.${lldpItem[$j]:0:1}"
#  snmpget -v 2c -c pubrim $ip $oid\
#   | sed -n -e 's/^.*STRING: //p' &>> "$PATH"/rem_int;
#done'''
file4=$(cat  $path/rem_int |tr "\n" " ")
remItem=($file4)
#only delete items if there lldp interfaces:
##for del in ${file4[@]}
##do
##   file1=("${file1[@]/$del}") #Quotes when working with strings
##done
Lengthrem=${#remItem[@]}
fileItem=($file1)
echo $file1
intupItem=($file2)
Length=${#fileItem[@]}
echo "$Length";
echo $file1
#the following it's been commented (see the script master)
##verpath=/home/massimiliano/ansible_module/host_vars/$hostname.yml;
##if [[ -e "$verpath" ]];then
##	msg="the file in host_vars folder must not be present yet. Exiting"
##	exit 0
##else
##  #
##  touch $verpath;
##  echo "---" &>>$verpath;
##  echo "loop_protect:" &>>$verpath;
##fi
###
build_range() {
  local range_start= range_end=
  local -a result

  end_range() {
      : range_start="$range_start" range_end="$range_end"
      [[ $range_start ]] || return
      if (( range_end == range_start )); then
        # single number; just add it directly
        result+=( "$range_start" )
      elif (( range_end == (range_start + 1) )); then
        # emit 6,7 instead of 6-7
        result+=( "$range_start" "$range_end" )
      else
        # larger span than 2; emit as start-end
        result+=( "$range_start-$range_end" )
      fi
      range_start= range_end=
  }

  # use the first number to initialize both values
  range_start= range_end=
  result=( )
  for number; do
    : number="$number"
    if ! [[ $range_start ]]; then
      range_start=$number
      range_end=$number
      continue
    elif (( number == (range_end + 1) )); then
      (( range_end += 1 ))
      continue
    else
      end_range
      range_start=$number
      range_end=$number
    fi
  done
  end_range
  (IFS=,; printf '%s\n' "${result[*]}")
}
########
for (( i = 0; i < Length; ++ i ));
do
  if [[ ${fileItem[$i]:0:1} =~ [a-zA-Z] && ${fileItem[$i]:1:1} =~ [0-9] ]]; then
    if [[ $initial == zero ]]; then
      initial=$fileItem;
      echo "$initial" &>>$path/camp$COUNT;
      #last=${fileItem[$i+1]};
      #MOD=$(expr $MOD + 1);
    else
      #echo "$fileItem" | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
      if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:1:1} =~ [0-9] ]]; then
        if [[ $MOD == 0 ]]; then
          initial=${fileItem[$i]};
          echo "$initial" &>>$path/camp$COUNT;
          MOD=$(expr $MOD + 1);
        fi
        last=${fileItem[$i+1]};
        echo "$last" &>>$path/camp$COUNT;
      else
        COUNT=$(expr $COUNT + 1);
        #initial=${fileItem[$i+1]};
        integer=$(expr $i + 1);
        #if ![[ $integer == Length ]]; then
        #  echo "$initial" &>>$path/camp$COUNT;
          echo "$COUNT" &> $path/Eth_int;
          MOD=0;
        #fi
        #echo "$initial" &>>$path/camp$COUNT;
        #echo "$COUNT" &> $path/Eth_int;
        #MOD=0;
      fi 
    fi
  #fi
  elif [[ ${fileItem[$i]:0:1} =~ [1-9] && ${fileItem[$i]:1:1} =~ '/' &&  ${fileItem[$i]:2:1} =~ [1-9] ]]; then
    if [[ $initial == zero ]]; then
      initial=$fileItem;
      echo "$initial" &>>$path/camp$COUNT;
      #last=${fileItem[$i+1]};
      #MOD=$(expr $MOD + 1);
    else
      if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:2:1} =~ [0-9] ]]; then
        if [[ $MOD == 0 ]]; then
          initial=${fileItem[$i]};
          echo "$initial" &>>$path/camp$COUNT;
          MOD=$(expr $MOD + 1);
        fi
        last=${fileItem[$i+1]};
        echo "$last" &>>$path/camp$COUNT;
        #echo "$fileItem" &>>$path/camp$COUNT;
      else
        COUNT=$(expr $COUNT + 1);
        #initial=${fileItem[$i+1]};
        #echo "$initial" &>>$path/camp$COUNT;
        echo "$COUNT" &> $path/Eth_int;
        MOD=0;
      fi
    fi
     #MOD=0;
  elif [[ ${fileItem[$i]:0:1} =~ [1-9] && ${fileItem[$i]:1:1} =~ '/' &&  ${fileItem[$i]:2:1} =~ [a-zA-Z] ]]; then
    if [[ $initial == zero ]]; then
      initial=$fileItem;
      echo "$initial" &>>$path/camp$COUNT;
      #last=${fileItem[$i+1]};
      #MOD=$(expr $MOD + 1);
    else
      if [[ ${fileItem[$i]:0:1} == ${fileItem[$i+1]:0:1} && ${fileItem[$i+1]:2:1} =~ [a-zA-Z] ]]; then
        if [[ $MOD == 0 ]]; then
          initial=${fileItem[$i]};
          echo "$initial" &>>$path/camp$COUNT;
          MOD=$(expr $MOD + 1);
        fi
        last=${fileItem[$i+1]};
        echo "$last" &>>$path/camp$COUNT;
        #echo "$fileItem" &>>$path/camp$COUNT;
      else
        COUNT=$(expr $COUNT + 1);
        #initial=${fileItem[$i+1]};
        #echo "$initial" &>>$path/camp$COUNT;
        echo "$COUNT" &> $path/Eth_int;
        MOD=0;
      fi
    fi
  #fi
  elif [[ ${fileItem[$i]:0:1} =~ [0-9]  ]]; then
    #second if condition set initial to first line character (if initial==zero)
    if [[ $initial == zero ]]; then
      initial=$fileItem;
      echo "$initial" &>>$path/camp$COUNT;
      #last=${fileItem[$i+1]};
      #MOD=$(expr $MOD + 1);
    else
      if [[ ${fileItem[$i]:0:1} =~ [0-9] && ${fileItem[$i+1]:0:1} =~ [0-9] ]]; then
        if [[ $MOD == 0 ]]; then
          initial=${fileItem[$i]};
          echo "$initial" &>>$path/camp$COUNT;
          MOD=$(expr $MOD + 1);
        fi
        last=${fileItem[$i+1]};
        echo "$last" &>>$path/camp$COUNT;
      else
        COUNT=$(expr $COUNT + 1);
        #initial=${fileItem[$i+1]};
        integer=$(expr $i + 1);
        #if ![[ $integer == Length ]]; then
          #echo "$initial" &>>$path/camp$COUNT;
          echo "$COUNT" &> $path/Eth_int;
          MOD=0;
        #fi
      fi
    fi
  elif [[ ${fileItem[$i]:0:1} =~ [tT] && ${fileItem[$i]:1:1} =~ [rR] ]]; then
    if [[ $initial == zero ]]; then
      #echo "$initial" &>>$path/camp$COUNT;
      #last=${fileItem[$i+1]};
      MOD=$(expr $MOD + 1);
    else
      #statements
    #now is time to build camp var with elements
      initial=${fileItem[$i]}
      #if [[ $initial == $last ]]; then
        #:
      #COUNT=$(expr $COUNT + 1);
      echo "$initial" &>>$path/camp$COUNT;
      #COUNT=$(expr $COUNT + 1);
      #initial=${fileItem[$i+1]};
      echo "$COUNT" &> $path/Eth_int;
      #next condition try to verify if next line character is a number if so set last var
     fi
  fi
done
#file8=$(cat  $path/Eth_int |tr "\n" " ")
#Length2=($file8)
#echo $Length2;
##fileItem=($file)
##Length=${#fileItem[@]}
##path="/home/massimiliano"
#virg=','
#camp=0
#file7=$(cat  $path/count_int |tr "\n" " ")
#remcount=($file7)
#echo $file7
#for (( i = 0; i < Length2; ++ i ));
#do
#  camp=$(cat  $path/camp$i)
#  for del in ${file7[@]}
#  do
#    camp=("${camp[@]/$del}") #Quotes when working with strings
#    echo $camp
#    #export camp;
#  done
#  COUNT=$(expr $i + 1)
#  #if [[ $COUNT < $Length2  ]]; then
#  #echo $camp;
#  #export camp
#  #######echo $camp | sed -e '$!s/$/,/' &>>$path/add_camp$i;
#  #else
#  #  echo $camp &>>$path/add_camp$i;
#  #fi
#  #######tr -d '\n' < $path/add_camp$i > $path/ports$i
#  #######sed -i 's/ /, /g' $path/ports$i
#  #source $script_path2;
#  #######echo $ports$i;
#done
##rm -f $path/ports*
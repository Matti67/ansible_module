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
path="/home/max/ansible/module/procurve"
#rm -f $path/rem*;
#rm -f $path/int*;
#rm -f $path/lldp_i*;
#rm -f $path/Eth_int;
#rm -f $path/camp*;
#rm -f $path/add_camp*;
#file2=$(cat  /home/max/ansible/procurve/int_up |tr "\n" " ")
#snmpwalk -v 2c -c pubrim $ip .1.3.6.1.2.1.2.2.1.2\
# | sed -n -e 's/^.*STRING: //p' &>> "$path"/int; 
#file1=$(cat  /home/max/ansible/module/procurve/int |tr "\n" " ")
#hostname=$(snmpget -v 2c -c pubrim $ip sysName.0 | sed -n -e 's/^.*STRING: //p')
#verpath=/home/max/ansible/module/host_vars/$hostname.yml;
#snmpbulkwalk -v 2c -c pubrim $ip 1.0.8802.1.1.2.1.4.1.1.9\
#| sed -n -e 's/^.*\.\(.*\)\.\(.* =.*\).*\(SW\|SWT\|sw\|swt\).*$/\1/p' &>> "$path"/rem_id;
#file3=$(cat  /home/max/ansible/module/procurve/rem_id |tr "\n" " ")
##chek if int_free was introduced to host_vars yet
#if grep -q int_free "$verpath"; then
#  msg="the int_free field must not be present yet. Exiting"
#  exit 0
#else
#  echo "ports_free:" &>>$verpath;
#fi
#file5=$path/rem_id;
#while IFS= read -r line; do
#  intid=$(echo "$line");
#  oid=".1.3.6.1.2.1.2.2.1.2."$intid
#  snmpget -v 2c -c pubrim $ip $oid\
#  | sed -n -e 's/^.*STRING: //p' &>> "$path"/rem_int;
#done < "$file5"
rm -f $path/int*;
#rm -f $path/res*;
rm -f $path/ports;
ip=$1
export ip
echo $ip;
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
  (IFS=,; printf '%s\n' "${result[*]}" &> $path/result)
  #(printf '%s\n' "${result[*]}") &> $path/result
}
#file8=$(cat  $path/Eth_int |tr "\n" " ")
#Length2=($file8)
#echo $Length2;
#hostname=$(snmpget -v 2c -c pubrim $ip sysName.0 | sed -n -e 's/^.*STRING: //p')
#source /home/max/ansible/module/library/hp_nolldp2.sh
#source /home/max/ansible/module/library/hp_counters.sh
#
file8=$(cat  $path/Eth_int |tr "\n" " ")
Length2=($file8)
echo $Length2;
hostname=$(snmpget -v 2c -c pubrim $ip sysName.0 | sed -n -e 's/^.*STRING: //p')
#fileItem=($file)
#Length=${#fileItem[@]}
#path="/home/max"
virg=','
verpath=/home/max/ansible/module/host_vars/$hostname.yml;
#chek if int_free was introduced to host_vars yet
#if [[ -e "$verpath" ]];then
# msg="the file in host_vars folder must not be present yet. Exiting"
# exit 0
#else
#  #
#  touch $verpath;
#  #echo "---" &>>$verpath;
#  echo "loop_protect:" &>>$verpath;
#fi
if [[ -e "$verpath" ]];then
 echo "loop_protect:" &>>$verpath;
 #exit 0
fi
#
file7=$(cat  $path/rem_int |tr "\n" " ")
#remcount=($file7)
#echo $file7
for (( i = 0; i < Length2; ++ i ));
do
  camp=$(cat  $path/camp$i)
  rm -f $path/int*;
  for del in ${file7[@]}
  do
    camp=("${camp[@]/$del}") #Quotes when working with strings
    echo $camp
    #export camp;
  done
  intItem=($camp)
  if [[ ${intItem[1]:0:1} =~ [a-zA-Z] && ${intItem[1]:1:1} =~ [0-9] ]]; then
    Length=${#intItem[@]}
    COUNT=$(expr $i + 1)
    #if [[ $COUNT < $Length2  ]]; then
    val=0;
    letter=${intItem[1]:0:1}
    eval "letter=letter$i"
    echo $camp | sed -e 's/[A-Z]//g' &> $path/integer;
    cat $path/integer | tr " " "," &> $path/intg;
    in_intg=$(cat $path/intg)
    IFS=, read -r -a numbers <<< "$in_intg"
    build_range "${numbers[@]}"
    #the commented line below works anyway
    #cat $path/result | sed -e "s/\([1-9]\|[1-9][1-9]\)/${intItem[1]:0:1}&/g" &>> $path/ports
    cat $path/result | sed -e "s/\([1-9]\{1,2\}\)/${intItem[1]:0:1}&/g" &>> $path/ports;
    #cat $path/ports | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
    #cat $path/result;
  elif [[ ${intItem[0]:0:1} =~ [1-9] && ${intItem[0]:1:1} =~ '/' &&  ${intItem[0]:2:1} =~ [1-9] ]]; then
    ength=${#intItem[@]}
    COUNT=$(expr $i + 1)
    #if [[ $COUNT < $Length2  ]]; then
    val=0;
    letter=${intItem[1]:0:1}
    eval "letter=letter$i"
    echo $camp | sed -e "s/[1-9]\///g" &> $path/integer;
    cat $path/integer | tr " " "," &> $path/intg;
    in_intg=$(cat $path/intg)
    IFS=, read -r -a numbers <<< "$in_intg"
    build_range "${numbers[@]}"
    #the commented line below works anyway
    #cat $path/result | sed -e "s/\([1-9]\|[1-9][1-9]\)/${intItem[1]:0:1}&/g" &>> $path/ports
    cat $path/result | sed -e "s/\([1-9]\{1,2\}\)/${intItem[1]:0:1}\/&/g" &>> $path/ports
    #cat $path/ports | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
  #
  elif [[ ${intItem[0]:0:1} =~ [1-9] && ${intItem[0]:1:1} =~ '/' &&  ${intItem[0]:2:1} =~ [A-Z] ]]; then
    ength=${#intItem[@]}
    COUNT=$(expr $i + 1)
    #if [[ $COUNT < $Length2  ]]; then
    val=0;
    letter=${intItem[1]:0:1}
    eval "letter=letter$i"
    echo $camp | sed -e "s/[1-9]\/[A-Z]//g" &> $path/integer;
    cat $path/integer | tr " " "," &> $path/intg;
    in_intg=$(cat $path/intg)
    IFS=, read -r -a numbers <<< "$in_intg"
    build_range "${numbers[@]}"
    #the commented line below works anyway
    #cat $path/result | sed -e "s/\([1-9]\|[1-9][1-9]\)/${intItem[1]:0:1}&/g" &>> $path/ports
    cat $path/result | sed -e "s/\([1-9]\{1,2\}\)/${intItem[0]:0:1}\/${intItem[0]:2:1}&/g" &>> $path/ports
    #cat $path/ports | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
  elif [[ ${intItem[1]:0:1} =~ [1-9] ]]; then
    ength=${#intItem[@]}
    COUNT=$(expr $i + 1)
    #if [[ $COUNT < $Length2  ]]; then
    val=0;
    letter=${intItem[1]:0:1}
    eval "letter=letter$i"
    echo $camp &> $path/integer;
    cat $path/integer | tr " " "," &> $path/intg;
    in_intg=$(cat $path/intg)
    IFS=, read -r -a numbers <<< "$in_intg"
    build_range "${numbers[@]}"
    #the commented line below works anyway
    #cat $path/result | sed -e "s/\([1-9]\|[1-9][1-9]\)/${intItem[1]:0:1}&/g" &>> $path/ports
    cat $path/result &>> $path/ports
    #cat $path/ports | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
  fi
done
cat $path/ports | sed -e 's/\(^\)\(.*\)/  - \1\2/g' &>>$verpath;
#cat $path/ports;
#cat /home/max/ansible/module/templates/temp_aruba &>>$verpath;
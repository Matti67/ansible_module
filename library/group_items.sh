#!/bin/bash
path="/home/max/ansible/module/procurve"
#rm -f $path/rem*;
#rm -f $path/int*;
#rm -f $path/lldp_i*;
#rm -f $path/Eth_int;
#rm -f $path/camp*;
#rm -f $path/add_camp*;
#rm -f $path/count*;
#rm -f $path/ports*;
#file2=$(cat  /home/max/ansible/module/procurve/camp |tr "\n" " ")
file8=$(cat  $path/Eth_int |tr "\n" " ")
Length2=($file8)
echo $Length2;
#fileItem=($file)
#Length=${#fileItem[@]}
#path="/home/max"
virg=','
#camp=0
file7=$(cat  $path/count_int |tr "\n" " ")
#remcount=($file7)
#echo $file7
for (( i = 0; i < Length2; ++ i ));
do
  camp=$(cat  $path/camp$i)
  for del in ${file7[@]}
  do
    camp=("${camp[@]/$del}") #Quotes when working with strings
    echo $camp
    #export camp;
  done
  intItem=($camp)
  Length=${#intItem[@]}
  COUNT=$(expr $i + 1)
  #if [[ $COUNT < $Length2  ]]; then
  val=0;
  for (( j = 0; j < Length; ++ j ));
    do
      #: range_start="${intItem[$j]}" range_end="$range_start"
      if [[ ${intItem[$j]:0:1} =~ [a-zA-Z] && ${intItem[$j]:1:1} =~ [0-9] ]]; then
        echo ${intItem[$j]} | sed -e 's/^.//g' > $path/integer;
        intg = $(cat $path/integer)
        intg = $(expr $intg + 1);
        echo ${intItem[$j+1]} | sed -e 's/^.//g' > $path/integerfor;
        intgfor = $(cat $path/integerfor)
        if [[ $intgfor == $intg ]]; then
          #range_start=${intItem[$j]}
          if [[ $val == 0 ]]; then
            range_start=${intItem[$j]}
          fi
          range_end=${intItem[$j+1]}
          val=$(expr $val + 1);
        else
          if [[ $val -gt 0 ]]; then
            echo $range_start-$range_end &>> $path/add_camp$i;
            val=0;
            range_start=${intItem[$j+1]};
           else
             echo ${intItem[$j+1]} &>> $path/add_camp$i;
          fi
        fi
      fi 
    done 
  #echo $camp;${intItem[$i]:0:1}
  #export camp
  file9=$(cat  $path/add_camp$i |tr "\n" " ")
  #echo $file9 | sed -e '$!s/$/,/' &>>$path/add_camp$i;
  sed -i '$!s/$/,/' $path/add_camp$i;
  #else
  #  echo $camp &>>$path/add_camp$i;
  #fi
  tr -d '\n' < $path/add_camp$i > $path/ports$i
  sed -i 's/ /, /g' $path/ports$i
  #source $script_path2;
  echo $ports$i;
  #
done
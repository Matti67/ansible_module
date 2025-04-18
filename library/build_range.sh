#!/bin/bash
path="/home/max/ansible/module/procurve"
rm -f $path/int*;
rm -f $path/res*;
rm -f $path/ports;
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
}
file8=$(cat  $path/Eth_int |tr "\n" " ")
Length2=($file8)
echo $Length2;
#fileItem=($file)
#Length=${#fileItem[@]}
#path="/home/max"
virg=','
#fileItem=($file8)
#echo $file1
#intupItem=($file2)
#Length2=${#fileItem[@]}
#camp=0
file7=$(cat  $path/count_int |tr "\n" " ")
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
    cat $path/result | sed -e "s/\([1-9]\{1,2\}\)/${intItem[1]:0:1}&/g" &>> $path/ports
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
  fi
done
cat $path/ports;
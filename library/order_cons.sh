#!/bin/bash
path="/home/massimiliano/ansible_module/procurve"
#rm -f $path/rem*;
#rm -f $path/int*;
#rm -f $path/lldp_i*;
#rm -f $path/Eth_int;
#rm -f $path/camp*;
#rm -f $path/add_camp*;
#rm -f $path/count*;
#rm -f $path/ports*;
#file2=$(cat  /home/massimiliano/ansible_module/procurve/camp |tr "\n" " ")
#file8=$(cat  $path/Eth_int |tr "\n" " ")
#Length2=($file8)
#echo $Length2;
#fileItem=($file)
#Length=${#fileItem[@]}
#path="/home/massimiliano"
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
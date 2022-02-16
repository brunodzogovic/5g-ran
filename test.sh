#!/bin/bash
# Bash Menu Script Example

PS3='Please enter your choice: '
options=($(ip route |awk 'NR>1{print $3}'))
len=${#options[@]}
for (( i=0; i<${len}; i++ ));
do
    select opt in "${options[@]}"; 
    do
	if [[ $len > $opt ]];
	then 
	    echo "No such choice available, try again!"
	else
	    INT_INTERFACE=$opt
    	    echo "Selected interface: $opt"
            break
	fi
    done 
break
done

echo $INT_INTERFACE


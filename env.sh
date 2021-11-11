#! /bin/bash 

cd /openairinterface5g
source oaienv
git checkout develop
git pull
cd /openairinterface5g/cmake_targets/
./build_oai -i -I -w USRP -x --gNB
wait
file="/openairinterface5g/targets/ARCH/USRP/USERSPACE/LIB/usrp_lib.cpp"
red=$(tput setaf 1)
green=$(tput setaf 2)
orange=$(tput setaf 3)
reset=$(tput sgr0)

echo "${orange}Enter the model of your USRP (Options: B210, X310, N310, N320 or N321 respectively):${reset}"
while read -r USRP_MODEL
do 
    if [[ -z "$USRP_MODEL" ]];
    then
      echo "No input. Please enter a USRP model..."
    elif ! [[ "$USRP_MODEL" =~ ^(B210|X310|N310|N320|N321)$ ]];	
    then
      echo "Wrong model name. Please try again..." 
    elif [[ $USRP_MODEL != N321 ]];
    then
      echo "${green}The clock frequencies are already set${reset}"
      break
      exit
    elif [[ $USRP_MODEL = N321 ]];
    then 
      echo "${green}Your USRP model is: ${red}$USRP_MODEL${reset}" 
      sleep 1
      echo "${orange}Distinct USRP models support different clock frequency rates. For example, N320 cannot work on 200 Mhz whereas N321 cannot work under 200 MHz. Enter the required clock frequency of your device in decimal numbers (Example 200.30 or 188.43 etc). Enter the clock rate of your device: ${reset}"
   	while read -r CLOCK_RATE
	do
    	  if ! [[ "$CLOCK_RATE" =~ ^[0-9][0-9][0-9]+([.][0-9][0-9]+)+$ ]]; 
     	  then 	
      	    echo "${red} The clock rate is incorrect. Please enter a valid number with the format XXX.XX...${reset}"
    	  else
      	    sed -i "s/122.88e6/$CLOCK_RATE\e6/g" "$file"
      	    sleep 1
      	    echo "${green}The clock frequency of the ${red}$USRP_MODEL ${green}is set to ${red}$CLOCK_RATE${reset}"
	    sleep 1
    	  break	
          fi
	done
    break	
    fi
done




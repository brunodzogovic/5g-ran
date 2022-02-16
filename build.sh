#!/bin/bash 
# The script can run on Ubuntu 18.04/20.04 hosts

file=env.sh 
red=`tput setaf 1`
green=`tput setaf 2`
orange=`tput setaf 3`
reset=`tput sgr0`

# Take the default route interface and put it in variable. This will be used as a parent interface for routing MACVLAN traffic from containers to the host NIC
echo "${green}Registering main interface from default route to external network... ${reset}"
sleep 1
EXT_INTERFACE=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
echo "${green}$EXT_INTERFACE${reset}"
# Register the default gateway in a variable
echo "${green}Registering the default gateway... ${reset}"
GATEWAY=$(ip route |awk 'NR<2{print $3}')
sleep 1
echo "${green}$GATEWAY${reset}"
echo "${orange}Enter the internal network IP address of your base-station SDR as a gateway IP: ${reset}"
read USRP_IP
sleep 1
# Select the interface to be used as an internal connection to the USRP SDR
echo "${orange}Choose which interface will connect to your internal network: ${reset}"
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
            echo "${green}Selected interface: $opt ${reset}"
            break
        fi
    done
break
done
INT_INTERFACE=$opt

echo "${orange}Enter your Docker repository name: ${reset}" 
read REPO
sleep 1 
echo "${orange}Enter your external MACVLAN network name: ${reset}" 
read EXT_MACVLAN_NET 
sleep 1
echo "${orange}Enter your internal MACVLAN network name: ${reset}"
read INT_MACVLAN_NET
sleep 1
echo "${orange}Enter your external subnet that routes to the internet (xxx.xxx.xxx.xxx/xx): ${reset}" 
read EXT_SUBNET
sleep 1
echo "${orange}Enter your internal subnet that connects your RAN (xxx.xxx.xxx.xxx/xx): ${reset}"
read INT_SUBNET
sleep 1
echo "${orange}Enter an IP address for your container to attach to the external MACVLAN network: ${reset}" 
read EXT_IP_ADDRESS
sleep 1
echo "${orange}Enter an IP address for your container to attach to the internal MACVLAN network: ${reset}" 
read INT_IP_ADDRESS
sleep 1
echo "${green}Creating MACVLAN Docker network and connecting a driver to the $EXT_SUBNET subnet... Please wait...${reset}" 
docker network create -d macvlan --subnet $EXT_SUBNET --gateway $GATEWAY -o parent=$EXT_INTERFACE --attachable $EXT_MACVLAN_NET
wait
echo "${green}Done!${reset}" 
sleep 1
echo "${green}Creating MACVLAN Docker network and connecting a driver to the $INT_SUBNET subnet... Please wait...${reset}" 
docker network create -d macvlan --subnet $INT_SUBNET --gateway $USRP_IP -o parent=$INT_INTERFACE --attachable $INT_MACVLAN_NET
wait
echo "${green}Done!${reset}" 
sleep 1
#
# Configuring the USRP sampling rate for the appropriate model
#
echo "${orange}Enter the model of your USRP (Options: B210, X310, N310, N320 or N321 respectively):${reset}"
while read -r USRP_MODEL
do
    if [[ -z "$USRP_MODEL" ]];
    then
      echo "${red}No input. Please enter a USRP model...${reset}"
    elif ! [[ "$USRP_MODEL" =~ ^(B210|X310|N310|N320|N321)$ ]];
    then
      echo "${red}Wrong model name. Please try again...${reset}"
    elif [[ $USRP_MODEL != N321 ]];
    then
      echo "${green}The clock frequencies are already set${reset}"
      break
      exit
    elif [[ $USRP_MODEL = N321 ]];
    then
      echo "${green}Your USRP model is: ${red}$USRP_MODEL${reset}"
      sleep 1
      echo "${green} Increasing the network kernel socket send/receive buffers to 25000000 to avoid dropped packets to the USRP..."
      sysctl -w net.core.wmem_max=62500000
      sysctl -w net.core.rmem_max=62500000
      ulimit -s 8192 
      sleep 1
      echo "Done!${reset}"
      echo "${orange}Distinct USRP models support different clock frequency rates. For example, N320 cannot work on 200 Mhz whereas N321 cannot work under 200 MHz. Enter the required clock frequency of your device in decimal numbers ${green}(N321 supported clock rates: 200.00, 245.76 or 250.00 MHz). ${orange}Enter the clock rate of your device: ${reset}"
        while read -r CLOCK_RATE
        do
          if ! [[ "$CLOCK_RATE" =~ ^[0-9][0-9][0-9]+([.][0-9][0-9]+)+$ ]];
          then
            echo "${red} The clock rate is incorrect. Please enter a valid number with the format XXX.XX...${reset}"
          else
            sed -i 's/^CLOCK_RATE=.*/CLOCK_RATE='"$CLOCK_RATE"'/g' "$file" 
            sleep 1
            echo "${green}The clock frequency of the ${red}$USRP_MODEL ${green}is set to ${red}$CLOCK_RATE${reset}"
            sleep 1
          break
          fi
        done
    break
    fi
done

docker build -t $REPO/5g_gnb .
process_id1=$!
wait $process_id1
docker commit -m "Built latest version of the 5G gNB" 5g_gnb $REPO/5g_gnb
wait
docker push 
wait
# Run the container after the iamge is pushed to the repository
docker run -it --privileged --net $EXT_MACVLAN_NET --ip $EXT_IP_ADDRESS --hostname=5g_gnb --restart=unless-stopped --name=5g_gnb -v /dev/bus/usb:/dev/bus/usb -v /lib/modules:/lib/modules -v /etc/network:/etc/network:rw --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" $REPO/5g_gnb
wait
docker network connect --ip $INT_IP_ADDRESS $INT_MACVLAN_NET 5g_gnb

# Copy the configuration file manually in the end to avoid git checkout errors in previous stages
docker cp gnb.band78.sa.fr1.106PRB.usrpn310.conf 5g_gnb:/openairinterface5g/ci-scripts/conf_files/

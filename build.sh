#!/bin/bash 
# The script can run on Ubuntu 18.04/20.04 hosts

file=env.sh 
red=`tput setaf 1`
green=`tput setaf 2`
orange=`tput setaf 3`
reset=`tput sgr0`
# Take the default route interface and put it in variable. This will be used as a parent interface for routing MACVLAN traffic from containers to the host NIC
ETH_INTERFACE=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")

echo "${orange}Enter your MACVLAN network name: ${reset}" 
read MACVLAN_NET 
sleep 1
echo "${orange}Enter your subnet (xxx.xxx.xxx.xxx/xx): ${reset}" 
read SUBNET
sleep 1 
echo "${orange}Enter your default gateway (xxx.xxx.xxx.xxx): ${reset}" 
read GATEWAY
sleep 1
echo "${green}Creating MACVLAN Docker network and connecting a driver to the 192.168.10.0/24 subnet... Please wait...${reset}" 
docker network create -d macvlan --subnet $SUBNET --gateway $GATEWAY -o parent=$ETH_INTERFACE --attachable $MACVLAN_NET
sleep 3
echo "${green}Done!${reset}" 
sleep 1
echo "${orange}Enter your Docker repository name: ${reset}" 
read REPO 
sleep 1 
echo "${orange}Enter an IP address for your container to attach to the MACVLAN network: ${reset}" 
read IP_ADDRESS
sleep 1
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
      sysctl -w net.core.wmem_max=25000000
      sysctl -w net.core.rmem_max=25000000 
      sleep 1
      echo "Done!${reset}"
      echo "${orange}Distinct USRP models support different clock frequency rates. For example, N320 cannot work on 200 Mhz whereas N321 cannot work under 200 MHz. Enter the required clock frequency of your device in decimal numbers ${green}(N321 supported clock rates: 200.00, 245.76 or 250.00 MHz). ${orange}Enter the clock rate of your device: ${reset}"
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

docker build -t $REPO/5g_gnb .
wait
docker run -it --privileged --net $MACVLAN_NET --ip $IP_ADDRESS --hostname=5g_gnb --restart=unless-stopped --name=5g_gnb -v /lib/modules:/lib/modules -v /etc/network:/etc/network:rw --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" $REPO/5g_gnb

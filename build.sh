#!/bin/bash 


red=`tput setaf 1`
green=`tput setaf 2`
orange=`tput setaf 3`
reset=`tput sgr0`
# Take the default route interface and put it in variable. This will be used as a parent interface for routing MACVLAN traffic from containers to the host NIC
ETH_INTERFACE=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
sleep 2
echo "${orange}Enter your MACVLAN network name: ${reset}" 
read MACVLAN_NET 
sleep 2
echo "${orange}Enter your subnet (xxx.xxx.xxx.xxx/xx): ${reset}" 
read SUBNET
sleep 2 
echo "${orange}Enter your default gateway (xxx.xxx.xxx.xxx): ${reset}" 
read GATEWAY
sleep 2
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
docker build -t $REPO/5g_gnb .
wait
docker run -itd --privileged --net $MACVLAN_NET ip $IP_ADDRESS --hostname=5g_gnb --restart=unless-stopped --name=5g_gnb -v /lib/modules:/lib/modules -v /etc/network:/etc/network:rw --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" $REPO/5g_gnb

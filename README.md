# 5G-RAN

Dockerfile for building an image for OpenAirInterface5G RAN for the gNB

The Dockerfile installs the gNB for 5G RAN from OpenAirInterface into a Docker container. The regular builds are pushed into the Docker repository ```brunodzogovic/5g_gnb```. This Dockerfile builds the RAN in monolithic version and the IP addressing of the AMF/NRF should be adjusted accordingly into the configuration files manually (in the future, it will be implemented to be configurable before building the gNB). 

Make sure the same UHD driver version is present on the FPGA as the one being installed in the container. If the installed FPGA UHD driver is i.e. version 4.1.0.0, then you can change this value in the env variable in the Dockerfile. The installation script addresses the issue with incorrect clock frequency for the USRP N321 model. Fir example, the N321 does not support clock frequencies below 200 MHz, whereas the N320 does. . 

Building the container: ```/bin/bash build.sh``` the script will build and then run the container based on your previous input. The installation initializes a Docker MACVLAN network for Ethernet connectivity. Make sure you have an appropriate L2 switch that supports VLAN trunking and port promiscuous mode in order to use the container as a physical machine. 

Note that mapping the volume of /dev/bus/usb is necessary only for the SDRs running through USB.  

The environmental variable DISPLAY in the build script serves for the purpose of enabling X11 sessions coming from the container. This is necessary for the gNB x-forms to be represented on screen, providing information on the FFT, channel coding and the general signal connection details. 

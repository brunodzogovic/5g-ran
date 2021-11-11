# 5G-RAN

Dockerfile for building an image for OpenAirInterface5G RAN for the gNB

The Dockerfile installs the gNB for 5G RAN from OpenAirInterface into a Docker container. The regular builds are pushed into the Docker repository ```brunodzogovic/5g_gnb```. This Dockerfile builds the RAN in monolithic version and the IP addressing of the AMF/NRF should be adjusted accordingly into the configuration files manually (in the future, it will be implemented to be configurable before building the gNB). 

Make sure the same UHD driver version is present on the FPGA as the one being installed in the container. If the installed FPGA UHD driver is i.e. version 4.1.0.0, then you can change this value in the Dockerfile. The installation script asks for the correct USRP model so it can set the correct clock frequency for certain USRP devices. For example, the USRP N321 does not support clock frequencies below 200 MHz, whereas the N320 does. This can be changed when the build requests an input. 

To build the containers, simply run ```docker build -t [your_docker_repository]/5g_gnb .``` it will invoke the Dockerfile and necessary side scripts.

To run the containers, one can do the following (note that mapping the volume of /dev/bus/usb is necessary only for the SDRs running through USB): 

```
docker run -itd --privileged --net=[your_network] --hostname=5g_gnb --restart=unless-stopped --name=5g_gnb -v /dev/bus/usb:/dev/bus/usb -v /lib/modules:/lib/modules -v /etc/network:/etc/network:rw --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" [your_docker_repository]/5g_gnb
```

The environmental variable DISPLAY serves for the purpose of enabling X11 sessions coming from the container. This is necessary for the gNB x-forms to be represented on screen, providing information on the FFT, channel coding and the general signal connection details. 

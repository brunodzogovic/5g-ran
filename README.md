# 5G-RAN

Dockerfile for building an image for OpenAirInterface5G RAN for the gNB

The Dockerfile installs the gNB for 5G RAN from OpenAirInterface into a Docker container. The regular builds are pushed into the Docker repository ```brunodzogovic/5g_gnb```. This Dockerfile builds the RAN in monolithic version and the IP addressing of the AMF/NRF should be adjusted accordingly into the configuration files manually (in the future, it will be implemented to be configurable before building the gNB). 

Note that the latest Git pulls will also invoke new UHD libraries and images for the FPGA of the particular SDR, since the code is based on the latest develop branches of OpenAirInterface. If the N or X-series of USRP SDRs are used, then the UHD image version in the container should be the same as the one loaded in the FPGA. Please refer to this link how to load the same image into the FPGA: https://files.ettus.com/manual/page_usrp_n3xx.html (the proper model of the device should be selected). For example, if the latest repository version contains the v4.0 of the UHD driver, then the USRP N320 or X320 for example should have the same image version in order to work.

To build the containers, simply run ```docker build -t [your_docker_repository]/5g_gnb .``` it will invoke the Dockerfile and necessary side scripts.

To run the containers, one can do the following (note that mapping the volume of /dev/bus/usb is necessary only for the SDRs running through USB): 

```
docker run -itd --privileged --net=[your_network] --hostname=5g_gnb --restart=unless-stopped --name=5g_gnb -v /dev/bus/usb:/dev/bus/usb -v /lib/modules:/lib/modules -v /etc/network:/etc/network:rw --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" [your_docker_repository]/5g_enb
```

The environmental variable DISPLAY serves for the purpose of enabling X11 sessions coming from the container. This is necessary for the gNB x-forms to be represented on screen, providing information on the FFT, channel coding and the general signal connection details. 

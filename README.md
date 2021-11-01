# 5g-ran
Dockerfile for building an image for OpenAirInterface5G RAN for the gNB

The Dockerfile installs the gNB for 5G RAN from OpenAirInterface into a Docker container. The regular builds are pushed into the Docker repository ```brunodzogovic/5g_gnb```

Note that the latest Git pulls will also invoke new UHD libraries and images for the FPGA of your SDR. If the N or X-series of USRP SDRs are used, then the UHD image version in the container should be the same as the one loaded in the FPGA. Please refer to this link how to load the same image into the FPGA: https://files.ettus.com/manual/page_usrp_n3xx.html (the proper model of the device should be selected)

To run the containers, one can do the following: 

```
docker run -i -t -d --privileged --net=[your_network] --hostname=5g_enb --restart=unless-stopped --name=5g_enb -v /dev/bus/usb:/dev/bus/usb -v /lib/modules:/lib/modules -v /etc/network:/etc/network:rw --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" brunodzogovic/5g_enb
```

the environmental variable DISPLAY serves for the purpose of enabling X11 sessions coming from the container. This is necessary for the gNB x-forms to be represented on screen, providing information on the FFT, channel coding and the general signal connection details. 

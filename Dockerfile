FROM ubuntu:18.04 
LABEL org.opencontainers.image.authors="bruno.dzogovic@gmail.com"
ENV TZ=Europe/Oslo
ENV UHD_IMAGES_DIR=/usr/share/uhd/images
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade && apt-get install -y \
        software-properties-common \
	apt-transport-https \
        apt-utils \
	&& DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:ettusresearch/uhd -y \
	&& DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:ubuntu-toolchain-r/test -y \ 
	&& DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \	
	gcc-9 \
	g++-9 \
	libboost-all-dev \ 
	curl \
        git \
        subversion \
        vim \
        net-tools \
        iputils-ping \
        unzip \	
	libuhd-dev \
	libuhd4.1.0 \
	uhd-host=4.1.0.4-0ubuntu1~bionic1 -y \
	&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9 \
	&& update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9 \
        && git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git
RUN uhd_images_downloader
COPY env.sh /openairinterface5g/env.sh 
WORKDIR /openairinterface5g
RUN ./env.sh  


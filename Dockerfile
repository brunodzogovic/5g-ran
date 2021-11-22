FROM ubuntu:18.04 
LABEL org.opencontainers.image.authors="bruno.dzogovic@gmail.com"
ENV TZ=Europe/Oslo
ENV BUILD_UHD_FROM_SOURCE=True
ENV UHD_VERSION=4.1.0.4
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get upgrade && apt-get install -y \
        software-properties-common \
	apt-transport-https \
        apt-utils \
	&& apt-add-repository ppa:ubuntu-toolchain-r/test -y \ 
	&& apt-get update && apt-get install -y \	
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
	&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9 \
	&& update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9 \
        && git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git

COPY env.sh /openairinterface5g/env.sh 
WORKDIR /openairinterface5g
RUN ./env.sh  


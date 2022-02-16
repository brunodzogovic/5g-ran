FROM ubuntu:bionic 
LABEL org.opencontainers.image.authors="bruno.dzogovic@gmail.com"
ENV TZ=Europe/Oslo
ENV BUILD_UHD_FROM_SOURCE=True
ENV UHD_VERSION=3.15.0.0
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        software-properties-common \
	apt-transport-https \
        apt-utils \	
	curl \
        git \
        subversion \
        vim \
        net-tools \
        iputils-ping \
        unzip \		
        && git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git
COPY env.sh /openairinterface5g/env.sh
WORKDIR /openairinterface5g
RUN ./env.sh  


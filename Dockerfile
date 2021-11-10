FROM ubuntu:18.04 
LABEL org.opencontainers.image.authors="bruno.dzogovic@gmail.com"
ENV TZ=Europe/Oslo 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get upgrade && apt-get install -y \
	apt-transport-https \	
	curl \
	git \
	subversion \ 
	vim \
	net-tools \ 
	iputils-ping \ 
	unzip \
	&& git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git

COPY env.sh /openairinterface5g/env.sh 
RUN ./openairinterface5g/env.sh  

WORKDIR /openairinterface5g/cmake_targets 
RUN ./build_oai -i -I -w USRP -x --gNB 

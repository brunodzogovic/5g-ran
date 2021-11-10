#! /bin/bash 

export BUILD_UHD_FROM_SOURCE=True
export UHD_VERSION=4.1.0.0
cd /openairinterface5g
source oaienv
git checkout develop 
git pull 


#!/bin/bash 

CLOCK_RATE=200.00
cd /openairinterface5g
source oaienv
git checkout develop
git pull
file="/openairinterface5g/targets/ARCH/USRP/USERSPACE/LIB/usrp_lib.cpp"
sed -i "s/122.88e6/$CLOCK_RATE\e6/g" "$file"
cd /openairinterface5g/cmake_targets/
./build_oai -i -I -w USRP --gNB --build-lib "nrscope" 
process_id=$!
wait $process_id 
exit 


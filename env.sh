#!/bin/bash 

CLOCK_RATE=245.76
cd /openairinterface5g
source oaienv
git checkout develop
git pull
file="/openairinterface5g/targets/ARCH/USRP/USERSPACE/LIB/usrp_lib.cpp"
sed -i "s/122.88e6/$CLOCK_RATE\e6/g" "$file"
cd /openairinterface5g/cmake_targets/
yes | ./build_oai -I 
yes | ./build_oai --gNB -w USRP --build-lib "nrscope" 
process_id1=$!
wait $process_id1 
exit 


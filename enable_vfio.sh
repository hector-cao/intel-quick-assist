#!/bin/bash

rmmod vfio-pci
modprobe vfio-pci ids=8086:4940

QAT_BDF=0000\:$1

#echo down > /sys/bus/pci/devices/$QAT_BDF/qat/state
#echo "sym;asym" | tee /sys/bus/pci/devices/$QAT_BDF/qat/cfg_services
#echo up > /sys/bus/pci/devices/$QAT_BDF/qat/state

# 16 vfs, other value not possible
echo 16 > /sys/bus/pci/devices/$QAT_BDF/sriov_numvfs

#!/bin/bash

rmmod vfio-pci

# 4941 : PCI id of VF
modprobe vfio-pci ids=8086:4941

QAT_BDF=0000\:$1

#echo down > /sys/bus/pci/devices/$QAT_BDF/qat/state
#echo "sym;asym" | tee /sys/bus/pci/devices/$QAT_BDF/qat/cfg_services
#echo up > /sys/bus/pci/devices/$QAT_BDF/qat/state

# 16 vfs, other value not possible
echo 16 > /sys/bus/pci/devices/$QAT_BDF/sriov_numvfs

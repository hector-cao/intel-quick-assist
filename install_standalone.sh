#!/bin/bash

# List QAT physical devices
# 
lspci -d :4940 -k

apt install --no-install-recommends --yes qatengine qatlib-examples libqat4 qatzip

# list VFs (virtual functions)
lspci -d :4941 -k

rmmod vfio-pci
modprobe vfio-pci ids=8086:4941

QAT_BDF=0000\:70\:00.0

echo down > /sys/bus/pci/devices/$QAT_BDF/qat/state
echo dc > /sys/bus/pci/devices/$QAT_BDF/qat/cfg_services
echo up > /sys/bus/pci/devices/$QAT_BDF/qat/state

echo 16 > /sys/bus/pci/devices/$QAT_BDF/sriov_numvfs

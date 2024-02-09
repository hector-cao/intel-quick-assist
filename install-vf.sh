#!/bin/bash

# Install QAT with VF support
# VF uses SR-IOV

# make sure QAT device support SR-IOV
lspci -vn -d :4940|grep -i SR-IOV

# QAT VFs only available on hardware platforms supporting VT-d (Virtualization tech for Directed I/O)
# BIOS configuration : enable VT-d and SR-IOV 

# check if SR-IOV is enabled ?
# if DMAR: IOMMU enabled -> SR-IOV enabled 
dmesg | grep DMAR
if [ $? -ne 0 ]; then
    echo "Should enable SR-IOV in BIOS"
fi

# Check QAT VF
# For the 4th Gen Intel Xeon Scalable processors (Sapphire Rapids), then QAT PF device ID is 0x4940,
# the VF device ID is 0x4941
lspci -d :4941


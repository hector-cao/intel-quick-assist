#!/bin/bash

set -e

# PPA
add-apt-repository -y ppa:kobuk-team/qat-ubuntu

# List QAT physical devices
# 
lspci -d :4940 -k

# list QAT virtual devices (must enable SR_IOV 


# qatengine
apt install --yes qatengine

# qatzip


# BIOS : must enable VT-d

# Kernel : must add intel_iommu=on and iommu=pt

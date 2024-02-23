#!/bin/bash

#set -x

# Install the 6.8 kernel
UNAME_R=$(uname -r)
if [[ $UNAME_R != 6.8* ]]; then
    apt-add-repository -y ppa:canonical-kernel-team/ubuntu/unstable
    # install kernel
    apt install -y linux-image-6.8.0-5-generic
    ### qat drivers are in modules-extra
    apt install -y linux-modules-extra-6.8.0-5-generic
fi

grep -E "GRUB_CMDLINE_LINUX.*=.*\".*intel_iommu( )*=( )*on.*\"" /etc/default/grub &> /dev/null
if [ $? -ne 0 ]; then
  sed -i -E "s/GRUB_CMDLINE_LINUX=\"(.*)\"/GRUB_CMDLINE_LINUX=\"\1 intel_iommu=on\"/g" /etc/default/grub
  update-grub
  grub-install
fi

grep -E "GRUB_CMDLINE_LINUX.*=.*\".*iommu( )*=( )*pt.*\"" /etc/default/grub &> /dev/null
if [ $? -ne 0 ]; then
  sed -i -E "s/GRUB_CMDLINE_LINUX=\"(.*)\"/GRUB_CMDLINE_LINUX=\"\1 iommu=pt\"/g" /etc/default/grub
  update-grub
  grub-install
fi

# PPA
add-apt-repository -y ppa:kobuk-team/qat-ubuntu

# List QAT physical devices
# 
#lspci -d :4940 -k

# install qat
# qatlib-service (qat service) is mandatory to initialize the VFs
apt install --yes qatengine qatlib-examples qatlib-service qatzip

# qat service must always be running to enable the VFs
#systemctl restart qat

# list VFs (virtual functions)
#lspci -d :4941 -k

# check qatengine
#openssl engine -t -c -v qatengine

# QAT engine algorithms
#

# run qatengine
# openssl speed -elapsed -async_jobs 72 rsa2048
# openssl speed -engine qatengine -elapsed -async_jobs 72 rsa2048
# openssl speed -elapsed -async_jobs 72 ecdhx25519
# openssl speed -elapsed -engine qatengine -elapsed ecdhx25519


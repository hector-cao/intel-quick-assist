#!/bin/bash

set -e
set -x

# Install the 6.8 kernel
UNAME_R=$(uname -r)
if [[ $UNAME_R != 6.8* ]]; then
    apt-add-repository ppa:canonical-kernel-team/ubuntu/unstable                                                 
    # install kernel
    apt install -y linux-image-6.8.0-5-generic
    ### qat drivers are in modules-extra
    apt install -y linux-modules-extra-6.8.0-5-generic
    reboot
fi

# PPA
add-apt-repository -y ppa:kobuk-team/qat-ubuntu

# List QAT physical devices
# 
lspci -d :4940 -k

# qatlib
apt install --yes qatengine qatlib-examples

# qatengine

# check qatengine
openssl engine -t -c -v qatengine

# QAT engine algorithms
#

# run qatengine
openssl speed -elapsed -async_jobs 72 rsa2048
openssl speed -engine qatengine -elapsed -async_jobs 72 rsa2048

openssl speed -elapsed -async_jobs 72 ecdhx25519
openssl speed -elapsed -engine qatengine -elapsed ecdhx25519


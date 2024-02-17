#!/bin/bash

# PPA
add-apt-repository -y ppa:kobuk-team/qat-ubuntu

# qatlib
apt install --yes qatengine qatlib-examples

# list VFs (virtual functions)
lspci -d :4941 -k


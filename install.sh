#!/bin/bash

#set -x

# Install the 6.8 kernel
KERNEL_VERSION=6.8.0-20-generic

# grub: switch to kernel version
grub_switch_kernel() {
    KERNELVER=$1
    MID=$(awk '/Advanced options for Ubuntu/{print $(NF-1)}' /boot/grub/grub.cfg | cut -d\' -f2)
    KID=$(awk "/with Linux $KERNELVER/"'{print $(NF-1)}' /boot/grub/grub.cfg | cut -d\' -f2 | head -n1)
    cat > /etc/default/grub.d/99-tdx-kernel.cfg <<EOF
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
EOF
    grub-editenv /boot/grub/grubenv set saved_entry="${MID}>${KID}"
    update-grub
}

# FROM unstable
# UNAME_R=$(uname -r)
# if [[ $UNAME_R != 6.8* ]]; then
#     apt-add-repository -y ppa:canonical-kernel-team/ubuntu/unstable
# fi

# From Proposed bucket
cat <<EOF >/etc/apt/sources.list.d/ubuntu-$(lsb_release -cs)-proposed.list
# Enable Ubuntu proposed archive
deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-proposed restricted main multiverse universe
EOF

# install kernel
apt install -y linux-image-${KERNEL_VERSION}
### qat drivers are in modules-extra
apt install -y linux-modules-extra-${KERNEL_VERSION}

grub_switch_kernel ${KERNEL_VERSION}

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
#add-apt-repository -y ppa:kobuk-team/qat-ubuntu

# List QAT physical devices
# 
#lspci -d :4940 -k

# install qat
# qatlib-service (qat service) is mandatory to initialize the VFs
apt install --yes qatengine qatlib-examples qatlib-service qatzip

# check components
echo "==============================="
apt list libqat4 \
    qatlib-examples \
    qatzip \
    libqatzip3 \
    libcrypto-mb11 \
    qatlib-service \
    qatengine \
    libippcp11 \
    libusdm0
echo "==============================="

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


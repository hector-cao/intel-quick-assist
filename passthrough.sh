#!/bin/bash

WORK_DIR=/tmp/tdxtest-default-8u_nt2o2

mkdir -p $WORK_DIR

sudo rmmod qat_4xxx
sudo modprobe qat_4xxx

sudo modprobe vfio-pci ids=8086:4940

#                   -object tdx-guest,id=tdx -machine q35,kernel_irqchip=split,confidential-guest-support=tdx \
sudo qemu-system-x86_64 -cpu host -smp 16,sockets=1 -accel kvm \
                   -nographic -nodefaults -no-user-config -m 2G -bios /usr/share/ovmf/OVMF.fd \
                   -object tdx-guest,id=tdx -machine q35,kernel_irqchip=split \
                   -drive file=$WORK_DIR/image.qcow2,if=none,id=virtio-disk0 \
                   -device virtio-blk-pci,drive=virtio-disk0 -pidfile $WORK_DIR/qemu.pid \
                   -monitor unix:$WORK_DIR/monitor.sock,server,nowait \
                   -qmp unix:$WORK_DIR/qmp.sock,server=on,wait=off \
                   -device virtio-net-pci,netdev=nic0_td -netdev user,id=nic0_td,hostfwd=tcp::39005-:22 \
                   -D $WORK_DIR/qemu-log.txt \
                   -chardev file,id=c1,path=$WORK_DIR/serial.log,signal=off \
                   -device isa-serial,chardev=c1 -serial stdio \
                   -device vfio-pci,host=70:00.0




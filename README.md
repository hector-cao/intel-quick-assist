# intel-quick-assist

This repository contains scripts to enable QAT for 24.04

To install QAT packages, run

```
$ sudo ./install.sh
```

# VM

have to use install.sh on the guest to install the QAT stack

check:

lspci -kd :4941

08:00.0 Co-processor: Intel Corporation Device 4941 (rev 40)
        Subsystem: Intel Corporation Device 0000
        Kernel driver in use: vfio-pci
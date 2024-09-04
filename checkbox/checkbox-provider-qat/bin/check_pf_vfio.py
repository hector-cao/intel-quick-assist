#!/usr/bin/env python3

import subprocess
import sys

def check_device_vfio(device : str):
    """
    Check if we can enable vfio for the QAT PF device
    """
    # populate the VFIO devices if they have been removed due to previous tests
    # that put the PF in a down state
    subprocess.check_call(f'echo 16 > /sys/bus/pci/devices/0000:{device}/sriov_numvfs', shell=True)
    result = subprocess.run(f'qatctl status --vfio', stdout=subprocess.PIPE, shell=True)
    stdout = result.stdout.decode('utf-8')
    print(stdout)
    assert len(stdout.rstrip()) > 0

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(1)

    device = sys.argv[1]
    check_device_vfio(device)

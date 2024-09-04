#!/usr/bin/env python3

import subprocess
import sys

def check_device_state(device : str):
    subprocess.check_call(f'qatctl --set-state down -d {device}', shell=True)
    subprocess.check_call(f'qatctl --set-state up -d {device}', shell=True)
    result = subprocess.run(f'qatctl --get-state -d {device}', stdout=subprocess.PIPE, shell=True)
    stdout = result.stdout.decode('utf-8')
    assert stdout.rstrip() == 'up'

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(1)

    device = sys.argv[1]
    check_device_state(device)

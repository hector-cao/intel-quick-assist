#!/bin/bash

# run qat checkbox provider locally

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CHECKBOX_DIR=${SCRIPT_DIR}/

install_deps() {
  # install qat-tools
  cd ${SCRIPT_DIR}/lib/qat_tools-1.0.0/
  python3 -m pip install --break-system-packages ./
  cd -
}

# cleanup
rm -rf /var/tmp/checkbox-providers/checkbox-provider-qat/

mkdir -p /var/tmp/checkbox-providers
cp -rf ${CHECKBOX_DIR}/checkbox-provider-qat /var/tmp/checkbox-providers/

umount /snap/checkbox-qat-classic/current/lib/python3.12/site-packages/qat_tools/ || true
mount --bind ${SCRIPT_DIR}/lib/qat_tools-1.0.0/src/qat_tools/ /snap/checkbox-qat-classic/current/lib/python3.12/site-packages/qat_tools/

checkbox-qat-classic.test-runner-automated

umount /snap/checkbox-qat-classic/current/lib/python3.12/site-packages/qat_tools/ || true

#!/bin/bash

# Check if a VM name was provided as an argument
if [[ -z $1 ]]; then
  echo "Usage: ./delete_instance.sh <VM_NAME>"
  exit 1
fi

VM_NAME="$1"

# Check if the VM is running and shut it down if so
if virsh domstate ${VM_NAME} | grep -q running; then
  echo "Shutting down VM ${VM_NAME}..."
  virsh shutdown ${VM_NAME} 
fi

# Force-delete the VM definition
echo "Deleting VM ${VM_NAME}..."
virsh undefine ${VM_NAME} 

RM_DISK_IMAGE=true
if [[ $RM_DISK_IMAGE == true ]]; then
  DISK_PATH="/var/lib/libvirt/images/$VM_NAME.qcow2"
  rm ${DISK_PATH}
fi

#!/bin/bash

# Check if a VM name was provided
if [[ -z $1 ]]; then
  echo "Usage: ./get-instance-ip.sh <VM_NAME>"
  exit 1
fi

VM_NAME="$1"
MAX_RETRIES=10
DELAY=5 

for ((i=1; i<=MAX_RETRIES; i++)); do
  IP_ADDRESS=$(virsh net-dhcp-leases default | grep ${VM_NAME} | awk '{print $5}' | cut -d '/' -f 1)
  if [[ -z $IP_ADDRESS ]]; then
    echo "Waiting for IP assignment (attempt $i/$MAX_RETRIES)..."
    sleep $DELAY
  else
    echo "${IP_ADDRESS}"
    exit 0
  fi
done

echo "Error: Could not get IP for ${VM_NAME}"
exit 1 

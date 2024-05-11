#!/bin/bash

# Function to perform cleanup
cleanup() {
    echo "Performing cleanup..."
    rm -f user-data meta-data
    echo "Cleanup complete."
}

# Trap Ctrl+C and call cleanup function
trap cleanup EXIT

# Check if a VM name was provided as an argument
if [[ -z $1 ]]; then
  echo "Usage: ./clone_and_connect.sh <NEW_VM_NAME>"
  exit 1
fi

# wget https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2
# wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img

# VM Settings
BASE_VM_NAME="Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
# BASE_VM_NAME="jammy-server-cloudimg-amd64-disk-kvm.img"
#virt-0
NEW_VM_NAME="$1"
VM_DISK_PATH="/var/lib/libvirt/images/${NEW_VM_NAME}.qcow2"
BASE_VM_PATH="/var/lib/libvirt/images/${BASE_VM_NAME}"
SSH_KEY_PATH="/home/alexander/.ssh/er87"
DOMAIN=".localhost"

# Copy base image
cp ${BASE_VM_PATH} ${VM_DISK_PATH}

cat > user-data << EOF
#cloud-config

ssh_pwauth: false
disable_root: true

users:
  - name: user
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ThVCbVXyVMld82CV5UC8Y8JYpRfuGBWKY+QBc9LTK
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
EOF

cat user-data

cat > meta-data << EOF
instance-id: ${NEW_VM_NAME}
local-hostname: ${NEW_VM_NAME}
hostname: ${NEW_VM_NAME}.${DOMAIN}
public-keys:

EOF

cat meta-data

# Clone the base VM
virt-install \
  --name ${NEW_VM_NAME} \
  --memory 4048 \
  --vcpus 4 \
  --graphics none \
  --os-variant detect=on,name=fedora-unknown \
  --disk=size=10,backing_store=${VM_DISK_PATH} \
  --graphics none \
  --console pty,target_type=virtio \
  --serial pty \
  --cloud-init user-data=user-data,meta-data=meta-data --noautoconsole

# Start the new VM
#virsh start ${NEW_VM_NAME}

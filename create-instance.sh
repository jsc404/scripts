#!/bin/bash

# Function to perform cleanup
cleanup() {
    echo "Performing cleanup..."
    rm -f user-data meta-data
    echo "Cleanup complete."
}

# Trap Ctrl+C
trap cleanup EXIT

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <NEW_VM_NAME>"
    exit 1
fi
NEW_VM_NAME="$1"

# ----- VM Settings -----
BASE_VM_NAME="jammy-server-cloudimg-amd64-disk-kvm.img" 
BASE_VM_PATH="/var/lib/libvirt/images/$BASE_VM_NAME"
VM_DISK_PATH="/var/lib/libvirt/images/$NEW_VM_NAME.qcow2"
DOMAIN="localhost"

echo "Check if Base Image Exists at $BASE_VM_PATH"
if [[ ! -f "$BASE_VM_PATH" ]]; then
    echo "Error: Base image not found at $BASE_VM_PATH"
    exit 1
fi

echo "Copying base image..."
cp "$BASE_VM_PATH" "$VM_DISK_PATH"

echo "Create user-data and meta-data"
cat << EOF > user-data
#cloud-config

ssh_pwauth: false
disable_root: true

users:
  - name: naro
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ThVCbVXyVMld82CV5UC8Y8JYpRfuGBWKY+QBc9LTK
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
EOF

cat << EOF > meta-data
instance-id: $NEW_VM_NAME
local-hostname: $NEW_VM_NAME
hostname: $NEW_VM_NAME.$DOMAIN
public-keys:
EOF

echo "Creating VM $NEW_VM_NAME..."
virt-install \
    --name "$NEW_VM_NAME" \
    --memory 4048 \
    --vcpus 4 \
    --graphics none \
    --os-variant detect=on,name=ubuntufocal \
    --network network=default,model=virtio \
    --disk size=15,backing_store="$BASE_VM_PATH" \
    --console pty \
    --serial pty \
    --cloud-init user-data=user-data,meta-data=meta-data 

echo "VM creation completed. Connect via SSH:"
echo "ssh naro@$NEW_VM_NAME.$DOMAIN"

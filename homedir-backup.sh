#!/bin/bash

# Check if source and destination directories are provided as arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

SOURCE_DIR="$1"
DESTINATION_DIR="$2"

# Define directories to exclude
EXCLUDE_DIRS=(
    '.cache'
    '.mozilla'
    '.thunderbird'
    '.local/share/Trash'
    '.docker'
    '.config/Code/Cache'
    '.config/code'
    '.vscode'
    '.config/google-chrome'
    'go'
    'terraform'
    '.config/BraveSoftware/Brave-Browser'
    '/var/lib/docker'
)

# Construct the exclude options
EXCLUDE_OPTS=""
for dir in "${EXCLUDE_DIRS[@]}"; do
    EXCLUDE_OPTS+="--exclude='$dir' "
done

# Perform the rsync operation
rsync -avzh --progress $EXCLUDE_OPTS "$SOURCE_DIR" "$DESTINATION_DIR"

echo "Backup completed!"

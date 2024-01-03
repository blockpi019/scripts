#!/bin/bash
set -euo pipefail

# Define variables
hypernode_service="hypernode-arbitrum.service"
node_client_service="arbitrum-archive.service"
node_client_dir="/node/archive/arbitrum/bin/nitro"
node_data_dir="/node/archive/arbitrum/bin/"
software_url="http://file.204001.xyz/blockpi/software/arbitrum/nitro"
# whether change service, if so, please change the statement on "if [ $is_change_service -eq 1 ]; then" below
is_change_service=1
# Generate a random sleep duration that is a multiple of 60, between 0 and 300 seconds
#random_sleep=$(( (RANDOM % 6) * 60 ))
random_sleep=0

echo "Sleeping for a random duration: $random_sleep seconds before stopping services..."
sleep $random_sleep

echo "Stopping $hypernode_service..."
systemctl stop $hypernode_service || { echo "Failed to stop $hypernode_service"; exit 1; }
sleep 60

echo "Stopping $node_client_service..."
systemctl stop $node_client_service || { echo "Failed to stop $node_client_service"; exit 1; }

if [ $is_change_service -eq 1 ]; then
    sudo sed -i 's/--node\./--execution\./g' /etc/systemd/system/arbitrum-archive.service
    systemctl daemon-reload
else
    echo "Do not change service file"
fi

# Check if $node_client_dir exists and move it if it does
if [ -e "$node_client_dir" ]; then
    echo "$node_client_dir exists. Moving the file..."
    mv "${node_client_dir}" "${node_data_dir}nitro-old" || { echo "Failed to move nitro binary"; exit 1; }
else
    echo "$node_client_dir does not exist. Skipping the move operation."
fi

echo "Downloading new nitro binary..."
aria2c -s 16 -x 16 -q -d $node_data_dir -o nitro $software_url || { echo "Failed to download nitro binary"; exit 1; }

echo "Making nitro binary executable..."
chmod +x ${node_client_dir} || { echo "Failed to make nitro binary executable"; exit 1; }

echo "Checking nitro version..."
${node_client_dir} version || { echo "Nitro version check failed"; exit 1; }

echo "Starting $node_client_service..."
systemctl start $node_client_service || { echo "Failed to start $node_client_service"; exit 1; }
sleep 60

echo "Starting $hypernode_service..."
systemctl start $hypernode_service || { echo "Failed to start $hypernode_service"; exit 1; }

echo "All steps completed successfully."

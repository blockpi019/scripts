#!/bin/bash
set -euo pipefail

# Define variables
hypernode_service="hypernode-arbitrum.service"
node_client_service="arbitrum-archive.service"
node_client_dir="/node/archive/arbitrum/bin/nitro"
node_data_dir="/node/archive/arbitrum/bin/"
software_url="http://file.204001.xyz/blockpi/software/arbitrum/nitro"

# Generate a random sleep duration that is a multiple of 60, between 0 and 300 seconds
random_sleep=$(( (RANDOM % 6) * 60 ))

echo "Sleeping for a random duration: $random_sleep seconds before stopping services..."
sleep $random_sleep

echo "Stopping $hypernode_service..."
systemctl stop $hypernode_service || { echo "Failed to stop $hypernode_service"; exit 1; }
sleep 60

echo "Stopping $node_client_service..."
systemctl stop $node_client_service || { echo "Failed to stop $node_client_service"; exit 1; }

echo "Moving old nitro binary..."
mv ${node_client_dir} ${node_data_dir}nitro-old || { echo "Failed to move nitro binary"; exit 1; }

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


#### draft ######
#!/bin/bash
set -euo pipefail

# Generate a random sleep duration that is a multiple of 120, between 0 and 600 seconds
random_sleep=$(( (RANDOM % 6) * 120 ))

echo "Sleeping for a random duration: $random_sleep seconds before stopping services..."
sleep $random_sleep

echo "Stopping hypernode-arbitrum service..."
systemctl stop hypernode-arbitrum.service || { echo "Failed to stop hypernode-arbitrum service"; exit 1; }
sleep 60

echo "Stopping arbitrum-archive service..."
systemctl stop arbitrum-archive.service || { echo "Failed to stop arbitrum-archive service"; exit 1; }
sleep 60

echo "Moving old nitro binary..."
mv /node/archive/arbitrum/bin/nitro /node/archive/arbitrum/bin/nitro-old || { echo "Failed to move nitro binary"; exit 1; }

echo "Downloading new nitro binary..."
aria2c -s 16 -x 16 -q -d /node/archive/arbitrum/bin/ -o nitro http://bweb.131810.xyz/blockpi/software/arbitrum/nitro || { echo "Failed to download nitro binary"; exit 1; }

echo "Making nitro binary executable..."
chmod +x /node/archive/arbitrum/bin/nitro || { echo "Failed to make nitro binary executable"; exit 1; }

echo "Checking nitro version..."
/node/archive/arbitrum/bin/nitro version || { echo "Nitro version check failed"; exit 1; }

echo "Starting arbitrum-archive service..."
systemctl start arbitrum-archive.service || { echo "Failed to start arbitrum-archive service"; exit 1; }
sleep 60

echo "Starting hypernode-arbitrum service..."
systemctl start hypernode-arbitrum.service || { echo "Failed to start hypernode-arbitrum service"; exit 1; }

echo "All steps completed successfully."


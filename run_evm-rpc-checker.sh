#!/bin/bash

if [ ! -f /root/evm-rpc-checker-linux ]; then
    wget -q "http://file.204001.xyz/blockpi/software/evm-rpc-checker-linux" -O /root/evm-rpc-checker-linux
    chmod +x /root/evm-rpc-checker-linux
else
    echo "/root/evm-rpc-checker-linux existed"
fi

cat /dev/null > /root/check_evp_rpc_host.log
rpc_list=("127.0.0.1:21291" "127.0.0.1:21301" "127.0.0.1:31301" "127.0.0.1:21101")
for rpc in "${rpc_list[@]}"
do
    height=$(curl -Ls -X POST "http://$rpc" -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r .result)
    if [ ! -z $height ]; then
		echo "start check $rpc"
		echo "block height: $height_dec"
		/root/evm-rpc-checker-linux --url "http://$rpc" --check-tx-receipt
        #>> /root/check_evp_rpc_host.log
		tail -n 9 /root/check_evp_rpc_host.log
		echo "successful check $rpc"
    else
        echo "Skipping $rpc because it did not return a valid height"
    fi
done

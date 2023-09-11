#!/bin/bash

wget -q "https://filebrower.204001.xyz/api/raw/blockpi/software/evm-rpc-checker-linux?auth=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoyLCJsb2NhbGUiOiJ6aC1jbiIsInZpZXdNb2RlIjoibGlzdCIsInNpbmdsZUNsaWNrIjpmYWxzZSwicGVybSI6eyJhZG1pbiI6ZmFsc2UsImV4ZWN1dGUiOnRydWUsImNyZWF0ZSI6dHJ1ZSwicmVuYW1lIjp0cnVlLCJtb2RpZnkiOnRydWUsImRlbGV0ZSI6dHJ1ZSwic2hhcmUiOmZhbHNlLCJkb3dubG9hZCI6dHJ1ZX0sImNvbW1hbmRzIjpbXSwibG9ja1Bhc3N3b3JkIjp0cnVlLCJoaWRlRG90ZmlsZXMiOmZhbHNlLCJkYXRlRm9ybWF0IjpmYWxzZX0sImlzcyI6IkZpbGUgQnJvd3NlciIsImV4cCI6MTY5NDQ1MTIyMSwiaWF0IjoxNjk0NDQ0MDIxfQ.9l4Rif0l9BDYcTnaVnpOYQU-_DG5erZJSaYMxa5Jo94&" -O /root/evm-rpc-checker-linux
chmod +x /root/evm-rpc-checker-linux

cat /dev/null > /root/check_evp_rpc_host.log
rpc_list=("127.0.0.1:21291" "127.0.0.1:21301" "127.0.0.1:31301" "127.0.0.1:21101")
for rpc in "${rpc_list[@]}"
do
    height=$(curl -Ls -X POST "http://$rpc" -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r .result)
    height_dec=$(echo "ibase=16;obase=10;${height#0x}" | bc)
    if [ ! -z $height ]; then
		if [[ $height_dec > 0 ]]; then
			echo "start check $rpc"
			echo "block height: $height_dec"
			/root/evm-rpc-checker-linux --url "$rpc" --check-tx-receipt >> /root/check_evp_rpc_host.log
			cat /root/check_evp_rpc_host.log
			echo "successful check $rpc"
		fi
    else
        echo "Skipping $rpc because it did not return a valid height"
    fi
done

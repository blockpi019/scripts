#!/bin/bash
nodeServiceName=bsc-archive
# 检测服务是否同步完成 因链改动

est_time=0
old_dHeight=0
total_run_time=0
interval_time=10
base_speed=0.00

get_block_height() {
    globalHeight=$(curl -s -X POST 'https://bsc-dataseed1.binance.org' -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r ".result" | tr 'a-f' 'A-F')
    LocalHeight=$(curl -Ls -X POST 'http://127.0.0.1:21041' -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r ".result" | tr 'a-f' 'A-F')
}

    get_block_height
    dHeight=$(echo "obase=10; ibase=16; ${globalHeight:2}-${LocalHeight:2}" | bc)
    if [ ${dHeight#-} -gt 50 ]; then
        systemctl restart bsc-archive.service
        printf "restart %s.service success! \n" $nodeServiceName
    else
        printf "Don't need restart %s.service success! \n" $nodeServiceName
    fi

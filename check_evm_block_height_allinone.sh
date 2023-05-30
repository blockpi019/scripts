#!/bin/bash
nodeServiceName=eth
# 检测服务是否同步完成 因链改动

est_time=0
old_dHeight=0
total_run_time=0
interval_time=10
base_speed=0.00

get_block_height() {
    case "${1}" in
        "eth") chain_name="ethereum" node_port=31301
        ;;
        "bsc") chain_name="bsc" node_port=31041
        ;;
    esac

    globalHeight=$(curl -s -X POST 'https://$chain_name.blockpi.network/v1/rpc/0cb922caf1e980040cbecca069e07c542d8fa373' -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r ".result" | tr 'a-f' 'A-F')
    LocalHeight=$(curl -Ls -X POST 'http://127.0.0.1:$node_port' -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r ".result" | tr 'a-f' 'A-F')
}

while true
do

    get_block_height
    if [ -z $LocalHeight ]; then
        printf "项目名称：%s " ${nodeServiceName}
        printf "本地同步未开始，请等待 \n"
    else
        dHeight=$(echo "obase=10; ibase=16; ${globalHeight:2}-${LocalHeight:2}" | bc)
        old_dHeight=$dHeight
        break
    fi

    sleep 1

done

while true
do

    printf "项目名称：%s " ${nodeServiceName}
    if [ $total_run_time -ne 0 ]; then
        if [ $old_dHeight -gt $dHeight ]; then
            sync_speed=$(echo "scale=2; ((($old_dHeight - $dHeight) / $total_run_time)-$base_speed)" | bc)        
            est_time=$(echo "($dHeight / $sync_speed)/1" | bc)
            est_time_hours=$(echo "($est_time/3600)" | bc)
            est_time_minutes=$(echo "($est_time%3600)/60" | bc)
            est_time_seconds=$(echo "($est_time%3600)%60" | bc)
            printf "相差高度：%d " $dHeight
            printf "同步速度：%5.2f blocks/s " $sync_speed
            printf "剩余时间：%02d:%02d:%02d \n" $est_time_hours $est_time_minutes $est_time_seconds
        else
            printf "相差高度：%d 同步速度太慢！ \n" $dHeight
        fi

    else
        printf "相差高度：%d \n" $dHeight
    fi

    # 判断高度是否小于特定值
    if [ ${dHeight#-} -lt 5 ]; then
        break
    fi

    get_block_height
    dHeight=$(echo "obase=10; ibase=16; ${globalHeight:2}-${LocalHeight:2}" | bc)

    total_run_time=$(echo "$total_run_time+$interval_time" | bc)

    sleep $interval_time

done

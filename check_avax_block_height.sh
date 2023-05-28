#!/bin/bash
nodeServiceName=avax
# 检测服务是否同步完成 因链改动

est_time=0
old_dHeight=0
total_run_time=0
interval_time=10
base_speed=0.00

get_block_height() {
    globalHeight=$(curl -s -X POST 'https://avalanche.blockpi.network/v1/rpc/5dc28246d4865c49f42689a98b20832fb1ec81f2' -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r ".result" | tr 'a-f' 'A-F')
    LocalHeight=$(curl -Ls -X POST 'http://127.0.0.1:31411/ext/bc/C/rpc' -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0","method": "eth_blockNumber","params": [],"id": 1}' | jq -r ".result" | tr 'a-f' 'A-F')
}

#检查avax引导是否完成
while true
do
    if [[ $(curl -s -X POST --data '{"jsonrpc":"2.0","id" :1,"method" :"info.isBootstrapped","params": { "chain":"X" }}' -H 'content-type:application/json' 127.0.0.1:31411/ext/info | jq .result.isBootstrapped) == "true" ]]; then
        break
    else
        str_record=$( journalctl -n 5 -u ${nodeServiceName}.service | tail -n 5 )
        if [[ $str_record =~ No\ entries ]]; then
            printf "项目名称：%s ERROR: 服务未成功运行 \n" ${nodeServiceName}
        else
            if [[ $str_record =~ executing\ operations && $str_record =~ \"eta\" ]]; then
                eta=$( journalctl -n 5 -u ${nodeServiceName}.service | grep "executing\ operations" | grep -o '\{.*\}' | tail -n 1 | jq -r .eta )
                printf "项目名称：%s " ${nodeServiceName}
                printf "正在建立引导中，阶段: executing operations 剩余时间：%s \n" $eta
            elif [[ $str_record =~ fetching\ blocks && $str_record =~ \"eta\" ]]; then
                eta=$( journalctl -n 5 -u ${nodeServiceName}.service | grep "fetching\ blocks" | grep -o '\{.*\}' | tail -n 1 | jq -r .eta )
                printf "项目名称：%s " ${nodeServiceName}
                printf "正在建立引导中，阶段: fetching blocks 剩余时间：%s \n" $eta
            fi
        fi
    fi

    sleep 10
done

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
#!/usr/bin/env bash

PID_LIST=()

sudo -E ./NFs/upf/build/bin/free5gc-upfd -c ./config/upfcfg.yaml -l ./log/nf/upf.log -g ./log/free5gc.log &
PID_LIST+=($!)

sleep 1

NF_LIST="nrf amf smf udr pcf udm nssf ausf"
OP_LIST="nef af"

export GIN_MODE=release

for NF in ${NF_LIST}; do
    ./bin/${NF} &
    PID_LIST+=($!)
    sleep 0.1
done

for OP in ${OP_LIST}; do
    ./epcforedge/ngc/dist/${OP} &
    PID_LIST+=($!)
    sleep 0.1
done

#sudo ./bin/n3iwf &
#SUDO_N3IWF_PID=$!
#sleep 1
#N3IWF_PID=$(pgrep -P $SUDO_N3IWF_PID)
#PID_LIST+=($SUDO_N3IWF_PID $N3IWF_PID)

function terminate()
{
    sudo kill -SIGTERM ${PID_LIST[${#PID_LIST[@]}-2]} ${PID_LIST[${#PID_LIST[@]}-1]}
    sleep 2
}

trap terminate SIGINT
wait ${PID_LIST}

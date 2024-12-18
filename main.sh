#!/bin/sh

echo Running bash script in github

#export CHAIN_ID=namada.5f5de2dd1b88cba30586420
#export NAMADA_NETWORK_CONFIGS_SERVER="https://github.com/anoma/namada-mainnet-genesis/releases/download/mainnet-genesis"
#namada --version
#echo "Joining Namada Network"
#namadac utils join-network --chain-id $CHAIN_ID

export VALIDATOR_ADDRESS=tnam1qyvc8n7ufmpan4yy3nemm3td2c6uff4m6s72g3eg


echo "fetching the validator commission"
COMMISSION=$(curl -s https://api.namada.valopers.com/account/$VALIDATOR_ADDRESS/commission | jq -r .amount)

DETAILS=$(curl -s https://api.namada.valopers.com/validators/details/$VALIDATOR_ADDRESS)
STAKE=$(echo $DETAILS | jq -r .stake)
COMMISSION_RATE=$(echo $DETAILS | jq -r .commission.commission_rate)

METRIC_FILE=metrics/metrics.txt

start_time=$(date +%s)
echo $start_time > metrics/last_run.txt



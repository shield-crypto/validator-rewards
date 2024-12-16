#!/bin/sh

echo Running bash script in github

export CHAIN_ID=namada.5f5de2dd1b88cba30586420
export NAMADA_NETWORK_CONFIGS_SERVER="https://github.com/anoma/namada-mainnet-genesis/releases/download/mainnet-genesis"


namada --version

echo "Joining Namada Network"
namadac utils join-network --chain-id $CHAIN_ID

echo "fetching the validator balance"

namadac balance --token NAM --owner tnam1qyvc8n7ufmpan4yy3nemm3td2c6uff4m6s72g3eg --node https://namada-public-rpc.shield-crypto.com
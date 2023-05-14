#!/bin/sh

NODE_URL=${1:-http://localhost:26659}
VALIDATOR_NAME=validator1
CHAIN_ID=blog
KEY_NAME=blog-key
KEY_2_NAME=blog-key-2
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000stake"
STAKING_AMOUNT="1000000000stake"

NAMESPACE_ID=$(openssl rand -hex 8)
echo $NAMESPACE_ID
DA_BLOCK_HEIGHT=$(curl https://rpc-blockspacerace.pops.one/block | jq -r '.result.block.header.height')
echo $DA_BLOCK_HEIGHT

ignite chain build
blogd tendermint unsafe-reset-all
blogd init $VALIDATOR_NAME --chain-id $CHAIN_ID

blogd keys add $KEY_NAME --keyring-backend test
blogd keys add $KEY_2_NAME --keyring-backend test
blogd add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test
blogd add-genesis-account $KEY_2_NAME $TOKEN_AMOUNT --keyring-backend test
blogd gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test
blogd collect-gentxs
blogd start --rollkit.aggregator true --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"'$NODE_URL'","timeout":60000000000,"gas_limit":6000000,"fee":6000}' --rollkit.namespace_id $NAMESPACE_ID --rollkit.da_start_height $DA_BLOCK_HEIGHT


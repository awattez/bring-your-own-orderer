#!/bin/sh

set -e

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}

read -p "Press [Enter] key to continue..."
docker exec cli-org2 sh -c 'peer channel fetch 0 ${CHANNEL_NAME}_genesis.block -o $ORDERER --tls --cafile $ORDERER_CA_TLS_CERT -c $CHANNEL_NAME'

read -p "Press [Enter] key to continue..."
docker exec cli-org2 sh -c 'peer channel join -b ${CHANNEL_NAME}_genesis.block'

echo "Installing chaincode.."
read -p "Press [Enter] key to continue..."
docker exec cli-org2 peer chaincode install -n chaincode1 -p github.com/chaincode1 -v 1

echo "Sleeping for 8 seconds before continuing .."
sleep 8
read -p "Press [Enter] key to continue..."
docker exec cli-org2 sh -c 'peer chaincode query -C $CHANNEL_NAME -n chaincode1 -c "{\"Args\":[\"query\",\"v\"]}"'

sleep 2
read -p "Press [Enter] key to continue..."
docker exec cli-org2 sh -c 'peer chaincode invoke -C $CHANNEL_NAME -n chaincode1 -c "{\"Args\":[\"put\",\"x\", \"711\"]}" -o $ORDERER --tls --cafile $ORDERER_CA_TLS_CERT'

sleep 2
read -p "Press [Enter] key to continue..."
docker exec cli-org2 sh -c 'peer chaincode query -C $CHANNEL_NAME -n chaincode1 -c "{\"Args\":[\"query\",\"x\"]}"'



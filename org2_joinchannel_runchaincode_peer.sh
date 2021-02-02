#!/bin/sh -ex


export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}

read -p "Press [Enter] key to continue..."
docker exec peer0.org2.example.com sh -c 'peer channel fetch 0 channel1_genesis.block -o orderer0.org2.example.com:7050 --tls --cafile /etc/hyperledger/fabric/tls/ca.crt -c channel1'

read -p "Press [Enter] key to continue..."
docker exec peer0.org2.example.com sh -c 'peer channel join -b channel1_genesis.block'

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



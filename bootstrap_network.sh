#!/bin/sh

set -e

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=channel1
MSP_NAME=Org1MSP

mkdir -p config
rm -rf config/*.tx
rm -rf config/*.block

# generate genesis block for system channel
configtxgen -profile OrdererGenesis -outputBlock ./config/genesis.block -channelID system-channel
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

docker-compose up -d orderer0.org1.example.com orderer1.org1.example.com peer0.org1.example.com cli-org1 cli-org2
echo "Sleep for 30 seconds for components to start up.."
sleep 30
echo "Done"

# generate channel configuration transaction
configtxgen -profile Channel -outputCreateChannelTx ./config/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile Channel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

echo "Creating channel $CHANNEL_NAME as $MSP_NAME.."
docker exec cli-org1 sh -c 'peer channel create -o $ORDERER -c $CHANNEL_NAME --tls --cafile $ORDERER_CA_TLS_CERT -f /config/${CHANNEL_NAME}.tx'

# Join peer0.org1.example.com to the channel
docker exec cli-org1 sh -c 'peer channel join -b ${CHANNEL_NAME}.block'

# Updating anchor peers for org1
docker exec cli-org1 sh -c 'peer channel update -o $ORDERER -c $CHANNEL_NAME --tls --cafile $ORDERER_CA_TLS_CERT -f /config/Org1MSPanchors.tx'

docker exec cli-org1 peer chaincode install -n chaincode1 -p github.com/chaincode1 -v 1

docker exec cli-org1 sh -c 'peer chaincode instantiate -o $ORDERER -C $CHANNEL_NAME --tls --cafile $ORDERER_CA_TLS_CERT -n chaincode1 -l golang -v 1 -c "{\"Args\":[\"init\",\"a\",\"81\",\"b\",\"11\"]}" -P "OR(\"Org1MSP.member\",\"Org2MSP.member\")"'

sleep 6
docker exec cli-org1 sh -c 'peer chaincode invoke -C $CHANNEL_NAME -n chaincode1 -c "{\"Args\":[\"put\",\"v\", \"833\"]}" -o $ORDERER --tls --cafile $ORDERER_CA_TLS_CERT'

sleep 3
docker exec cli-org1 sh -c 'peer chaincode query -C $CHANNEL_NAME -n chaincode1 -c "{\"Args\":[\"query\",\"v\"]}"'


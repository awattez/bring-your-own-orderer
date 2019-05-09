#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

set -e
source utils.sh

if [ "$1" == "" ]; then
    echo "Usage: ./add_org2_orderer_to_consenter_list system-channel | channel1"
    exit 1
else
    CHANNEL=$1
fi

WORKING_DIR=/downloads/${CHANNEL}_step3

echo "Create $WORKING_DIR folder.."
docker exec cli-org1 mkdir -p $WORKING_DIR

export FLAG=$(if [ "$(uname -s)" == "Linux" ]; then echo "-w 0"; else echo "-b 0"; fi)
TLS_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/orderers/orderer0.org2.example.com/tls/server.crt
echo "{\"client_tls_cert\":\"$(cat $TLS_FILE | base64 $FLAG)\",\"host\":\"orderer0.org2.example.com\",\"port\":7050,\"server_tls_cert\":\"$(cat $TLS_FILE | base64 $FLAG)\"}" > $PWD/$WORKING_DIR/org2consenter.json

retrieve_current_config $WORKING_DIR $CHANNEL cli-org1

echo "Add orderer0.org2.example.com to list of Consenters and prepare protobuf update.."
docker exec -e "WORKING_DIR=$WORKING_DIR" cli-org1 sh -c 'jq ".channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [$(cat $WORKING_DIR/org2consenter.json)]" $WORKING_DIR/current_config.json > $WORKING_DIR/modified_config.json'

prepare_unsigned_modified_config $WORKING_DIR $CHANNEL cli-org1

echo "Org2MSP signs update.."
docker exec -e "WORKING_DIR=$WORKING_DIR" cli-org2 sh -c 'peer channel signconfigtx -f $WORKING_DIR/config_update_in_envelope.pb'

echo "Org1MSP signs and sends update.."
docker exec -e "WORKING_DIR=$WORKING_DIR" -e "CHANNEL=$CHANNEL" cli-org1 sh -c 'peer channel update -f $WORKING_DIR/config_update_in_envelope.pb -o $ORDERER --tls --cafile $ORDERER_CA_TLS_CERT -c $CHANNEL'

retrieve_updated_config $WORKING_DIR $CHANNEL cli-org1

echo "Done!!"



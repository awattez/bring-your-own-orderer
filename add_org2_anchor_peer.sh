#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

set -e
source utils.sh

if [ "$1" == "" ]; then
    echo "Usage: ./add_org2_anchor_peer channel1"
    exit 1
else
    CHANNEL=$1
fi

WORKING_DIR=/downloads/${CHANNEL}_step5

echo "Create $WORKING_DIR folder.."
docker exec cli-org2 mkdir -p $WORKING_DIR
echo 
echo "{\"mod_policy\": \"Admins\",\"value\": {\"anchor_peers\": [{\"host\": \"peer0.org2.example.com\",\"port\": 7051}]}}" > $PWD/$WORKING_DIR/org2anchorpeer.json

retrieve_current_config $WORKING_DIR $CHANNEL cli-org2

echo "Add peer0.org2.example.com as anchor peer.."
docker exec -e "WORKING_DIR=$WORKING_DIR" cli-org2 sh -c 'jq -s ".[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"groups\": {\"Org2MSP\": {\"values\": {\"AnchorPeers\": .[1]}}}}}}}" $WORKING_DIR/current_config.json $WORKING_DIR/org2anchorpeer.json > $WORKING_DIR/modified_config.json'

prepare_unsigned_modified_config $WORKING_DIR $CHANNEL cli-org2

echo "Org2MSP signs update.."
docker exec -e "WORKING_DIR=$WORKING_DIR" cli-org2 sh -c 'peer channel signconfigtx -f $WORKING_DIR/config_update_in_envelope.pb'

echo "Org1MSP signs and sends update.."
docker exec -e "WORKING_DIR=$WORKING_DIR" -e "CHANNEL=$CHANNEL" cli-org2 sh -c 'peer channel update -f $WORKING_DIR/config_update_in_envelope.pb -o $ORDERER --tls --cafile $ORDERER_CA_TLS_CERT -c $CHANNEL'

retrieve_updated_config $WORKING_DIR $CHANNEL cli-org2

echo "Done!!"
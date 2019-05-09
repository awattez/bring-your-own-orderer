#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

set -e
source utils.sh

if [ "$1" == "" ]; then
    echo "Usage: ./add_org2_to_orderer_channel_group.sh system-channel | channel1"
    exit 1
else
    CHANNEL=$1
fi

WORKING_DIR=/downloads/${CHANNEL}_step1

echo "Create $WORKING_DIR folder.."
docker exec cli-org1 mkdir -p $WORKING_DIR

retrieve_current_config $WORKING_DIR $CHANNEL cli-org1

echo "Add the crypto material of Org2MSP to the Orderer configuration.."
docker exec -e "WORKING_DIR=$WORKING_DIR" cli-org1 sh -c 'jq -s ".[0] * {\"channel_group\":{\"groups\":{\"Orderer\":{\"groups\":{\"Org2MSP\":.[1]}}}}}" $WORKING_DIR/current_config.json /config/org2definition.json > $WORKING_DIR/modified_config.json'

prepare_unsigned_modified_config $WORKING_DIR $CHANNEL cli-org1

echo "Org1MSP signs and sends update.."
docker exec -e "WORKING_DIR=$WORKING_DIR" -e "CHANNEL=$CHANNEL" cli-org1 sh -c 'peer channel update -f $WORKING_DIR/config_update_in_envelope.pb -o $ORDERER --tls --cafile $ORDERER_CA_TLS_CERT -c $CHANNEL'

retrieve_updated_config $WORKING_DIR $CHANNEL cli-org1

echo "Done!!"
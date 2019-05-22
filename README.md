# Bring-Your-Own-Orderer with RAFT

## Environment Setup

1. Download binaries for Hyperledger Fabric v1.4.1

   ```bash
   curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.4.1 -d -s
   rm -f config/configtx.yaml config/core.yaml config/orderer.yaml
   ```

2. Start Org1 CA and generate key and certs for Org1

   ```bash
   ./create_crypto.sh org1
   ```

3. Start Org1 Orderer and Peer, create channel `channel1` and run `chaincode1`;

   ```bash
   ./bootstrap_network.sh
   ```

4. Start Org2 CA and generate key and certs for Org2

   ```bash
   ./create_crypto.sh org2
   ```

## system-channel

1. Add Org2MSP to Orderer Channel Group

   ```bash
   ./add_org2_to_orderer_channel_group.sh system-channel
   ```

2. Add Org2MSP to Consortium Channel Group

   ```bash
   ./add_org2_to_consortium_channel_group.sh system-channel
   ```

3. Add Org2 Orderer to Consenters List

   ```bash
   ./add_org2_orderer_to_consenter_list.sh system-channel
   ```

4. Start Org2 Orderer

   ```bash
   docker-compose up -d orderer0.org2.example.com
   ```

5. Add Org2 Orderer to Orderer address list

   ```bash
   ./add_org2_orderer_address_to_address_list.sh system-channel
   ```

## channel1

1. Add Org2MSP to Orderer Channel Group

   ```bash
   ./add_org2_to_orderer_channel_group.sh channel1
   ```

2. Add Org2MSP to Application Channel Group

   ```bash
   ./add_org2_to_application_channel_group.sh channel1
   ```

3. Add Org2 Orderer to Consenters List

   ```bash
   ./add_org2_orderer_to_consenter_list.sh channel1
   ```

4. Add Org2 Orderer to Orderer address list

   ```bash
   ./add_org2_orderer_address_to_address_list.sh channel1
   ```

## Finishing Up

1. Provision Org2 Peer

   ```bash
   docker-compose up -d peer0.org2.example.com
   ```

2. Set anchor peer for Org2

   ```bash
   ./add_org2_anchor_peer.sh channel1
   ```

3. Join channel and run chaincode

   ```bash
   ./org2_joinchannel_runchaincode.sh
    ```
# Bring-Your-Own-Orderer with RAFT

## Environment Setup

1. Download binaries for Hyperledger Fabric v1.4.1

   ```bash
   curl -sSL https://bit.ly/2ysbOFE | bash -s
   hyperledger/fabric-tools             2.3 
   hyperledger/fabric-tools             2.3.0  
   hyperledger/fabric-tools             latest 
   hyperledger/fabric-peer              2.3    
   hyperledger/fabric-peer              2.3.0  
   hyperledger/fabric-peer              latest 
   hyperledger/fabric-orderer           2.3    
   hyperledger/fabric-orderer           2.3.0  
   hyperledger/fabric-orderer           latest 
   hyperledger/fabric-ccenv             2.3    
   hyperledger/fabric-ccenv             2.3.0  
   hyperledger/fabric-ccenv             latest 
   hyperledger/fabric-baseos            2.3    
   hyperledger/fabric-baseos            2.3.0  
   hyperledger/fabric-baseos            latest 
   hyperledger/fabric-ca                1.4    
   hyperledger/fabric-ca                1.4.9  
   hyperledger/fabric-ca                latest 
   ```
   
   **Clean**
   ```bash
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
> If you try step3 before step1
> `[grpc] InfoDepth -> DEBU 02f [core]Channel Connectivity change to READY
Error: got unexpected status: BAD_REQUEST -- error applying config update to existing channel 'system-channel': consensus metadata update for channel config update is invalid: invalid new config metadata: verifying tls client cert with serial number 251895756776373017740243883290920663310755872594: x509: certificate signed by unknown authority`


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


3. Join channel and run chaincode

   ```bash
   ./org2_joinchannel_runchaincode.sh
    ```
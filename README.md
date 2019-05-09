# Bring-Your-Own-Orderer with RAFT

Download binaries for Hyperledger Fabric v1.4.1

```bash
curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.4.1 -d -s
rm -f config/configtx.yaml config/core.yaml config/orderer.yaml
```

Start Org1 CA and generate key and certs for Org1 (if there is `Error: Response from server: Error Code: 20 - Authentication failure` error, run `./stop.sh` and try again)

```bash
./create_crypto.sh org1
```

Start Org1 Orderer and Peer, create channel `channel1` and run `chaincode1`;

```bash
./bootstrap_network.sh
```

Start Org2 CA and generate key and certs for Org2

```bash
./create_crypto.sh org2
```

```bash
./add_org2_to_orderer_channel_group.sh system-channel
```

```bash
./add_org2_to_consortium_channel_group.sh system-channel
```

```bash
./add_org2_orderer_to_consenter_list.sh system-channel
```

```bash
docker-compose up -d orderer0.org2.example.com
```

```bash
./add_org2_orderer_address_to_address_list.sh system-channel
```

```bash
./add_org2_to_orderer_channel_group.sh channel1
```

```bash
./add_org2_to_application_channel_group.sh channel1
```

```bash
./add_org2_orderer_to_consenter_list.sh channel1
```

```bash
./add_org2_orderer_address_to_address_list.sh channel1
```
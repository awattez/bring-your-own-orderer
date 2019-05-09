# Bring-Your-Own-Orderer with RAFT

```bash
./create_crypto.sh org1
```

```bash
./bootstrap_network.sh
```

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
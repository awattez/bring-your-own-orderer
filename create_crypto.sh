#!/bin/sh -ex


export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}

if [ "$1" == "org1" ]; then
    ORG=org1
    ORG_NAME="org1.example.com"
    PORT=7054
    MSP_NAME=Org1MSP
    DEFINITION_NAME=org1definition
elif [ "$1" == "org2" ]; then
    ORG=org2
    ORG_NAME="org2.example.com"
    PORT=8054
    MSP_NAME=Org2MSP 
    DEFINITION_NAME=org2definition  
else
    echo "Usage: ./create_crypto.sh org1 | org2"
    exit 1
fi

TLS_DIR=$PWD/ca/$ORG_NAME
ORG_DIR=$PWD/crypto-config/peerOrganizations/$ORG_NAME
REGISTRAR_DIR=$ORG_DIR/users/admin
PEER_DIR=$ORG_DIR/peers/peer0.$ORG_NAME
ORDERER0_DIR=$ORG_DIR/orderers/orderer0.$ORG_NAME
ORDERER1_DIR=$ORG_DIR/orderers/orderer1.$ORG_NAME
ADMIN_DIR=$ORG_DIR/users/Admin@$ORG_NAME
CA_NAME=ca

mkdir -p $ORG_DIR/msp $PEER_DIR $PEER_DIR/tls $REGISTRAR_DIR $ORDERER0_DIR $ORDERER0_DIR/tls $ORDERER1_DIR $ORDERER1_DIR/tls $ADMIN_DIR

docker-compose up -d ca.$ORG_NAME
echo "Sleeping for 12s to wait till CA starts.."
sleep 12

read -p "Press [Enter] key to continue..."


export FABRIC_CA_CLIENT_HOME=$REGISTRAR_DIR
echo "Enrolling registrar.."
fabric-ca-client enroll --caname $CA_NAME --csr.names C=SG,ST=Singapore,L=Singapore,O=$ORG_NAME -m admin -u https://admin:adminpw@localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem

read -p "Press [Enter] key to continue..."

echo "Registering Admin@$ORG_NAME.."
fabric-ca-client register --caname $CA_NAME --id.name Admin@$ORG_NAME --id.secret mysecret --id.type admin --id.affiliation $ORG -u https://localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem
echo "Registering peer0.$ORG_NAME.."
fabric-ca-client register --caname $CA_NAME --id.name peer0.$ORG_NAME --id.secret mysecret --id.type peer --id.affiliation $ORG -u https://localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem
echo "Registering orderer0.$ORG_NAME.."
fabric-ca-client register --caname $CA_NAME --id.name orderer0.$ORG_NAME --id.secret mysecret --id.type peer --id.affiliation $ORG -u https://localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem
echo "Registering orderer1.$ORG_NAME.."
fabric-ca-client register --caname $CA_NAME --id.name orderer1.$ORG_NAME --id.secret mysecret --id.type peer --id.affiliation $ORG -u https://localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem

read -p "Press [Enter] key to continue..."

FABRIC_CA_CLIENT_HOME=$ADMIN_DIR
echo "Enrolling Admin@$ORG_NAME.."
fabric-ca-client enroll --caname $CA_NAME --csr.names C=SG,ST=Singapore,L=Singapore,O=$ORG_NAME -m Admin@$ORG_NAME -u https://Admin@$ORG_NAME:mysecret@localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem
mkdir -p $ADMIN_DIR/msp/admincerts && cp $ADMIN_DIR/msp/signcerts/*.pem $ADMIN_DIR/msp/admincerts/

export FABRIC_CA_CLIENT_HOME=$PEER_DIR
echo "Enrolling peer0.$ORG_NAME.."
fabric-ca-client enroll --caname $CA_NAME --csr.names C=SG,ST=Singapore,L=Singapore,O=$ORG_NAME --csr.hosts peer0.$ORG_NAME,localhost -m peer0.$ORG_NAME -u https://peer0.$ORG_NAME:mysecret@localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem
mkdir -p $PEER_DIR/msp/admincerts && cp $ADMIN_DIR/msp/signcerts/*.pem $PEER_DIR/msp/admincerts/

echo "TLS peer0.$ORG_NAME.."
cp $PEER_DIR/msp/cacerts/*.pem $PEER_DIR/tls/ca.crt
cp $PEER_DIR/msp/keystore/* $PEER_DIR/tls/server.key
cp $PEER_DIR/msp/signcerts/*.pem $PEER_DIR/tls/server.crt

export FABRIC_CA_CLIENT_HOME=$ORDERER0_DIR
echo "Enrolling orderer0.$ORG_NAME.."
fabric-ca-client enroll --caname $CA_NAME --csr.names C=SG,ST=Singapore,L=Singapore,O=$ORG_NAME --csr.hosts orderer0.$ORG_NAME,localhost -m orderer0.$ORG_NAME -u https://orderer0.$ORG_NAME:mysecret@localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem
mkdir -p $ORDERER0_DIR/msp/admincerts && cp $ADMIN_DIR/msp/signcerts/*.pem $ORDERER0_DIR/msp/admincerts/

echo "TLS orderer0.$ORG_NAME.."
cp $ORDERER0_DIR/msp/cacerts/*.pem $ORDERER0_DIR/tls/ca.crt
cp $ORDERER0_DIR/msp/keystore/* $ORDERER0_DIR/tls/server.key
cp $ORDERER0_DIR/msp/signcerts/*.pem $ORDERER0_DIR/tls/server.crt

export FABRIC_CA_CLIENT_HOME=$ORDERER1_DIR
echo "Enrolling orderer1.$ORG_NAME.."
fabric-ca-client enroll --caname $CA_NAME --csr.names C=SG,ST=Singapore,L=Singapore,O=$ORG_NAME --csr.hosts orderer1.$ORG_NAME,localhost -m orderer1.$ORG_NAME -u https://orderer0.$ORG_NAME:mysecret@localhost:$PORT --tls.certfiles $TLS_DIR/tls-cert.pem
mkdir -p $ORDERER1_DIR/msp/admincerts && cp $ADMIN_DIR/msp/signcerts/*.pem $ORDERER1_DIR/msp/admincerts/

echo "TLS orderer1.$ORG_NAME.."
cp $ORDERER1_DIR/msp/cacerts/*.pem $ORDERER1_DIR/tls/ca.crt
cp $ORDERER1_DIR/msp/keystore/* $ORDERER1_DIR/tls/server.key
cp $ORDERER1_DIR/msp/signcerts/*.pem $ORDERER1_DIR/tls/server.crt

echo "Preparing MSP folder.."
mkdir -p $ORG_DIR/msp/admincerts $ORG_DIR/msp/cacerts $ORG_DIR/msp/tlscacerts
cp $ADMIN_DIR/msp/signcerts/*.pem $ORG_DIR/msp/admincerts/
cp $PEER_DIR/msp/cacerts/*.pem $ORG_DIR/msp/cacerts/
cp $PEER_DIR/tls/ca.crt $ORG_DIR/msp/tlscacerts/

read -p "Press [Enter] key to continue..."

mkdir -p config
rm -f ./config/$DEFINITION_NAME.json
configtxgen -printOrg $MSP_NAME > ./config/$DEFINITION_NAME.json
echo "All Done!!"
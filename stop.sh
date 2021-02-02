#/bin/sh

set -x

echo "Destroying all components.."

docker-compose down -v -t 5

docker rm -f $(docker ps -a | grep chaincode1 | awk '{print $1}')

rm -rf crypto-config

rm -rf ca/org1.example.com/msp ca/org1.example.com/*.pem ca/org1.example.com/*.db ca/org1.example.com/IssuerPublicKey ca/org1.example.com/IssuerRevocationPublicKey

rm -rf ca/org2.example.com/msp ca/org2.example.com/*.pem ca/org2.example.com/*.db ca/org2.example.com/IssuerPublicKey ca/org2.example.com/IssuerRevocationPublicKey

# Chaincode packaging
rm -rf chaincode/hyperledger

rm -rf downloads
rm -rf config
rm -rf ledger

echo "Done!!"
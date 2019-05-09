#/bin/sh

echo "Destroying all components.."

docker-compose down

docker rm -f $(docker ps -a | grep chaincode1 | awk '{print $1}')

rm -rf crypto-config
rm -rf ca-config/org1/msp ca-config/org1/*.pem ca-config/org1/*.db ca-config/org1/IssuerPublicKey ca-config/org1/IssuerRevocationPublicKey
rm -rf ca-config/org1/tlsca/msp ca-config/org1/tlsca/*.pem ca-config/org1/tlsca/*.db ca-config/org1/tlsca/IssuerPublicKey ca-config/org1/tlsca/IssuerRevocationPublicKey

rm -rf ca-config/org2/msp ca-config/org2/*.pem ca-config/org2/*.db ca-config/org2/IssuerPublicKey ca-config/org2/IssuerRevocationPublicKey
rm -rf ca-config/org2/tlsca/msp ca-config/org2/tlsca/*.pem ca-config/org2/tlsca/*.db ca-config/org2/tlsca/IssuerPublicKey ca-config/org2/tlsca/IssuerRevocationPublicKey

rm -rf downloads
rm -rf config

echo "Done!!"
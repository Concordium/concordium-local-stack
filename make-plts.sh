#!/usr/bin/env bash

# get the details for the PLT to create
echo "Choose a token Identifier (e.g., PLT1):"
read TOKEN_ID
echo "Set a descriptive name for the token (e.g., My Protocol Level Token):"
read TOKEN_NAME
echo "Set a longer description for the token (e.g., This is my first Protocol Level Token):"
read TOKEN_DESCRIPTION
echo "Choose the number of decimal places (e.g., 2; 8 or less is recommended):"
read DECIMALS
echo "Set the number of tokens for the initial supply (e.g., 1000):"
read INITIAL_SUPPLY
INITIAL_SUPPLY=$((${INITIAL_SUPPLY} * 10**${DECIMALS}))
echo "Set the address for the token governance account:"
read GOVERNANCE_ADDRESS

cat <<EOF
Ready to create a Protocol Level Token with the following details:
TOKEN_SYMBOL: $TOKEN_ID
TOKEN_NAME: $TOKEN_NAME
GOVERNANCE_ADDRESS: $GOVERNANCE_ADDRESS
DECIMALS: $DECIMALS
INITIAL_SUPPLY: $INITIAL_SUPPLY (in smallest units)
EOF

echo "Press Enter to continue or Ctrl+C to abort."
read continue

# Get the next sequence number for the level 2 key
NEXT_SEQUENCE=$(concordium-client raw GetNextUpdateSequenceNumbers --grpc-ip localhost --grpc-port 20100 | jq .protocolLevelTokensParameters)
# set a timout one hour from now
TIMEOUT=$(date -u -d "+1 hour" +%s 2>/dev/null || date -u -v +1H +%s)

# create the transaction file that will create the PLT
jq "\
  .seqNumber=${NEXT_SEQUENCE} | \
  .timeout=${TIMEOUT} | \
  .payload.update.tokenId=\"${TOKEN_ID}\" | \
  .payload.update.decimals=${DECIMALS} | \
  .payload.update.initializationParameters.name=\"${TOKEN_NAME}\" | \
  .payload.update.initializationParameters.metadata.url=\"http://localhost:7020/metadata/${TOKEN_ID}-metadata.json\" | \
  .payload.update.initializationParameters.initialSupply.decimals=${DECIMALS} | \
  .payload.update.initializationParameters.initialSupply.value=\"${INITIAL_SUPPLY}\" | \
  .payload.update.initializationParameters.governanceAccount.address=\"${GOVERNANCE_ADDRESS}\" \
   " ./transactions/create-plt-template.json > ./transactions/create-${TOKEN_ID}.json

# create the metadata file for the PLT
cat <<EOF > ./webserver/metadata/${TOKEN_ID}-metadata.json
{
  "name": "${TOKEN_NAME}",
  "description": "${TOKEN_DESCRIPTION}",
  "symbol": "${TOKEN_ID}",
  "decimals": ${DECIMALS},
  "thumbnail": {
    "url": "http://localhost:7020/images/plt1.png"
  },
  "display": {
    "url": "http://localhost:7020/images/plt1.png"
  }
}
EOF

#submit the transaction to the node
echo "Submitting $transaction"
concordium-client consensus chain-update transactions/create-${TOKEN_ID}.json --key chain/update-keys/level2-key-0.json  --grpc-ip localhost --grpc-port 20100

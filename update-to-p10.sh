#!/usr/bin/env bash

# Check the chain is at P9
CURRENT_PROTOCOL_VERSION=$(concordium-client --grpc-port 20100 --grpc-ip localhost raw GetConsensusInfo | jq .protocolVersion)
echo "Current protocol version is ${CURRENT_PROTOCOL_VERSION}"
if [[ ${CURRENT_PROTOCOL_VERSION} -ne 9 ]]; then
  echo "Error: Current protocol level is not 9. Aborting."
  exit 1
fi

echo "This script will create a chain update transaction"
echo "to update the protocol level from 9 to 10"
echo "The protocol version update will happen in 10 minutes time"
echo "Press Enter to continue or Ctrl+C to abort."
read continue

# Get the next sequence number for the level 2 key
NEXT_SEQUENCE=$(concordium-client raw GetNextUpdateSequenceNumbers --grpc-ip localhost --grpc-port 20100 | jq .protocol)
# set an effective time 10 minutes from now
EFFECTIVE_TIME=$(date -u -d "+10 minutes" +%s 2>/dev/null || date -u -v +10M +%s)
# set a timout 5 minutes from now
TIMEOUT=$(date -u -d "+5 minutes" +%s 2>/dev/null || date -u -v +5M +%s)

# create the transaction file that will create the PLT
jq "\
  .seqNumber=${NEXT_SEQUENCE} | \
  .timeout=${TIMEOUT} | \
  .effectiveTime=${EFFECTIVE_TIME} \
   " ./transactions/p9-p10-update-template.json > ./transactions/p9-p10-update.json

#submit the transaction to the node
echo "Submitting chain update $transaction"
concordium-client consensus chain-update transactions/p9-p10-update.json --key chain/update-keys/level2-key-0.json  --grpc-ip localhost --grpc-port 20100

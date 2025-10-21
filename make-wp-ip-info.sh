#!/usr/bin/env bash

ar1=$(jq ".arInfo.arPublicKey" ./chain/ars/ar-data-1.json)
ar2=$(jq ".arInfo.arPublicKey" ./chain/ars/ar-data-2.json)
ar3=$(jq ".arInfo.arPublicKey" ./chain/ars/ar-data-3.json)
ipVerifyKey=$(jq ".ipInfo.ipVerifyKey" ./chain/idps/ip-data-0.json)
ipCdiVerifyKey=$(jq ".ipInfo.ipCdiVerifyKey" ./chain/idps/ip-data-0.json)

echo "Making wallet-proxy/ip-info.json"
jq " \
  .[0].arsInfos.\"1\".arPublicKey=${ar1} | \
  .[0].arsInfos.\"2\".arPublicKey=${ar2} | \
  .[0].arsInfos.\"3\".arPublicKey=${ar3} | \
  .[0].ipInfo.ipCdiVerifyKey=${ipCdiVerifyKey} | \
  .[0].ipInfo.ipVerifyKey=${ipVerifyKey} \
  " ./wallet-proxy/ip-info.json-template > ./wallet-proxy/ip-info.json

#!/usr/bin/env bash


for IDP_FILE in $(ls chain/idps/ip-data-*.json); do
  if [[ ! ${IDP_FILE} =~ "pub" ]] ; then
    NEW_FILE=$(echo $IDP_FILE | sed 's/.json$/.pub.json/')
    echo "Making data pub for $IDP_FILE $NEW_FILE"
    jq ".v=0 | .value=.ipInfo | del(.ipSecretKey, .ipInfo, .ipCdiSecretKey)" $IDP_FILE > $NEW_FILE
  fi
done

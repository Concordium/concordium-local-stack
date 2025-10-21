#!/usr/bin/env bash

if ! [ -f local-node/genesis.dat ] ; then
  echo "creating genesis for localnet"
  genesis-creator generate --config=p9-localnet-genesis.toml

  echo "copying genesis.dat for local-node"
  cp chain/genesis.dat local-node/

else
  echo "genesis.dat already exists for local-node, skipping genesis creation"
fi

echo "Setting up idp public key files"
./make-ip-data-pubs.sh

echo "Setting up wallet proxy config"
./make-wp-ip-info.sh

if ! [ -d localccd-postgres/data ] ; then
  echo "creating localccd-postgresql data directory"
  mkdir -p localccd-postgres/data
else
  echo "localccd-postgresql data directory already exists, skipping"
fi


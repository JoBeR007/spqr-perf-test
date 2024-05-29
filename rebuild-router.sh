#!/bin/bash
for pid in $(ps -ef | awk '/spqr-router --config/ {print $2}'); do kill -9 "$pid"; done
rm -rf spqr
git clone https://github.com/pg-sharding/spqr.git
cd spqr || exit 1
make build
./spqr-router --config ../configs/router.yaml run
cd ..

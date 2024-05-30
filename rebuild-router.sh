#!/bin/bash
pkill -9 -f "spqr-router --config"
rm -rf spqr
git clone https://github.com/pg-sharding/spqr.git
cd spqr || exit 1
make build
./spqr-router --config ../configs/router.yaml run

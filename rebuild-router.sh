#!/bin/bash
pkill -9 -f "spqr-router --config"
cd spqr || exit 1
make build
./spqr-router --config ../configs/router.yaml run

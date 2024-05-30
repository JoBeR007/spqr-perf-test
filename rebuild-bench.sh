#!/bin/bash
pkill -9 -f "benchbase"
rm -rf benchbase-spqr
git clone https://github.com/JoBeR007/benchbase-spqr.git
cd benchbase-spqr || exit 1
./mvnw clean package -P spqr -DskipTests
cd target || exit 1
tar xvzf benchbase-spqr.tgz
cd ..
java -jar target/benchbase-spqr/benchbase.jar -b tpcc -c config/postgres/sample_tpcc_config2.xml --create=true --load=true --execute=true
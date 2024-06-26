#!/bin/bash

#SETTING UP ROUTER CONFIG
ROUTER_CFG_PATH="configs/router.yaml"
BENCH_CFG_PATH="configs/tpcc_config.xml"
#replace every entrance of HOSTPORT1..6 in router config with env variable
for i in {1..6}; do
  search_string="HOSTPORT${i}"
  replace_string="${!search_string}"
  sed -i "s/$search_string/$replace_string/g" configs/router.yaml
done
#replace host with router ip
sed -i "s/0.0.0.0/${ROUTER_IP}/g" "${ROUTER_CFG_PATH}"
#replace postgres credentials
sed -i "s/strong/${POSTGRES_PASS}/g" "${ROUTER_CFG_PATH}"
sed -i "s/user1/${POSTGRES_USER}/g" "${ROUTER_CFG_PATH}"
sed -i "s/db1/${POSTGRES_DB}/g" "${ROUTER_CFG_PATH}"

#SETTING UP BENCH CONFIG
#modify config
jdbc="jdbc:postgresql://"
sslmode="?targetServerType=master&amp;sslmode=disable"
shard1url="$jdbc${HOSTPORT1},${HOSTPORT2},${HOSTPORT3}/${POSTGRES_DB}$sslmode"
shard2url="$jdbc${HOSTPORT4},${HOSTPORT5},${HOSTPORT6}/${POSTGRES_DB}$sslmode"
routerurl="$jdbc${ROUTER_IP}:8432/$POSTGRES_DB$sslmode"
escaped_shard1url=$(echo "$shard1url" | sed -e 's/[\/&]/\\&/g')
escaped_shard2url=$(echo "$shard2url" | sed -e 's/[\/&]/\\&/g')
escaped_routerurl=$(echo "$routerurl" | sed -e 's/[\/&]/\\&/g')
sed -i "s/HOSTPORT1/$escaped_shard1url/g" "${BENCH_CFG_PATH}"
sed -i "s/HOSTPORT2/$escaped_shard2url/g" "${BENCH_CFG_PATH}"
sed -i "s/ROUTERHOSTPORT/$escaped_routerurl/g" "${BENCH_CFG_PATH}"
sed -i "s/user1/${POSTGRES_USER}/g" "${BENCH_CFG_PATH}"
sed -i "s/12345678/${POSTGRES_PASS}/g" "${BENCH_CFG_PATH}"

scp "${BENCH_CFG_PATH}" "${BENCH_USER}"@"${BENCH_IP}":/home/spqr-perf-test/configs
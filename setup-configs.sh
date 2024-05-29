#!/bin/bash

#SETTING UP ROUTER CONFIG
#replace every entrance of HOSTPORT1..6 in router config with env variable
for i in {1..6}; do
  search_string="HOSTPORT${i}"
  replace_string="${!search_string}"
  sed -i "s/$search_string/$replace_string/g" configs/router.yaml
done
#replace postgres credentials
sed -i "s/strong/${POSTGRES_PASS}/g" configs/router.yaml
sed -i "s/user1/${POSTGRES_USER}/g" configs/router.yaml
sed -i "s/db1/${POSTGRES_DB}/g" configs/router.yaml

#SETTING UP BENCH CONFIG
#modify config
jdbc="jdbc:postgresql://"
sslmode="?targetServerType=master&sslmode=disable"
shard1url="$jdbc${HOSTPORT1},${HOSTPORT2},${HOSTPORT3}/${POSTGRES_DB}$sslmode"
shard2url="$jdbc${HOSTPORT4},${HOSTPORT5},${HOSTPORT6}/${POSTGRES_DB}$sslmode"
routerurl="$jdbc${ROUTER_IP}:8432/$POSTGRES_DB$sslmode"
escaped_shard1url=$(echo "$shard1url" | sed -e 's/[\/&]/\\&/g')
escaped_shard2url=$(echo "$shard2url" | sed -e 's/[\/&]/\\&/g')
escaped_routerurl=$(echo "$routerurl" | sed -e 's/[\/&]/\\&/g')
sed -i "s/HOSTPORT1/$escaped_shard1url/g" configs/tpcc_config.xml
sed -i "s/HOSTPORT2/$escaped_shard2url/g" configs/tpcc_config.xml
sed -i "s/ROUTERHOSTPORT/$escaped_routerurl/g" configs/tpcc_config.xml
sed -i "s/user1/${POSTGRES_USER}/g" configs/tpcc_config.xml
sed -i "s/12345678/${POSTGRES_PASS}/g" configs/tpcc_config.xml

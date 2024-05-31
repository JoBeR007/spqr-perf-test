pkill -9 -f "benchbase"
java -jar target/benchbase-spqr/benchbase.jar -b tpcc -c ../configs/tpcc_config.xml --create=true --load=true --execute=true
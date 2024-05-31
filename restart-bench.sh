pkill -9 -f "benchbase"
java -jar target/benchbase-spqr/benchbase.jar -b tpcc -c config/postgres/sample_tpcc_config2.xml --create=true --load=true --execute=true
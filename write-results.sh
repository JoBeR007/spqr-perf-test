IFS=':' read -r HOST1 PORT1 <<< "${HOSTPORT1}"
export PGPASSWORD="${POSTGRES_PASS}"

psql -h "$HOST1" -p "$PORT1" -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<EOF
CREATE TABLE IF NOT EXISTS benchmark_data (
    timestamp TIMESTAMPTZ,
    tpmC DECIMAL(10, 2),
    lat_median DECIMAL(10, 2),
    lat_avg DECIMAL(10, 2),
    lat_75th DECIMAL(10, 2),
    lat_90th DECIMAL(10, 2),
    lat_95th DECIMAL(10, 2),
    lat_99th DECIMAL(10, 2),
    goodput DECIMAL(10, 2)
);
EOF

if [ $? -ne 0 ]; then
   echo "Failed to create results table"
   exit 1
fi

while read -r line; do
    # Insert data into the PostgreSQL table
    psql -h "$HOST1" -p "$PORT1" -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<EOF
    INSERT INTO benchmark_data (timestamp, tpmC, lat_median, lat_avg, lat_75th, lat_90th, lat_95th, lat_99th, goodput)
    VALUES (NOW(), $line);
EOF
    if [ $? -eq 0 ]; then
      echo "Successfully exported results"
    else
       echo "Failed to insert results: $line"
       exit 1
    fi
done


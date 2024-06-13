SQL_FILE="configs/copy-tables.sql"

# Parse HOST and PORT from HOSTPORT1
IFS=':' read -r HOST1 PORT1 <<< "${HOSTPORT1}"

export PGPASSWORD=$POSTGRES_PASS
psql -h "$HOST1" -p "$PORT1" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$SQL_FILE"

if [ $? -eq 0 ]; then
  echo "SQL file executed successfully on ${HOSTPORT1}"
else
  echo "Failed to execute SQL file on ${HOSTPORT1}"
  exit 1
fi

# Parse HOST and PORT from HOSTPORT4
IFS=':' read -r HOST2 PORT2 <<< "${HOSTPORT4}"

psql -h "$HOST2" -p "$PORT2" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$SQL_FILE"

if [ $? -eq 0 ]; then
  echo "SQL file executed successfully on $HOSTPORT2"
else
   echo "Failed to execute SQL file on $HOSTPORT2"
   exit 1
fi

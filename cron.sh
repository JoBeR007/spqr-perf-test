#!/bin/bash

REPO_URL="https://github.com/pg-sharding/spqr"
BRANCH="master"
FULL_PATH=$(realpath $0)
DIR_PATH=$(dirname "$FULL_PATH")

REPO_DIR="spqr"
LAST_COMMIT_FILE="last_commit.txt"

# Scripts to run
SCRIPTS=("setup-configs.sh" "rebuild-router.sh" "copy-data.sh")
REMOTE_SCRIPT1="load-data.sh"
REMOTE_SCRIPT2="restart-bench.sh"

#Check whether all necessary env variables are set
ENV_VARS=("HOSTPORT1" "HOSTPORT2" "HOSTPORT3" "HOSTPORT4" "HOSTPORT5" "HOSTPORT6" "POSTGRES_USER" "POSTGRES_PASS"
"POSTGRES_DB" "ROUTER_IP" "BENCH_IP" "BENCH_USER")
for i in "${!SCRIPTS[@]}"; do
    env_var="${ENV_VARS[$i]}"
    if [ -z "${!env_var}" ]; then
        echo "Error: $env_var is not set for script"
        exit 1
    fi
done

cd "$DIR_PATH" || exit 1

# Clone the repository if it does not exist
if [ ! -d "$REPO_DIR" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
fi

# Function to fetch the latest commit hash
fetch_latest_commit_hash() {
  git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" fetch origin "$BRANCH"
  git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" rev-parse origin/"$BRANCH"
}

# Get the last processed commit hash (if it exists)
if [ -f "$LAST_COMMIT_FILE" ]; then
  LAST_PROCESSED_COMMIT_HASH=$(cat "$LAST_COMMIT_FILE")
else
  LAST_PROCESSED_COMMIT_HASH=""
fi

data_loaded=false
#parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -dl|--data-loaded)
      data_loaded="$2"
      shift 2 # shift past curr arg and value for curr arg
      ;;
    *)
      echo "Unknown option: $1, -dl | --data-loaded arg is supported" >&2
      exit 1
      ;;
  esac
  shift
done

# Validate option value
if [ "$data_loaded" != "true" ] && [ "$data_loaded" != "false" ]; then
    echo "Invalid value for argument: $data_loaded. Use true or false." >&2
    exit 1
fi

# Get the latest commit hash
LATEST_COMMIT_HASH=$(fetch_latest_commit_hash)

# Check if there is a new commit
if [ "$LATEST_COMMIT_HASH" != "$LAST_PROCESSED_COMMIT_HASH" ]; then

  echo "New commit detected. Running the scripts"

  bash "${SCRIPTS[0]}"
  if [ $? -ne 0 ]; then
      echo "Script ${SCRIPTS[0]} failed. Stopping the execution of further scripts."
      exit 1
  fi
  echo "Starting router"
  bash "${SCRIPTS[1]}" &

  echo "Loading Data"
  if [ "$data_loaded" = false ] ; then
    scp ${REMOTE_SCRIPT1} "${BENCH_USER}"@"${BENCH_IP}":/home/"${BENCH_USER}"
    ssh "${BENCH_USER}"@"${BENCH_IP}" "bash /home/${BENCH_USER}/$REMOTE_SCRIPT1"
    if [ $? -ne 0 ]; then
        echo "Script ${REMOTE_SCRIPT1} failed. Stopping the execution of further scripts."
        exit 1
    fi
    data_loaded=true
  fi

  if [ "$data_loaded" = true ] ; then
    echo "Copying tables"
    bash "${SCRIPTS[2]}"

    echo "Starting benchmark"
    scp $REMOTE_SCRIPT2 "${BENCH_USER}"@"${BENCH_IP}":/home/"${BENCH_USER}"
    ssh "${BENCH_USER}"@"${BENCH_IP}" "bash /home/${BENCH_USER}/$REMOTE_SCRIPT2"
  fi

  echo "$LATEST_COMMIT_HASH" > "$LAST_COMMIT_FILE"
  git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" pull
else
  echo "No new commits. Waiting..."
fi
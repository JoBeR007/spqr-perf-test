#!/bin/bash

REPO_URL="https://github.com/pg-sharding/spqr"
BRANCH="master"

REPO_DIR="spqr"

# Local storage for the last processed commit hash
LAST_COMMIT_FILE="last_commit.txt"

# Scripts to run
SCRIPTS=("setup-configs.sh" "rebuild-router.sh")
REMOTE_SCRIPT="restart-bench.sh"
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

# Main loop to check for updates
while true; do
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

    scp ${REMOTE_SCRIPT} "${BENCH_USER}"@"${BENCH_IP}":/home/spqr-perf-test/
    ssh "${BENCH_USER}"@"${BENCH_IP}" "bash ${REMOTE_SCRIPT}"

    echo "$LATEST_COMMIT_HASH" > "$LAST_COMMIT_FILE"

    git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" pull
  else
    echo "No new commits. Waiting..."
  fi
  sleep 300  # Check every 5 minutes
done
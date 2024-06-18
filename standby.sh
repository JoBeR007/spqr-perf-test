#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

REPO_URL="https://github.com/pg-sharding/spqr"
BRANCH="master"
FULL_PATH=$(realpath "$0")
DIR_PATH=$(dirname "$FULL_PATH")

REPO_DIR="spqr"
METADATA_FILE="metadata_file.txt"

# Scripts to run
SCRIPTS=("setup-configs.sh" "rebuild-router.sh" "copy-data.sh")
REMOTE_SCRIPT1="load-data.sh"
REMOTE_SCRIPT2="restart-bench.sh"

# Environment Variables
ENV_VARS=("HOSTPORT1" "HOSTPORT2" "HOSTPORT3" "HOSTPORT4" "HOSTPORT5" "HOSTPORT6" "POSTGRES_USER" "POSTGRES_PASS"
"POSTGRES_DB" "ROUTER_IP" "BENCH_IP" "BENCH_USER")

# Trap to handle cleanup on exit or interrupt
trap "exit_cleanup" EXIT INT TERM

exit_cleanup() {
    log "Exiting script. Cleaning up..."
    # Add cleanup tasks here if needed
}

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Check whether all necessary environment variables are set
for var in "${ENV_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        log "Error: $var is not set."
        exit 1
    fi
done

cd "$DIR_PATH" || exit 1

# Clone the repository if it does not exist
if [ ! -d "$REPO_DIR" ]; then
  log "Cloning repository $REPO_URL into $REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
fi

# Function to fetch the latest commit hash
fetch_latest_commit_hash() {
    git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" fetch origin "$BRANCH"
    git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" rev-parse origin/"$BRANCH"
}

# Initialize Metadata if not exists, otherwise read existing Metadata
initialize_or_read_metadata() {
    if [ -f "$METADATA_FILE" ]; then
        log "Reading metadata from $METADATA_FILE"
        source "$METADATA_FILE"
    else
        log "Initializing metadata file $METADATA_FILE"
        cat <<EOF > "$METADATA_FILE"
LAST_PROCESSED_COMMIT_HASH=''
DATA_LOADED='false'
EOF
        LAST_PROCESSED_COMMIT_HASH=''
        DATA_LOADED='false'
    fi

    # Ensure metadata values are correctly read
    [ -z "$LAST_PROCESSED_COMMIT_HASH" ] && LAST_PROCESSED_COMMIT_HASH=''
    [ -z "$DATA_LOADED" ] && DATA_LOADED='false'
}

# Update metadata file
update_metadata() {
    log "Updating metadata: LAST_PROCESSED_COMMIT_HASH=$LATEST_COMMIT_HASH, DATA_LOADED=$DATA_LOADED"
    cat <<EOF > "$METADATA_FILE"
LAST_PROCESSED_COMMIT_HASH=$LATEST_COMMIT_HASH
DATA_LOADED=$DATA_LOADED
EOF
}

# Parse arguments
parse_arguments() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -dl|--data-loaded)
                DATA_LOADED="$2"
                shift 2 # shift past curr arg and value for curr arg
                ;;
            *)
                log "Unknown option: $1. Only -dl | --data-loaded arg is supported" >&2
                exit 1
                ;;
        esac
    done

    # Validate option value
    if [ "$DATA_LOADED" != "true" ] && [ "$DATA_LOADED" != "false" ]; then
        log "Invalid value for argument: $DATA_LOADED. Use true or false." >&2
        exit 1
    fi
}
main() {
    initialize_or_read_metadata
    parse_arguments "$@"

    # Main loop to check for updates
    while true; do
        # Get the latest commit hash
        LATEST_COMMIT_HASH=""
        for _ in {1..3}; do
            if LATEST_COMMIT_HASH=$(fetch_latest_commit_hash); then
                break
            else
                sleep 10
            fi
        done


        if [ -z "$LATEST_COMMIT_HASH" ]; then
            log "Failed to fetch latest commit hash after multiple attempts. Exiting."
            exit 1
        fi
        # Check if there is a new commit
        if [ "$LATEST_COMMIT_HASH" != "$LAST_PROCESSED_COMMIT_HASH" ]; then
            log "New commit detected. Running the scripts"

            for script in "${SCRIPTS[@]}"; do
                if [ ! -e "$script" ]; then
                    log "Script $script not found. Exiting."
                    exit 1
                fi
            done

            bash "${SCRIPTS[0]}"
            log "Starting router"
            bash "${SCRIPTS[1]}" &
            sleep 5

            log "Loading Data"
            if [ "$DATA_LOADED" = "false" ]; then
                scp ${REMOTE_SCRIPT1} "${BENCH_USER}"@"${BENCH_IP}":/home/"${BENCH_USER}"
                ssh "${BENCH_USER}"@"${BENCH_IP}" "bash /home/${BENCH_USER}/$REMOTE_SCRIPT1"
                DATA_LOADED="true"
            fi

            if [ "$DATA_LOADED" = "true" ]; then
                log "Copying tables"
                bash "${SCRIPTS[2]}"

                log "Starting benchmark"
                scp $REMOTE_SCRIPT2 "${BENCH_USER}"@"${BENCH_IP}":/home/"${BENCH_USER}"
                ssh "${BENCH_USER}"@"${BENCH_IP}" "bash /home/${BENCH_USER}/$REMOTE_SCRIPT2"
            fi

            # Update metadata file
            update_metadata
            log "Pulling latest changes from remote repository"
            git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" pull
        else
            log "No new commits. Waiting..."
        fi
        sleep 300  # Check every 5 minutes
    done
}

main "$@"
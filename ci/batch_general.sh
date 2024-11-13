#!/bin/bash

# Set the app variable
app="sgemm"

# Create a new directory with a timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_DIR="general_results_$TIMESTAMP"
mkdir -p $RESULT_DIR

# Function to sanitize command for filename
sanitize_filename() {
  echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g'
}

# Function to run a test and log the output
run_test() {
  local test_command=$1
  local sanitized_command=$(sanitize_filename "$test_command")
  local logfile="$RESULT_DIR/${sanitized_command}.log"
  echo "Running test and logging to $logfile"
  $test_command >> "$logfile" 2>&1
}

# Clusters (default=1)
echo "===========Testing cluster configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --clusters=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --clusters=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --clusters=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --clusters=8 --perf=2"

# Cores (default=1)
echo "===========Testing core configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --cores=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --cores=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --cores=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --cores=8 --perf=2"

# Warps (default=4)
echo "===========Testing warp configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --warps=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --warps=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --warps=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --warps=16 --perf=2"

# Threads (default=4)
echo "===========Testing thread configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --threads=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --threads=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --threads=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --threads=64 --perf=2"

# Barriers (default=4)
echo "===========Testing barrier configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --barriers=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --barriers=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --barriers=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --barriers=16 --perf=2"

# Socket Size (default=4)
echo "===========Testing socket size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --socket_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --socket_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --socket_size=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --socket_size=32 --perf=2"

# XLEN
echo "===========Testing XLEN configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --xlen=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --xlen=64 --perf=2"

# FLEN
echo "===========Testing FLEN configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --flen=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --flen=64 --perf=2"

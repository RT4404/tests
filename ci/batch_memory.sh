#!/bin/bash

# Set the app variable
app="sgemm"

# Create a new directory with a timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_DIR="memory_results_$TIMESTAMP"
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

echo "==========Memory System Configuration Tests=========="

# Memory block size (default=64)
echo "===========Testing memory block size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=128 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=256 --perf=2"

# Memory address width (default=32, 48 with XLEN_64 enabled)
echo "T===========esting memory address width configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --mem_addr_width=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_addr_width=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_addr_width=48 --perf=2"

# Stack log2 size (default=13)
echo "===========Testing stack log2 size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --stack_log2_size=12 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_log2_size=13 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_log2_size=14 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_log2_size=16 --perf=2"

# Stack size (default=8192) ?
echo "===========Testing stack size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --stack_size=4096 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_size=8192 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_size=16384 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_size=32768 --perf=2"

# Stack base address (default=0xFF000000, 0x1FF000000 with XLEN_64)
echo "===========Testing stack base address configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --stack_base_addr=0x10000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_base_addr=0x20000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --stack_base_addr=0x30000000 --perf=2"

# Startup address (default=0x80000000, 0x180000000 with XLEN_64)
echo "===========Testing startup address configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --startup_addr=0x10000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --startup_addr=0x20000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --startup_addr=0x30000000 --perf=2"

# User base address
echo "===========Testing user base address configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --user_base_addr=0x00000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --user_base_addr=0x00010000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --user_base_addr=0x00100000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --user_base_addr=0x01000000 --perf=2"

# IO base address
echo "===========Testing IO base address configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --io_base_addr=0x20000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_base_addr=0x30000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_base_addr=0x40000000 --perf=2"

# Page table base address
echo "===========Testing page table base address configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --page_table_base_addr=0x00000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --page_table_base_addr=0x40000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --page_table_base_addr=0x80000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --page_table_base_addr=0xC0000000 --perf=2"

# Memory page size (default=4096) ?
echo "===========Testing memory page size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --mem_page_size=1024 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_page_size=2048 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_page_size=4096 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_page_size=8192 --perf=2"

# Memory page log2 size (default=12)
echo "===========Testing memory page log2 size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --mem_page_log2_size=10 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_page_log2_size=12 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_page_log2_size=13 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_page_log2_size=14 --perf=2"

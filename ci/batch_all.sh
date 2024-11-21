#!/bin/bash

# Set the app variable
app="sgemm"

# Create a new directory with a timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_DIR="results_$TIMESTAMP"
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

echo "==========General Configuration Tests=========="

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

echo "==========Cache Configuration Tests=========="

# L1 cache off (default=enabled)
echo "===========Testing L1 cache on/off configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l1cache_off --perf=2"

# L2 cache on (default=disabled)
echo "===========Testing L2 cache on/off configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2cache --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

# L3 cache on (default=disabled)
echo "===========Testing L3 cache on/off configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3cache --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

echo "==========ICache Configuration Tests=========="

# Number of ICaches (default=1)
echo "===========Testing Number of ICaches configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_icaches=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_icaches=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_icaches=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_icaches=8 --perf=2"

# Icache Size (default=16384)
echo "===========Testing ICache size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --icache_size=8192 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_size=16384 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_size=32768 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_size=65536 --perf=2"

# ICache Ways (default=2)
echo "===========Testing Number of ICaches configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --icache_ways=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_ways=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_ways=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_ways=8 --perf=2"

# ICache Memory Request Queue Size (default=4)
echo "===========Testing ICache MREQ size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --icache_mreq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mreq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mreq_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mreq_size=16 --perf=2"

# ICache Miss Status Holding Register Size (default=16)
echo "===========Testing ICache MSHR size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --icache_mshr_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mshr_size=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mshr_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mshr_size=64 --perf=2"

# ICache Core Response Queue Size (default=2)
echo "===========Testing ICache CRSQ size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --icache_crsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_crsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_crsq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_crsq_size=8 --perf=2"

# ICache Memory Response Queue Size (default=0)
echo "===========Testing ICache MRSQ size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --icache_mrsq_size=0 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mrsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mrsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --icache_mrsq_size=4 --perf=2"

echo "==========DCache Configuration Tests=========="

# Number of DCaches (default=2)
echo "===========Testing Number of Dcaches configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_dcaches=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_dcaches=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_dcaches=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_dcaches=8 --perf=2"

# DCache Writeback on/off (default=disabled)
echo "===========Testing DCache Writeback configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_writeback=0 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_writeback=1 --perf=2"

# DCache Size (default=16384)
echo "===========Testing DCache Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_size=8192 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_size=16384 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_size=32768 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_size=65536 --perf=2"

# DCache Ways (default=2)
echo "===========Testing DCache Ways Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_ways=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_ways=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_ways=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_ways=8 --perf=2"

# DCache MReq Size (default=4)
echo "===========Testing DCache MReq Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_mreq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mreq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mreq_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mreq_size=16 --perf=2"

# DCache MSHR Size (default=16)
echo "===========Testing DCache MSHR Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_mshr_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mshr_size=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mshr_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mshr_size=64 --perf=2"

# DCache CRSQ Size (default=2)
echo "===========Testing DCache CRSQ Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_crsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_crsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_crsq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_crsq_size=8 --perf=2"

# DCache MRSQ (default=0)
echo "===========Testing DCache MRSQ Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_mrsq_size=0 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mrsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mrsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_mrsq_size=4 --perf=2"

# DCache Banks (default=2)
echo "===========Testing DCache Banks Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dcache_banks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_banks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_banks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --dcache_banks=8 --perf=2"

echo "==========L2 Cache Configuration Tests=========="

# L2 Writeback (default=off)
echo "===========Testing L2 Writeback Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_writeback=0 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_writeback=1 --perf=2"

# L2 Cache Size (default=1048576)
echo "===========Testing L2 Cache Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_size=524288 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_size=1048576 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_size=2097152 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_size=4194304 --perf=2"

# L2 Ways (default=2)
echo "===========Testing L2 Ways Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_ways=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_ways=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_ways=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_ways=8 --perf=2"

# L2 MReq Size (default=4)
echo "===========Testing L2 MReq Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_mreq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mreq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mreq_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mreq_size=16 --perf=2"

# L2 MSHR Size (default=16)
echo "===========Testing L2 MSHR Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_mshr_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mshr_size=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mshr_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mshr_size=64 --perf=2"

# L2 CRSQ Size (default=2)
echo "===========Testing L2 CRSQ Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_crsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_crsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_crsq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_crsq_size=8 --perf=2"

# L2 MRSQ Size (default=0)
echo "===========Testing L2 MRSQ Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_mrsq_size=0 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mrsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mrsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_mrsq_size=4 --perf=2"

# L2 Banks (default=4)
echo "===========Testing L2 Banks Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l2_banks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_banks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_banks=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l2_banks=16 --perf=2"

echo "==========L3 Cache Configuration Tests=========="

# L3 Writeback (default=disabled)
echo "===========Testing L3 Writeback Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_writeback=0 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_writeback=1 --perf=2"

# L3 Cache Size (default=1048576)
echo "===========Testing L3 Cache Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_size=524288 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_size=1048576 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_size=2097152 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_size=4194304 --perf=2"

# L3 Ways (default=4)
echo "===========Testing L3 Ways Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_ways=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_ways=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_ways=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_ways=16 --perf=2"

# L3 MReq Size (default=4)
echo "===========Testing L3 MReq Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_mreq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mreq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mreq_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mreq_size=16 --perf=2"

# L3 MSHR Size (default=16)
echo "===========Testing L3 MSHR Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_mshr_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mshr_size=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mshr_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mshr_size=64 --perf=2"

# L3 CRSQ Size (default=2)
echo "===========Testing L3 CRSQ Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_crsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_crsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_crsq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_crsq_size=8 --perf=2"

# L3 MRSQ Size (default=0)
echo "===========Testing L3 MRSQ Size Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_mrsq_size=0 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mrsq_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mrsq_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_mrsq_size=4 --perf=2"

# L3 Banks (default=8)
echo "===========Testing L3 Banks Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --l3_banks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_banks=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_banks=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --l3_banks=32 --perf=2"

# Memory Banks (default=2)
echo "===========Testing Memory Banks Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --memory_banks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --memory_banks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --memory_banks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --memory_banks=8 --perf=2"

# Number of Memory Ports (default=2)
echo "===========Testing Number of Memory Ports Configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_mem_ports=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_mem_ports=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_mem_ports=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_mem_ports=8 --perf=2"

echo "==========Memory System Configuration Tests=========="

# Memory block size (default=64)
echo "===========Testing memory block size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=128 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --mem_block_size=256 --perf=2"

# Memory address width (default=32, 48 with XLEN_64 enabled)
echo "===========Testing memory address width configurations==========="
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

echo "==========Local Memory Configuration Tests=========="

# Local memory enable/disable (default=enabled)
echo "===========Testing local memory enable configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --lmem_enable --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

# Local memory base address
echo "===========Testing local memory base address configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --lmem_base_addr=0x10000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_base_addr=0x20000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_base_addr=0x30000000 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_base_addr=0x40000000 --perf=2"

# Local memory log size
echo "===========Testing local memory log size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --lmem_log_size=10 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_log_size=12 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_log_size=14 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_log_size=16 --perf=2"

# Local memory number of banks
echo "===========Testing local memory number of banks configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --lmem_num_banks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_num_banks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_num_banks=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lmem_num_banks=16 --perf=2"

echo "==========Execution Unit Configuration Tests=========="

# ALU lanes (default=4)
echo "===========Testing ALU lanes configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_alu_lanes=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_alu_lanes=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_alu_lanes=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_alu_lanes=16 --perf=2"

# FPU lanes (default=4)
echo "===========Testing FPU lanes configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_lanes=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_lanes=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_lanes=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_lanes=16 --perf=2"

# LSU lanes (default=4)
echo "===========Testing LSU lanes configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_lanes=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_lanes=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_lanes=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_lanes=8 --perf=2"

# SFU lanes (default=4)
echo "===========Testing SFU lanes configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_lanes=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_lanes=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_lanes=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_lanes=8 --perf=2"

# ALU blocks (default=4)
echo "===========Testing ALU blocks configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_alu_blocks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_alu_blocks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_alu_blocks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_alu_blocks=8 --perf=2"

# FPU blocks (default=4)
echo "===========Testing FPU blocks configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_blocks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_blocks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_blocks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_fpu_blocks=8 --perf=2"

# LSU blocks (default=1)
echo "===========Testing LSU blocks configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_blocks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_blocks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_blocks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_lsu_blocks=8 --perf=2"

# SFU blocks (default=1)
echo "===========Testing SFU blocks configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_blocks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_blocks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_blocks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_sfu_blocks=8 --perf=2"

echo "==========Latency and FPU Configuration Tests=========="

# FPU queue size (default=4)
echo "===========Testing FPU queue size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --fpuq_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fpuq_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fpuq_size=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fpuq_size=32 --perf=2"

# IMUL: Integer multiplication latency (default=4)
echo "===========Testing IMUL latency configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --latency_imul=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_imul=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_imul=6 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_imul=8 --perf=2"

# FMA: Fused multiply-add latency (default=4)
echo "===========Testing FMA latency configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --latency_fma=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fma=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fma=6 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fma=8 --perf=2"

# FDIV: Floating-point division latency (default=16)
echo "===========Testing FDIV latency configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --latency_fdiv=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fdiv=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fdiv=24 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fdiv=32 --perf=2"

# FSQRT: Floating-point square root latency (default=16)
echo "===========Testing FSQRT latency configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --latency_fsqrt=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fsqrt=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fsqrt=24 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fsqrt=32 --perf=2"

# FCVT: Floating-point conversion latency (default=5)
echo "===========Testing FCVT latency configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --latency_fcvt=3 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fcvt=5 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fcvt=7 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fcvt=9 --perf=2"

# FNCP: Floating-point reciprocal latency (default=2)
echo "===========Testing FNCP latency configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --latency_fncp=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fncp=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fncp=3 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --latency_fncp=4 --perf=2"

# FMA processing element ratio (default=1)
echo "===========Testing FMA processing element ratio configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --fma_pe_ratio=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fma_pe_ratio=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fma_pe_ratio=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fma_pe_ratio=8 --perf=2"

# FDIV processing element ratio (default=8)
echo "===========Testing FDIV processing element ratio configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --fdiv_pe_ratio=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fdiv_pe_ratio=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fdiv_pe_ratio=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fdiv_pe_ratio=16 --perf=2"

# FSQRT processing element ratio (default=8)
echo "===========Testing FSQRT processing element ratio configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --fsqrt_pe_ratio=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fsqrt_pe_ratio=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fsqrt_pe_ratio=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fsqrt_pe_ratio=16 --perf=2"

# FCVT processing element ratio (default=8)
echo "===========Testing FCVT processing element ratio configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --fcvt_pe_ratio=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fcvt_pe_ratio=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fcvt_pe_ratio=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fcvt_pe_ratio=16 --perf=2"

# FNCP processing element ratio (default=2)
echo "===========Testing FNCP processing element ratio configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --fncp_pe_ratio=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fncp_pe_ratio=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fncp_pe_ratio=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --fncp_pe_ratio=8 --perf=2"

echo "==========Pipeline Configuration Tests=========="

# Issue Width (default=4)
echo "===========Testing Issue Width configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --issue_width=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --issue_width=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --issue_width=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --issue_width=16 --perf=2"

# Instruction Buffer Size (default=2)
echo "===========Testing Instruction Buffer Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --ibuf_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ibuf_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ibuf_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ibuf_size=8 --perf=2"

# LSU Line Size
echo "===========Testing LSU Line Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --lsu_line_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsu_line_size=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsu_line_size=128 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsu_line_size=256 --perf=2"

# LSU Queue Input Size (default=2)
echo "===========Testing LSU Queue Input Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --lsuq_in_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsuq_in_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsuq_in_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsuq_in_size=8 --perf=2"

# LSU Queue Output Size
echo "===========Testing LSU Queue Output Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --lsuq_out_size=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsuq_out_size=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsuq_out_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --lsuq_out_size=8 --perf=2"

# Global Barrier Enable
echo "===========Testing Global Barrier Enable configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --gbar_enable --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

echo "==========Virtual Memory Configuration Tests=========="

# VM Enable (default=disabled)
echo "===========Testing Virtual Memory Enable configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

# VM Address Mode (default=32)
echo "===========Testing VM Address Mode configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --vm_addr_mode=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --vm_addr_mode=36 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --vm_addr_mode=48 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --vm_addr_mode=64 --perf=2"

# Page Table Level (default=2)
echo "===========Testing Page Table Level configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_level=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_level=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_level=3 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_level=4 --perf=2"

# PTE Size (default=8)
echo "===========Testing Page Table Entry Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pte_size=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pte_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pte_size=16 --perf=2"

# Number of PTE Entries (default=128)
echo "===========Testing Number of PTE Entries configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --num_pte_entry=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --num_pte_entry=128 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --num_pte_entry=256 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --num_pte_entry=512 --perf=2"

# Page Table Size Limit (default=4096)
echo "===========Testing Page Table Size Limit configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size_limit=1024 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size_limit=2048 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size_limit=4096 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size_limit=8192 --perf=2"

# Page Table Size (default=4096)
echo "===========Testing Page Table Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size=1024 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size=2048 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size=4096 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --pt_size=8192 --perf=2"

# TLB Size (default=64)
echo "===========Testing TLB Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --tlb_size=16 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --tlb_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --tlb_size=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --vm_enable --tlb_size=128 --perf=2"

echo "==========ISA Extension Configuration Tests=========="

# Integer Multiply/Divide Extension (M) (default=enabled)
echo "===========Testing Integer Multiply/Divide Extension configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ext_m_disable --perf=2"

# Single Precision Floating-Point Extension (F) (default=enabled)
echo "===========Testing Single Precision Floating-Point Extension configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ext_f_disable --perf=2"

# Double Precision Floating-Point Extension (D) (default=enabled)
echo "===========Testing Double Precision Floating-Point Extension configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ext_d_disable --perf=2"

# Compressed Extension (C) (default=enabled)
echo "===========Testing Compressed Extension configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ext_c_disable --perf=2"

# Atomic Instructions Extension (A) (default=enabled)
echo "===========Testing Atomic Instructions Extension configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ext_a_disable --perf=2"

# Conditional Operations Extension (ZICOND) (default=enabled)
echo "===========Testing Conditional Operations Extension configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --ext_zicond_disable --perf=2"

echo "==========Tensor Core Configuration Tests=========="

# Tensor Core Size (default=8)
echo "===========Testing Tensor Core Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --tc_size=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --tc_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --tc_size=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --tc_size=128 --perf=2"

# Number of Tensor Cores (default=4)
echo "===========Testing Number of Tensor Cores configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --tc_num=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --tc_num=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --tc_num=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --tc_num=16 --perf=2"

# Number of TCU Lanes (default=4)
echo "===========Testing Number of TCU Lanes configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_lanes=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_lanes=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_lanes=8 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_lanes=16 --perf=2"

# Number of TCU Blocks (default=4)
echo "===========Testing Number of TCU Blocks configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_blocks=1 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_blocks=2 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_blocks=4 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --num_tcu_blocks=8 --perf=2"

echo "==========DPI and Synthesis Configuration Tests=========="

# Floating-Point Unit DPI (default=disabled)
echo "===========Testing FPU DPI configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --fpu_dpi --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

# Integer Multiply DPI (default=disabled)
echo "===========Testing Integer Multiply DPI configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --imul_dpi --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

# Integer Divide DPI (default=disabled)
echo "===========Testing Integer Divide DPI configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --idiv_dpi --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

# DPI Disable (default=disabled)
echo "===========Testing DPI Disable configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --dpi_disable --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --perf=2"

echo "==========I/O Configuration Tests=========="

# IO Console Output Size (default assumed=64)
echo "===========Testing IO Console Output Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --io_cout_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_cout_size=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_cout_size=128 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_cout_size=256 --perf=2"

# IO MPM Size (default assumed=64)
echo "===========Testing IO MPM Size configurations==========="
run_test "./ci/blackboxthree.sh --app=$app --io_mpm_size=32 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_mpm_size=64 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_mpm_size=128 --perf=2"
run_test "./ci/blackboxthree.sh --app=$app --io_mpm_size=256 --perf=2"
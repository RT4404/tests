#!/bin/bash

# Function to sanitize command for filename
sanitize_filename() {
  echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g'
}

# Function to run a test and log the output
run_test() {
    local dynamic_parts=$1
    local log_dir=$2

    # Static parts of the command
    local static_parts="./ci/blackboxthree.sh --app=$app --perf=2 --args=\"$args\" --driver=$driver"

    # Construct the full command
    local full_command="$static_parts $dynamic_parts"

    # Ensure the log directory exists
    mkdir -p "$log_dir"

    # Sanitize the dynamic part for log filename
    local sanitized_command=$(sanitize_filename "$dynamic_parts")
    local logfile="$log_dir/${sanitized_command}.log"

    # Run the test and log output
    echo "Running test: $full_command"
    echo "Logging to: $logfile"
    $full_command >> "$logfile" 2>&1
}

# Configurable variables for testing
app="vecadd" #replace with desired tests e.g guassian and sgemm
args="-n32"
driver="simx"

# Create a new directory with a timestamp
TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")
ROOT_DIR="RESULTS/$driver/$app/$args"
mkdir -p "$ROOT_DIR"

############
# BASELINE #
############
DIR="$ROOT_DIR/baseline"
run_test "--cores=1 --clusters=1 --warps=4 --threads=4" "$DIR"

#################
# BASIC TESTING #
#################

# Cores
echo "===========Testing basic core configurations==========="
DIR="$ROOT_DIR/cores"
run_test "--cores=1" "$DIR"
run_test "--cores=2" "$DIR"
run_test "--cores=4" "$DIR"
run_test "--cores=8" "$DIR"

# Clusters
echo "===========Testing basic cluster configurations==========="
DIR="$ROOT_DIR/clusters"
run_test "--clusters=1" "$DIR"
run_test "--clusters=2" "$DIR"
run_test "--clusters=4" "$DIR"
run_test "--clusters=8" "$DIR"

# Warps
DIR="$ROOT_DIR/warps"
echo "===========Testing basic warp configurations==========="
run_test "--warps=4" "$DIR"
run_test "--warps=8" "$DIR"
run_test "--warps=16" "$DIR"
run_test "--warps=32" "$DIR"

# Threads
DIR="$ROOT_DIR/threads"
echo "===========Testing basic thread configurations==========="
run_test "--threads=4" "$DIR"
run_test "--threads=8" "$DIR"
run_test "--threads=16" "$DIR"
run_test "--threads=32" "$DIR"

#################
# CACHE TESTING #
#################

# L1 Cache Off
DIR="$ROOT_DIR/L1"
echo "===========Testing L1 Cache Off==========="
run_test "--l1cache_off" "$DIR"
run_test "--l1cache_off --cores=4" "$DIR"
run_test "--l1cache_off --clusters=4" "$DIR"
run_test "--l1cache_off --cores=4 --clusters=4" "$DIR"

# L2 Cache on
echo "===========Testing basic core configurations==========="
DIR="$ROOT_DIR/L2"
run_test "--cores=1 --l2cache" "$DIR"
run_test "--cores=2 --l2cache" "$DIR"
run_test "--cores=4 --l2cache" "$DIR"
run_test "--cores=8 --l2cache" "$DIR"

# L3 Cache on
echo "===========Testing basic cluster configurations==========="
DIR="$ROOT_DIR/L3"
run_test "--clusters=1 --l3cache" "$DIR"
run_test "--clusters=2 --l3cache" "$DIR"
run_test "--clusters=4 --l3cache" "$DIR"
run_test "--clusters=8 --l3cache" "$DIR"

################################
# CURATED COMBINATIONS TESTING #
################################

echo "===========Curated Combinations==========="

echo "===========Core and Cluster Combinations==========="
DIR="$ROOT_DIR/Core_Cluster_Combinations"
run_test "--cores=2 --clusters=1" "$DIR"
run_test "--cores=8 --clusters=1" "$DIR"
run_test "--cores=4 --clusters=4" "$DIR" 
run_test "--cores=2 --clusters=8" "$DIR"
run_test "--cores=8 --clusters=8" "$DIR"

echo "===========Cache Configurations==========="
DIR="$ROOT_DIR/Cache_Combinations"
run_test "--cores=4 --clusters=1 --l2cache" "$DIR"
run_test "--cores=8 --clusters=1 --l2cache" "$DIR"
run_test "--cores=4 --clusters=4 --l3cache" "$DIR"
run_test "--cores=8 --clusters=8 --l2cache --l3cache" "$DIR"
run_test "--cores=2 --clusters=2 --threads=16 --l2cache --l3cache" "$DIR"
run_test "--cores=4 --clusters=4 --threads=32 --warps=16 --l2cache --l3cache" "$DIR"
run_test "--cores=8 --clusters=8 --threads=64 --warps=32 --l2cache --l3cache" "$DIR"
run_test "--cores=8 --clusters=2 --threads=32 --warps=32 --l2cache --l3cache" "$DIR"

echo "===========Thread and Warp Configurations==========="
DIR="$ROOT_DIR/Core_Threads_Warps_Combinations"
run_test "--cores=4 --threads=8 --warps=4" "$DIR"
run_test "--cores=4 --threads=16 --warps=8" "$DIR"
run_test "--cores=4 --threads=24 --warps=12" "$DIR"
run_test "--cores=4 --threads=32 --warps=16" "$DIR"

echo "===========Stress Testing==========="
DIR="$ROOT_DIR/Stress"
run_test "--cores=8 --clusters=4 --threads=32 --warps=32 --l2cache --l3cache" "$DIR"

#########################################
# The rest of the configuration options #
#########################################

echo "==========All configuration options isolation testing (unstable)=========="

# Number of ICaches (default=1)
DIR="$ROOT_DIR/num_icaches"
echo "===========Testing Number of ICaches configurations==========="
run_test "--num_icaches=1" "$DIR"
run_test "--num_icaches=2" "$DIR"
run_test "--num_icaches=4" "$DIR"
run_test "--num_icaches=8" "$DIR"

# ICache Size (default=16384)
DIR="$ROOT_DIR/icache_size"
echo "===========Testing ICache Size configurations==========="
run_test "--icache_size=8192" "$DIR"
run_test "--icache_size=16384" "$DIR"
run_test "--icache_size=32768" "$DIR"
run_test "--icache_size=65536" "$DIR"

# ICache Ways (default=2)
DIR="$ROOT_DIR/icache_ways"
echo "===========Testing ICache Ways configurations==========="
run_test "--icache_ways=1" "$DIR"
run_test "--icache_ways=2" "$DIR"
run_test "--icache_ways=4" "$DIR"
run_test "--icache_ways=8" "$DIR"

# ICache Memory Request Queue Size (default=4)
DIR="$ROOT_DIR/icache_mreq_size"
echo "===========Testing ICache MReq Size configurations==========="
run_test "--icache_mreq_size=2" "$DIR"
run_test "--icache_mreq_size=4" "$DIR"
run_test "--icache_mreq_size=8" "$DIR"
run_test "--icache_mreq_size=16" "$DIR"

# ICache Miss Status Holding Register Size (default=16)
DIR="$ROOT_DIR/icache_mshr_size"
echo "===========Testing ICache MSHR Size configurations==========="
run_test "--icache_mshr_size=8" "$DIR"
run_test "--icache_mshr_size=16" "$DIR"
run_test "--icache_mshr_size=32" "$DIR"
run_test "--icache_mshr_size=64" "$DIR"

# ICache Core Response Queue Size (default=2)
DIR="$ROOT_DIR/icache_crsq_size"
echo "===========Testing ICache CRSQ Size configurations==========="
run_test "--icache_crsq_size=1" "$DIR"
run_test "--icache_crsq_size=2" "$DIR"
run_test "--icache_crsq_size=4" "$DIR"
run_test "--icache_crsq_size=8" "$DIR"

# ICache Memory Response Queue Size (default=0)
DIR="$ROOT_DIR/icache_mrsq_size"
echo "===========Testing ICache MRSQ Size configurations==========="
run_test "--icache_mrsq_size=0" "$DIR"
run_test "--icache_mrsq_size=1" "$DIR"
run_test "--icache_mrsq_size=2" "$DIR"
run_test "--icache_mrsq_size=4" "$DIR"

# Number of DCaches (default=2)
DIR="$ROOT_DIR/num_dcaches"
echo "===========Testing Number of DCaches configurations==========="
run_test "--num_dcaches=1" "$DIR"
run_test "--num_dcaches=2" "$DIR"
run_test "--num_dcaches=4" "$DIR"
run_test "--num_dcaches=8" "$DIR"

# DCache Writeback (default=disabled)
DIR="$ROOT_DIR/dcache_writeback"
echo "===========Testing DCache Writeback configurations==========="
run_test "--dcache_writeback=0" "$DIR"
run_test "--dcache_writeback=1" "$DIR"

# DCache Size (default=16384)
DIR="$ROOT_DIR/dcache_size"
echo "===========Testing DCache Size configurations==========="
run_test "--dcache_size=8192" "$DIR"
run_test "--dcache_size=16384" "$DIR"
run_test "--dcache_size=32768" "$DIR"
run_test "--dcache_size=65536" "$DIR"

# DCache Ways (default=2)
DIR="$ROOT_DIR/dcache_ways"
echo "===========Testing DCache Ways configurations==========="
run_test "--dcache_ways=1" "$DIR"
run_test "--dcache_ways=2" "$DIR"
run_test "--dcache_ways=4" "$DIR"
run_test "--dcache_ways=8" "$DIR"

# DCache MReq Size (default=4)
DIR="$ROOT_DIR/dcache_mreq_size"
echo "===========Testing DCache MReq Size configurations==========="
run_test "--dcache_mreq_size=2" "$DIR"
run_test "--dcache_mreq_size=4" "$DIR"
run_test "--dcache_mreq_size=8" "$DIR"
run_test "--dcache_mreq_size=16" "$DIR"

# DCache MSHR Size (default=16)
DIR="$ROOT_DIR/dcache_mshr_size"
echo "===========Testing DCache MSHR Size configurations==========="
run_test "--dcache_mshr_size=8" "$DIR"
run_test "--dcache_mshr_size=16" "$DIR"
run_test "--dcache_mshr_size=32" "$DIR"
run_test "--dcache_mshr_size=64" "$DIR"

# DCache Core Response Queue Size (default=2)
DIR="$ROOT_DIR/dcache_crsq_size"
echo "===========Testing DCache CRSQ Size configurations==========="
run_test "--dcache_crsq_size=1" "$DIR"
run_test "--dcache_crsq_size=2" "$DIR"
run_test "--dcache_crsq_size=4" "$DIR"
run_test "--dcache_crsq_size=8" "$DIR"

# DCache Memory Response Queue Size (default=0)
DIR="$ROOT_DIR/dcache_mrsq_size"
echo "===========Testing DCache MRSQ Size configurations==========="
run_test "--dcache_mrsq_size=0" "$DIR"
run_test "--dcache_mrsq_size=1" "$DIR"
run_test "--dcache_mrsq_size=2" "$DIR"
run_test "--dcache_mrsq_size=4" "$DIR"

# DCache Banks (default=2)
DIR="$ROOT_DIR/dcache_banks"
echo "===========Testing DCache Banks configurations==========="
run_test "--dcache_banks=1" "$DIR"
run_test "--dcache_banks=2" "$DIR"
run_test "--dcache_banks=4" "$DIR"
run_test "--dcache_banks=8" "$DIR"

# L2 Writeback (default=disabled)
DIR="$ROOT_DIR/l2_writeback"
echo "===========Testing L2 Writeback configurations==========="
run_test "--l2_writeback=0 --l2cache --cores=4" "$DIR"
run_test "--l2_writeback=1 --l2cache --cores=4" "$DIR"

# L2 Cache Size (default=1048576)
DIR="$ROOT_DIR/l2_size"
echo "===========Testing L2 Cache Size configurations==========="
run_test "--l2_size=524288 --l2cache --cores=4" "$DIR"
run_test "--l2_size=1048576 --l2cache --cores=4" "$DIR"
run_test "--l2_size=2097152 --l2cache --cores=4" "$DIR"
run_test "--l2_size=4194304 --l2cache --cores=4" "$DIR"

# L2 Ways (default=2)
DIR="$ROOT_DIR/l2_ways"
echo "===========Testing L2 Ways configurations==========="
run_test "--l2_ways=1 --l2cache --cores=4" "$DIR"
run_test "--l2_ways=2 --l2cache --cores=4" "$DIR"
run_test "--l2_ways=4 --l2cache --cores=4" "$DIR"
run_test "--l2_ways=8 --l2cache --cores=4" "$DIR"

# L2 MReq Size (default=4)
DIR="$ROOT_DIR/l2_mreq_size"
echo "===========Testing L2 MReq Size configurations==========="
run_test "--l2_mreq_size=2 --l2cache --cores=4" "$DIR"
run_test "--l2_mreq_size=4 --l2cache --cores=4" "$DIR"
run_test "--l2_mreq_size=8 --l2cache --cores=4" "$DIR"
run_test "--l2_mreq_size=16 --l2cache --cores=4" "$DIR"

# L2 MSHR Size (default=16)
DIR="$ROOT_DIR/l2_mshr_size"
echo "===========Testing L2 MSHR Size configurations==========="
run_test "--l2_mshr_size=8 --l2cache --cores=4" "$DIR"
run_test "--l2_mshr_size=16 --l2cache --cores=4" "$DIR"
run_test "--l2_mshr_size=32 --l2cache --cores=4" "$DIR"
run_test "--l2_mshr_size=64 --l2cache --cores=4" "$DIR"

# L2 Core Response Queue Size (default=2)
DIR="$ROOT_DIR/l2_crsq_size"
echo "===========Testing L2 CRSQ Size configurations==========="
run_test "--l2_crsq_size=1 --l2cache --cores=4" "$DIR"
run_test "--l2_crsq_size=2 --l2cache --cores=4" "$DIR"
run_test "--l2_crsq_size=4 --l2cache --cores=4" "$DIR"
run_test "--l2_crsq_size=8 --l2cache --cores=4" "$DIR"

# L2 Memory Response Queue Size (default=0)
DIR="$ROOT_DIR/l2_mrsq_size"
echo "===========Testing L2 MRSQ Size configurations==========="
run_test "--l2_mrsq_size=0 --l2cache --cores=4" "$DIR"
run_test "--l2_mrsq_size=1 --l2cache --cores=4" "$DIR"
run_test "--l2_mrsq_size=2 --l2cache --cores=4" "$DIR"
run_test "--l2_mrsq_size=4 --l2cache --cores=4" "$DIR"

# L2 Banks (default=4)
DIR="$ROOT_DIR/l2_banks"
echo "===========Testing L2 Banks configurations==========="
run_test "--l2_banks=2 --l2cache --cores=4" "$DIR"
run_test "--l2_banks=4 --l2cache --cores=4" "$DIR"
run_test "--l2_banks=8 --l2cache --cores=4" "$DIR"
run_test "--l2_banks=16 --l2cache --cores=4" "$DIR"

# L3 Writeback (default=disabled)
DIR="$ROOT_DIR/l3_writeback"
echo "===========Testing L3 Writeback configurations==========="
run_test "--l3_writeback=0 --l3cache --clusters=4" "$DIR"
run_test "--l3_writeback=1 --l3cache --clusters=4" "$DIR"

# L3 Cache Size (default=1048576)
DIR="$ROOT_DIR/l3_size"
echo "===========Testing L3 Cache Size configurations==========="
run_test "--l3_size=524288 --l3cache --clusters=4" "$DIR"
run_test "--l3_size=1048576 --l3cache --clusters=4" "$DIR"
run_test "--l3_size=2097152 --l3cache --clusters=4" "$DIR"
run_test "--l3_size=4194304 --l3cache --clusters=4" "$DIR"

# L3 Ways (default=4)
DIR="$ROOT_DIR/l3_ways"
echo "===========Testing L3 Ways configurations==========="
run_test "--l3_ways=2 --l3cache --clusters=4" "$DIR"
run_test "--l3_ways=4 --l3cache --clusters=4" "$DIR"
run_test "--l3_ways=8 --l3cache --clusters=4" "$DIR"
run_test "--l3_ways=16 --l3cache --clusters=4" "$DIR"

# L3 MReq Size (default=4)
DIR="$ROOT_DIR/l3_mreq_size"
echo "===========Testing L3 MReq Size configurations==========="
run_test "--l3_mreq_size=2 --l3cache --clusters=4" "$DIR"
run_test "--l3_mreq_size=4 --l3cache --clusters=4" "$DIR"
run_test "--l3_mreq_size=8 --l3cache --clusters=4" "$DIR"
run_test "--l3_mreq_size=16 --l3cache --clusters=4" "$DIR"

# L3 MSHR Size (default=16)
DIR="$ROOT_DIR/l3_mshr_size"
echo "===========Testing L3 MSHR Size configurations==========="
run_test "--l3_mshr_size=8 --l3cache --clusters=4" "$DIR"
run_test "--l3_mshr_size=16 --l3cache --clusters=4" "$DIR"
run_test "--l3_mshr_size=32 --l3cache --clusters=4" "$DIR"
run_test "--l3_mshr_size=64 --l3cache --clusters=4" "$DIR"

# L3 Core Response Queue Size (default=2)
DIR="$ROOT_DIR/l3_crsq_size"
echo "===========Testing L3 CRSQ Size configurations==========="
run_test "--l3_crsq_size=1 --l3cache --clusters=4" "$DIR"
run_test "--l3_crsq_size=2 --l3cache --clusters=4" "$DIR"
run_test "--l3_crsq_size=4 --l3cache --clusters=4" "$DIR"
run_test "--l3_crsq_size=8 --l3cache --clusters=4" "$DIR"

# L3 Memory Response Queue Size (default=0)
DIR="$ROOT_DIR/l3_mrsq_size"
echo "===========Testing L3 MRSQ Size configurations==========="
run_test "--l3_mrsq_size=0 --l3cache --clusters=4" "$DIR"
run_test "--l3_mrsq_size=1 --l3cache --clusters=4" "$DIR"
run_test "--l3_mrsq_size=2 --l3cache --clusters=4" "$DIR"
run_test "--l3_mrsq_size=4 --l3cache --clusters=4" "$DIR"

# L3 Banks (default=8)
DIR="$ROOT_DIR/l3_banks"
echo "===========Testing L3 Banks configurations==========="
run_test "--l3_banks=4 --l3cache --clusters=4" "$DIR"
run_test "--l3_banks=8 --l3cache --clusters=4" "$DIR"
run_test "--l3_banks=16 --l3cache --clusters=4" "$DIR"
run_test "--l3_banks=32 --l3cache --clusters=4" "$DIR"

# Memory Banks (default=2)
DIR="$ROOT_DIR/memory_banks"
echo "===========Testing Memory Banks configurations==========="
run_test "--memory_banks=1" "$DIR"
run_test "--memory_banks=2" "$DIR"
run_test "--memory_banks=4" "$DIR"
run_test "--memory_banks=8" "$DIR"

# Number of Memory Ports (default=2)
DIR="$ROOT_DIR/num_mem_ports"
echo "===========Testing Number of Memory Ports configurations==========="
run_test "--num_mem_ports=1" "$DIR"
run_test "--num_mem_ports=2" "$DIR"
run_test "--num_mem_ports=4" "$DIR"
run_test "--num_mem_ports=8" "$DIR"

# Memory Block Size (default=64)
DIR="$ROOT_DIR/mem_block_size"
echo "===========Testing Memory Block Size configurations==========="
run_test "--mem_block_size=32" "$DIR"
run_test "--mem_block_size=64" "$DIR"
run_test "--mem_block_size=128" "$DIR"
run_test "--mem_block_size=256" "$DIR"

# Memory Address Width (default=32, 48 with XLEN_64)
DIR="$ROOT_DIR/mem_addr_width"
echo "===========Testing Memory Address Width configurations==========="
run_test "--mem_addr_width=16" "$DIR"
run_test "--mem_addr_width=32" "$DIR"
run_test "--mem_addr_width=48" "$DIR"

# Stack Log2 Size (default=13)
DIR="$ROOT_DIR/stack_log2_size"
echo "===========Testing Stack Log2 Size configurations==========="
run_test "--stack_log2_size=12" "$DIR"
run_test "--stack_log2_size=13" "$DIR"
run_test "--stack_log2_size=14" "$DIR"
run_test "--stack_log2_size=16" "$DIR"

# Stack Size (default=8192)
DIR="$ROOT_DIR/stack_size"
echo "===========Testing Stack Size configurations==========="
run_test "--stack_size=4096" "$DIR"
run_test "--stack_size=8192" "$DIR"
run_test "--stack_size=16384" "$DIR"
run_test "--stack_size=32768" "$DIR"

# Stack Base Address (default=0xFF000000, 0x1FF000000 with XLEN_64)
DIR="$ROOT_DIR/stack_base_addr"
echo "===========Testing Stack Base Address configurations==========="
run_test "--stack_base_addr=0x10000000" "$DIR"
run_test "--stack_base_addr=0x20000000" "$DIR"
run_test "--stack_base_addr=0x30000000" "$DIR"

# Startup Address (default=0x80000000, 0x180000000 with XLEN_64)
DIR="$ROOT_DIR/startup_addr"
echo "===========Testing Startup Address configurations==========="
run_test "--startup_addr=0x10000000" "$DIR"
run_test "--startup_addr=0x20000000" "$DIR"
run_test "--startup_addr=0x30000000" "$DIR"

# User Base Address
DIR="$ROOT_DIR/user_base_addr"
echo "===========Testing User Base Address configurations==========="
run_test "--user_base_addr=0x00000000" "$DIR"
run_test "--user_base_addr=0x00010000" "$DIR"
run_test "--user_base_addr=0x00100000" "$DIR"
run_test "--user_base_addr=0x01000000" "$DIR"

# IO Base Address
DIR="$ROOT_DIR/io_base_addr"
echo "===========Testing IO Base Address configurations==========="
run_test "--io_base_addr=0x20000000" "$DIR"
run_test "--io_base_addr=0x30000000" "$DIR"
run_test "--io_base_addr=0x40000000" "$DIR"

# Page Table Base Address
DIR="$ROOT_DIR/page_table_base_addr"
echo "===========Testing Page Table Base Address configurations==========="
run_test "--page_table_base_addr=0x00000000" "$DIR"
run_test "--page_table_base_addr=0x40000000" "$DIR"
run_test "--page_table_base_addr=0x80000000" "$DIR"
run_test "--page_table_base_addr=0xC0000000" "$DIR"

# Memory Page Size (default=4096)
DIR="$ROOT_DIR/mem_page_size"
echo "===========Testing Memory Page Size configurations==========="
run_test "--mem_page_size=1024" "$DIR"
run_test "--mem_page_size=2048" "$DIR"
run_test "--mem_page_size=4096" "$DIR"
run_test "--mem_page_size=8192" "$DIR"

# Memory Page Log2 Size (default=12)
DIR="$ROOT_DIR/mem_page_log2_size"
echo "===========Testing Memory Page Log2 Size configurations==========="
run_test "--mem_page_log2_size=10" "$DIR"
run_test "--mem_page_log2_size=12" "$DIR"
run_test "--mem_page_log2_size=13" "$DIR"
run_test "--mem_page_log2_size=14" "$DIR"

# Local Memory Enable/Disable (default=enabled)
DIR="$ROOT_DIR/lmem_enable"
echo "===========Testing Local Memory Enable configurations==========="
run_test "--lmem_enable" "$DIR"

# Local Memory Base Address
DIR="$ROOT_DIR/lmem_base_addr"
echo "===========Testing Local Memory Base Address configurations==========="
run_test "--lmem_base_addr=0x10000000" "$DIR"
run_test "--lmem_base_addr=0x20000000" "$DIR"
run_test "--lmem_base_addr=0x30000000" "$DIR"
run_test "--lmem_base_addr=0x40000000" "$DIR"

# Local Memory Log Size
DIR="$ROOT_DIR/lmem_log_size"
echo "===========Testing Local Memory Log Size configurations==========="
run_test "--lmem_log_size=10" "$DIR"
run_test "--lmem_log_size=12" "$DIR"
run_test "--lmem_log_size=14" "$DIR"
run_test "--lmem_log_size=16" "$DIR"

# Local Memory Number of Banks
DIR="$ROOT_DIR/lmem_num_banks"
echo "===========Testing Local Memory Number of Banks configurations==========="
run_test "--lmem_num_banks=1" "$DIR"
run_test "--lmem_num_banks=4" "$DIR"
run_test "--lmem_num_banks=8" "$DIR"
run_test "--lmem_num_banks=16" "$DIR"

# ALU Lanes (default=4)
DIR="$ROOT_DIR/num_alu_lanes"
echo "===========Testing ALU Lanes configurations==========="
run_test "--num_alu_lanes=2" "$DIR"
run_test "--num_alu_lanes=4" "$DIR"
run_test "--num_alu_lanes=8" "$DIR"
run_test "--num_alu_lanes=16" "$DIR"

# FPU Lanes (default=4)
DIR="$ROOT_DIR/num_fpu_lanes"
echo "===========Testing FPU Lanes configurations==========="
run_test "--num_fpu_lanes=2" "$DIR"
run_test "--num_fpu_lanes=4" "$DIR"
run_test "--num_fpu_lanes=8" "$DIR"
run_test "--num_fpu_lanes=16" "$DIR"

# LSU Lanes (default=4)
DIR="$ROOT_DIR/num_lsu_lanes"
echo "===========Testing LSU Lanes configurations==========="
run_test "--num_lsu_lanes=1" "$DIR"
run_test "--num_lsu_lanes=2" "$DIR"
run_test "--num_lsu_lanes=4" "$DIR"
run_test "--num_lsu_lanes=8" "$DIR"

# SFU Lanes (default=4)
DIR="$ROOT_DIR/num_sfu_lanes"
echo "===========Testing SFU Lanes configurations==========="
run_test "--num_sfu_lanes=1" "$DIR"
run_test "--num_sfu_lanes=2" "$DIR"
run_test "--num_sfu_lanes=4" "$DIR"
run_test "--num_sfu_lanes=8" "$DIR"

# ALU Blocks (default=4)
DIR="$ROOT_DIR/num_alu_blocks"
echo "===========Testing ALU Blocks configurations==========="
run_test "--num_alu_blocks=1" "$DIR"
run_test "--num_alu_blocks=2" "$DIR"
run_test "--num_alu_blocks=4" "$DIR"
run_test "--num_alu_blocks=8" "$DIR"

# FPU Blocks (default=4)
DIR="$ROOT_DIR/num_fpu_blocks"
echo "===========Testing FPU Blocks configurations==========="
run_test "--num_fpu_blocks=1" "$DIR"
run_test "--num_fpu_blocks=2" "$DIR"
run_test "--num_fpu_blocks=4" "$DIR"
run_test "--num_fpu_blocks=8" "$DIR"

# LSU Blocks (default=1)
DIR="$ROOT_DIR/num_lsu_blocks"
echo "===========Testing LSU Blocks configurations==========="
run_test "--num_lsu_blocks=1" "$DIR"
run_test "--num_lsu_blocks=2" "$DIR"
run_test "--num_lsu_blocks=4" "$DIR"
run_test "--num_lsu_blocks=8" "$DIR"

# SFU Blocks (default=1)
DIR="$ROOT_DIR/num_sfu_blocks"
echo "===========Testing SFU Blocks configurations==========="
run_test "--num_sfu_blocks=1" "$DIR"
run_test "--num_sfu_blocks=2" "$DIR"
run_test "--num_sfu_blocks=4" "$DIR"
run_test "--num_sfu_blocks=8" "$DIR"


# Issue Width (default=4)
DIR="$ROOT_DIR/issue_width"
echo "===========Testing Issue Width configurations==========="
run_test "--issue_width=2" "$DIR"
run_test "--issue_width=4" "$DIR"
run_test "--issue_width=8" "$DIR"
run_test "--issue_width=16" "$DIR"

# Instruction Buffer Size (default=2)
DIR="$ROOT_DIR/ibuf_size"
echo "===========Testing Instruction Buffer Size configurations==========="
run_test "--ibuf_size=1" "$DIR"
run_test "--ibuf_size=2" "$DIR"
run_test "--ibuf_size=4" "$DIR"
run_test "--ibuf_size=8" "$DIR"

# LSU Line Size
DIR="$ROOT_DIR/lsu_line_size"
echo "===========Testing LSU Line Size configurations==========="
run_test "--lsu_line_size=32" "$DIR"
run_test "--lsu_line_size=64" "$DIR"
run_test "--lsu_line_size=128" "$DIR"
run_test "--lsu_line_size=256" "$DIR"

# LSU Queue Input Size (default=2)
DIR="$ROOT_DIR/lsuq_in_size"
echo "===========Testing LSU Queue Input Size configurations==========="
run_test "--lsuq_in_size=1" "$DIR"
run_test "--lsuq_in_size=2" "$DIR"
run_test "--lsuq_in_size=4" "$DIR"
run_test "--lsuq_in_size=8" "$DIR"

# LSU Queue Output Size
DIR="$ROOT_DIR/lsuq_out_size"
echo "===========Testing LSU Queue Output Size configurations==========="
run_test "--lsuq_out_size=1" "$DIR"
run_test "--lsuq_out_size=2" "$DIR"
run_test "--lsuq_out_size=4" "$DIR"
run_test "--lsuq_out_size=8" "$DIR"

# Global Barrier Enable
DIR="$ROOT_DIR/gbar_enable"
echo "===========Testing Global Barrier Enable configurations==========="
run_test "--gbar_enable" "$DIR"


# Virtual Memory Enable (default=disabled)
DIR="$ROOT_DIR/vm_enable"
echo "===========Testing Virtual Memory Enable configurations==========="
run_test "--vm_enable" "$DIR"


# VM Address Mode (default=32)
DIR="$ROOT_DIR/vm_addr_mode"
echo "===========Testing VM Address Mode configurations==========="
run_test "--vm_enable --vm_addr_mode=32" "$DIR"
run_test "--vm_enable --vm_addr_mode=36" "$DIR"
run_test "--vm_enable --vm_addr_mode=48" "$DIR"
run_test "--vm_enable --vm_addr_mode=64" "$DIR"

# Page Table Level (default=2)
DIR="$ROOT_DIR/pt_level"
echo "===========Testing Page Table Level configurations==========="
run_test "--vm_enable --pt_level=1" "$DIR"
run_test "--vm_enable --pt_level=2" "$DIR"
run_test "--vm_enable --pt_level=3" "$DIR"
run_test "--vm_enable --pt_level=4" "$DIR"

# Page Table Entry Size (default=8)
DIR="$ROOT_DIR/pte_size"
echo "===========Testing Page Table Entry Size configurations==========="
run_test "--vm_enable --pte_size=4" "$DIR"
run_test "--vm_enable --pte_size=8" "$DIR"
run_test "--vm_enable --pte_size=16" "$DIR"

# Number of PTE Entries (default=128)
DIR="$ROOT_DIR/num_pte_entry"
echo "===========Testing Number of PTE Entries configurations==========="
run_test "--vm_enable --num_pte_entry=64" "$DIR"
run_test "--vm_enable --num_pte_entry=128" "$DIR"
run_test "--vm_enable --num_pte_entry=256" "$DIR"
run_test "--vm_enable --num_pte_entry=512" "$DIR"

# Page Table Size Limit (default=4096)
DIR="$ROOT_DIR/pt_size_limit"
echo "===========Testing Page Table Size Limit configurations==========="
run_test "--vm_enable --pt_size_limit=1024" "$DIR"
run_test "--vm_enable --pt_size_limit=2048" "$DIR"
run_test "--vm_enable --pt_size_limit=4096" "$DIR"
run_test "--vm_enable --pt_size_limit=8192" "$DIR"

# Page Table Size (default=4096)
DIR="$ROOT_DIR/pt_size"
echo "===========Testing Page Table Size configurations==========="
run_test "--vm_enable --pt_size=1024" "$DIR"
run_test "--vm_enable --pt_size=2048" "$DIR"
run_test "--vm_enable --pt_size=4096" "$DIR"
run_test "--vm_enable --pt_size=8192" "$DIR"

# TLB Size (default=64)
DIR="$ROOT_DIR/tlb_size"
echo "===========Testing TLB Size configurations==========="
run_test "--vm_enable --tlb_size=16" "$DIR"
run_test "--vm_enable --tlb_size=32" "$DIR"
run_test "--vm_enable --tlb_size=64" "$DIR"
run_test "--vm_enable --tlb_size=128" "$DIR"

# Integer Multiply/Divide Extension (M) (default=enabled)
DIR="$ROOT_DIR/ext_m"
echo "===========Testing Integer Multiply/Divide Extension configurations==========="

run_test "--ext_m_disable" "$DIR"

# Single Precision Floating-Point Extension (F) (default=enabled)
DIR="$ROOT_DIR/ext_f"
echo "===========Testing Single Precision Floating-Point Extension configurations==========="

run_test "--ext_f_disable" "$DIR"

# Double Precision Floating-Point Extension (D) (default=enabled)
DIR="$ROOT_DIR/ext_d"
echo "===========Testing Double Precision Floating-Point Extension configurations==========="

run_test "--ext_d_disable" "$DIR"

# Compressed Extension (C) (default=enabled)
DIR="$ROOT_DIR/ext_c"
echo "===========Testing Compressed Extension configurations==========="

run_test "--ext_c_disable" "$DIR"

# Atomic Instructions Extension (A) (default=enabled)
DIR="$ROOT_DIR/ext_a"
echo "===========Testing Atomic Instructions Extension configurations==========="

run_test "--ext_a_disable" "$DIR"

# Conditional Operations Extension (ZICOND) (default=enabled)
DIR="$ROOT_DIR/ext_zicond"
echo "===========Testing Conditional Operations Extension configurations==========="

run_test "--ext_zicond_disable" "$DIR"

# Tensor Core Size (default=8)
DIR="$ROOT_DIR/tc_size"
echo "===========Testing Tensor Core Size configurations==========="
run_test "--tc_size=8" "$DIR"
run_test "--tc_size=32" "$DIR"
run_test "--tc_size=64" "$DIR"
run_test "--tc_size=128" "$DIR"

# Number of Tensor Cores (default=4)
DIR="$ROOT_DIR/tc_num"
echo "===========Testing Number of Tensor Cores configurations==========="
run_test "--tc_num=2" "$DIR"
run_test "--tc_num=4" "$DIR"
run_test "--tc_num=8" "$DIR"
run_test "--tc_num=16" "$DIR"

# Number of TCU Lanes (default=4)
DIR="$ROOT_DIR/num_tcu_lanes"
echo "===========Testing Number of TCU Lanes configurations==========="
run_test "--num_tcu_lanes=2" "$DIR"
run_test "--num_tcu_lanes=4" "$DIR"
run_test "--num_tcu_lanes=8" "$DIR"
run_test "--num_tcu_lanes=16" "$DIR"

# Number of TCU Blocks (default=4)
DIR="$ROOT_DIR/num_tcu_blocks"
echo "===========Testing Number of TCU Blocks configurations==========="
run_test "--num_tcu_blocks=1" "$DIR"
run_test "--num_tcu_blocks=2" "$DIR"
run_test "--num_tcu_blocks=4" "$DIR"
run_test "--num_tcu_blocks=8" "$DIR"

# Floating-Point Unit DPI (default=disabled)
DIR="$ROOT_DIR/fpu_dpi"
echo "===========Testing FPU DPI configurations==========="
run_test "--fpu_dpi" "$DIR"


# Integer Multiply DPI (default=disabled)
DIR="$ROOT_DIR/imul_dpi"
echo "===========Testing Integer Multiply DPI configurations==========="
run_test "--imul_dpi" "$DIR"


# Integer Divide DPI (default=disabled)
DIR="$ROOT_DIR/idiv_dpi"
echo "===========Testing Integer Divide DPI configurations==========="
run_test "--idiv_dpi" "$DIR"


# DPI Disable (default=disabled)
DIR="$ROOT_DIR/dpi_disable"
echo "===========Testing DPI Disable configurations==========="
run_test "--dpi_disable" "$DIR"


# IO Console Output Size (default assumed=64)
DIR="$ROOT_DIR/io_cout_size"
echo "===========Testing IO Console Output Size configurations==========="
run_test "--io_cout_size=32" "$DIR"
run_test "--io_cout_size=64" "$DIR"
run_test "--io_cout_size=128" "$DIR"
run_test "--io_cout_size=256" "$DIR"

# IO MPM Size (default assumed=64)
DIR="$ROOT_DIR/io_mpm_size"
echo "===========Testing IO MPM Size configurations==========="
run_test "--io_mpm_size=32" "$DIR"
run_test "--io_mpm_size=64" "$DIR"
run_test "--io_mpm_size=128" "$DIR"
run_test "--io_mpm_size=256" "$DIR"

# FPU Queue Size (default=4)
DIR="$ROOT_DIR/fpuq_size"
echo "===========Testing FPU Queue Size configurations==========="
run_test "--fpuq_size=4" "$DIR"
run_test "--fpuq_size=8" "$DIR"
run_test "--fpuq_size=16" "$DIR"
run_test "--fpuq_size=32" "$DIR"

# Integer Multiplication Latency (IMUL) (default=4)
DIR="$ROOT_DIR/latency_imul"
echo "===========Testing Integer Multiplication Latency configurations==========="
run_test "--latency_imul=2" "$DIR"
run_test "--latency_imul=4" "$DIR"
run_test "--latency_imul=6" "$DIR"
run_test "--latency_imul=8" "$DIR"

# Fused Multiply-Add Latency (FMA) (default=4)
DIR="$ROOT_DIR/latency_fma"
echo "===========Testing Fused Multiply-Add Latency configurations==========="
run_test "--latency_fma=2" "$DIR"
run_test "--latency_fma=4" "$DIR"
run_test "--latency_fma=6" "$DIR"
run_test "--latency_fma=8" "$DIR"

# Floating-Point Division Latency (FDIV) (default=16)
DIR="$ROOT_DIR/latency_fdiv"
echo "===========Testing Floating-Point Division Latency configurations==========="
run_test "--latency_fdiv=8" "$DIR"
run_test "--latency_fdiv=16" "$DIR"
run_test "--latency_fdiv=24" "$DIR"
run_test "--latency_fdiv=32" "$DIR"

# Floating-Point Square Root Latency (FSQRT) (default=16)
DIR="$ROOT_DIR/latency_fsqrt"
echo "===========Testing Floating-Point Square Root Latency configurations==========="
run_test "--latency_fsqrt=8" "$DIR"
run_test "--latency_fsqrt=16" "$DIR"
run_test "--latency_fsqrt=24" "$DIR"
run_test "--latency_fsqrt=32" "$DIR"

# Floating-Point Conversion Latency (FCVT) (default=5)
DIR="$ROOT_DIR/latency_fcvt"
echo "===========Testing Floating-Point Conversion Latency configurations==========="
run_test "--latency_fcvt=3" "$DIR"
run_test "--latency_fcvt=5" "$DIR"
run_test "--latency_fcvt=7" "$DIR"
run_test "--latency_fcvt=9" "$DIR"

# Floating-Point Reciprocal Latency (FNCP) (default=2)
DIR="$ROOT_DIR/latency_fncp"
echo "===========Testing Floating-Point Reciprocal Latency configurations==========="
run_test "--latency_fncp=1" "$DIR"
run_test "--latency_fncp=2" "$DIR"
run_test "--latency_fncp=3" "$DIR"
run_test "--latency_fncp=4" "$DIR"

# FMA Processing Element Ratio (default=1)
DIR="$ROOT_DIR/fma_pe_ratio"
echo "===========Testing FMA Processing Element Ratio configurations==========="
run_test "--fma_pe_ratio=1" "$DIR"
run_test "--fma_pe_ratio=2" "$DIR"
run_test "--fma_pe_ratio=4" "$DIR"
run_test "--fma_pe_ratio=8" "$DIR"

# FDIV Processing Element Ratio (default=8)
DIR="$ROOT_DIR/fdiv_pe_ratio"
echo "===========Testing FDIV Processing Element Ratio configurations==========="
run_test "--fdiv_pe_ratio=2" "$DIR"
run_test "--fdiv_pe_ratio=4" "$DIR"
run_test "--fdiv_pe_ratio=8" "$DIR"
run_test "--fdiv_pe_ratio=16" "$DIR"

# FSQRT Processing Element Ratio (default=8)
DIR="$ROOT_DIR/fsqrt_pe_ratio"
echo "===========Testing FSQRT Processing Element Ratio configurations==========="
run_test "--fsqrt_pe_ratio=2" "$DIR"
run_test "--fsqrt_pe_ratio=4" "$DIR"
run_test "--fsqrt_pe_ratio=8" "$DIR"
run_test "--fsqrt_pe_ratio=16" "$DIR"

# FCVT Processing Element Ratio (default=8)
DIR="$ROOT_DIR/fcvt_pe_ratio"
echo "===========Testing FCVT Processing Element Ratio configurations==========="
run_test "--fcvt_pe_ratio=2" "$DIR"
run_test "--fcvt_pe_ratio=4" "$DIR"
run_test "--fcvt_pe_ratio=8" "$DIR"
run_test "--fcvt_pe_ratio=16" "$DIR"

# FNCP Processing Element Ratio (default=2)
DIR="$ROOT_DIR/fncp_pe_ratio"
echo "===========Testing FNCP Processing Element Ratio configurations==========="
run_test "--fncp_pe_ratio=1" "$DIR"
run_test "--fncp_pe_ratio=2" "$DIR"
run_test "--fncp_pe_ratio=4" "$DIR"
run_test "--fncp_pe_ratio=8" "$DIR"

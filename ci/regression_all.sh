#!/bin/bash

# Copyright © 2019-2023
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Function to sanitize command for filename
sanitize_filename() {
  echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g'
}

# Function to run a test and log the output
run_test() {
    local dynamic_parts=$1
    local log_dir=$2
    local timeout_duration=600 # Timeout in seconds (adjust as needed)

    # Static parts of the command
    local static_parts="./ci/blackboxthree.sh --perf=2"

    # Construct the full command
    local full_command="$static_parts $dynamic_parts"

    # Ensure the log directory exists
    mkdir -p "$log_dir"

    # Sanitize the dynamic part for log filename
    local sanitized_command=$(sanitize_filename "$dynamic_parts")
    local logfile="$log_dir/${sanitized_command}.log"

    # Run the test with timeout and log output
    echo "Running test: $full_command"
    echo "Logging to: $logfile"
    timeout $timeout_duration $full_command >> "$logfile" 2>&1
    local exit_code=$?

    # Check if the test was terminated due to timeout
    if [ $exit_code -eq 124 ]; then
        echo "Test timed out: $full_command" | tee -a "$logfile"
    elif [ $exit_code -ne 0 ]; then
        echo "Test failed with exit code $exit_code: $full_command" | tee -a "$logfile"
    else
        echo "Test completed successfully: $full_command" | tee -a "$logfile"
    fi
}


# Configurable variables for testing
app="vecadd" #replace with desired tests e.g guassian and sgemm
args="-n32"
driver="simx"

# Directory configuration
ROOT_DIR="RESULTS/"
mkdir -p "$ROOT_DIR"

# Last configurations
rm -f blackbox.*.cache
XLEN="64"
XSIZE="8"

##################
# BASELINE TESTS #
##################
echo "===========Testing baselines==========="
DIR="$ROOT_DIR/Baseline/demo"
run_test "--driver=rtlsim --app=demo" "$DIR"
run_test "--driver=simx --app=demo" "$DIR"

DIR="$ROOT_DIR/Baseline/sgemmx"
run_test "--driver=rtlsim --app=sgemmx" "$DIR"
run_test "--driver=simx --app=sgemmx" "$DIR"

DIR="$ROOT_DIR/Baseline/io_addr"
run_test "--driver=rtlsim --app=io_addr" "$DIR"
run_test "--driver=simx --app=io_addr" "$DIR"

DIR="$ROOT_DIR/Baseline/mstress"
run_test "--driver=rtlsim --app=mstress" "$DIR"
run_test "--driver=simx --app=mstress" "$DIR"
run_test "--driver=opae --app=mstress" "$DIR"
run_test "--driver=xrt --app=mstress" "$DIR"

DIR="$ROOT_DIR/Baseline/diverge"
run_test "--driver=rtlsim --app=diverge" "$DIR"
run_test "--driver=simx --app=diverge" "$DIR"
run_test "--driver=opae --app=diverge" "$DIR"
run_test "--driver=xrt --app=diverge" "$DIR"

DIR="$ROOT_DIR/Baseline/vecaddx"
run_test "--driver=rtlsim --app=vecaddx" "$DIR"
run_test "--driver=simx --app=vecaddx" "$DIR"

DIR="$ROOT_DIR/Baseline/dogfood"
run_test "--driver=rtlsim --app=dogfood" "$DIR"
run_test "--driver=simx --app=dogfood" "$DIR"
run_test "--driver=opae --app=dogfood" "$DIR"
run_test "--driver=xrt --app=dogfood" "$DIR"

#########################
# CACHE CONFIGURATIONS #
#########################
echo "===========Testing cache configurations==========="

DIR="$ROOT_DIR/Cache_configurations/disable_local_memory"
run_test "--driver=rtlsim --app=demo --perf=1 --lmem_disable" "$DIR"
run_test "--driver=simx --app=demo --perf=1 --lmem_disable" "$DIR"


DIR="$ROOT_DIR/Cache_configurations/disable_L1_cache"
run_test "--driver=rtlsim --app=sgemmx --l1_disable --lmem_disable" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --l1_disable" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --dcache_disable" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --icache_disable" "$DIR"

DIR="$ROOT_DIR/Cache_configurations/reduce_L1_line_size"
run_test "--driver=rtlsim --app=io_addr --l1_line_size=$XSIZE" "$DIR"
run_test "--driver=simx --app=io_addr --l1_line_size=$XSIZE" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --l1_line_size=$XSIZE --lmem_disable" "$DIR"
run_test "--driver=simx --app=sgemmx --l1_line_size=$XSIZE --lmem_disable" "$DIR"

DIR="$ROOT_DIR/Cache_configurations/cache_ways"
run_test "--driver=rtlsim --app=sgemmx --icache_num_ways=1 --dcache_num_ways=1" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --icache_num_ways=4 --dcache_num_ways=8" "$DIR"
run_test "--driver=simx --app=sgemmx --icache_num_ways=4 --dcache_num_ways=8" "$DIR"

DIR="$ROOT_DIR/Cache_configurations/cache_banking"
run_test "--driver=rtlsim --app=sgemmx --lmem_num_banks=4 --dcache_num_banks=1" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --lmem_num_banks=2 --dcache_num_banks=2" "$DIR"
run_test "--driver=simx --app=sgemmx --lmem_num_banks=2 --dcache_num_banks=2" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --dcache_num_banks=1" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --dcache_num_banks=2" "$DIR"
run_test "--driver=simx --app=sgemmx --dcache_num_banks=2" "$DIR"

DIR="$ROOT_DIR/Cache_configurations/replacement_policy"
run_test "--driver=rtlsim --app=sgemmx --dcache_repl_policy=0" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --dcache_repl_policy=1" "$DIR"
run_test "--driver=rtlsim --app=sgemmx --dcache_repl_policy=2" "$DIR"

DIR="$ROOT_DIR/Cache_configurations/writeback"
run_test "--driver=rtlsim --app=mstress --dcache_writeback=1 --dcache_dirtybytes=0 --dcache_num_ways=4" "$DIR"
run_test "--driver=rtlsim --app=mstress --dcache_writeback=1 --dcache_dirtybytes=1 --dcache_num_ways=4" "$DIR"
run_test "--driver=simx --app=mstress --dcache_writeback=1 --dcache_num_ways=4" "$DIR"
run_test "--driver=rtlsim --app=mstress --cores=2 --clusters=2 --l2cache --l3cache --socket_size=1 --l2_writeback=1 --l3_writeback=1" "$DIR"
run_test "--driver=simx --app=mstress --cores=2 --clusters=2 --l2cache --l3cache --socket_size=1 --l2_writeback=1 --l3_writeback=1" "$DIR"

DIR="$ROOT_DIR/Cache_configurations/cache_clustering"
run_test "--driver=rtlsim --app=sgemmx --cores=4 --warps=1 --threads=2 --socket_size=4 --num_dcaches=4 --num_icaches=2" "$DIR"

DIR="$ROOT_DIR/Cache_configurations/L2_L3"
run_test "--driver=rtlsim --app=diverge --cores=4 --l2cache --socket_size=1 --args=\"-n1\"" "$DIR"
run_test "--driver=simx --app=diverge --cores=4 --l2cache --socket_size=1 --args=\"-n1\"" "$DIR"
run_test "--driver=rtlsim --app=diverge --cores=2 --clusters=2 --l2cache --l3cache --socket_size=1 --args=\"-n1\"" "$DIR"
run_test "--driver=simx --app=diverge --cores=2 --clusters=2 --l2cache --l3cache --socket_size=1 --args=\"-n1\"" "$DIR"

#########################
# BASIC CONFIGURATION 1 #
#########################

echo "===========Testing basic configurations 1==========="
DIR="$ROOT_DIR/Basic_configurations_1/warps_threads"
run_test "--driver=rtlsim --warps=1 --threads=1 --app=diverge" "$DIR"
run_test "--driver=rtlsim --warps=2 --threads=2 --app=diverge" "$DIR"
run_test "--driver=rtlsim --warps=2 --threads=8 --app=diverge" "$DIR"
run_test "--driver=rtlsim --warps=8 --threads=2 --app=diverge" "$DIR"
run_test "--driver=simx --warps=1 --threads=1 --app=diverge" "$DIR"
run_test "--driver=simx --warps=8 --threads=16 --app=diverge" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_1/cores_clustering"
run_test "--driver=rtlsim --cores=4 --app=diverge --args=\"-n1\"" "$DIR"
run_test "--driver=simx --cores=4 --app=diverge --args=\"-n1\"" "$DIR"
run_test "--driver=rtlsim --cores=2 --clusters=2 --app=diverge --args=\"-n1\"" "$DIR"
run_test "--driver=simx --cores=2 --clusters=2 --app=diverge --args=\"-n1\"" "$DIR"
run_test "--driver=rtlsim --cores=2 --clusters=2 --app=diverge --args=\"-n1\" --socket_size=1" "$DIR"
run_test "--driver=simx --cores=2 --clusters=2 --app=diverge --args=\"-n1\" --socket_size=1" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_1/issue_width"
run_test "--driver=rtlsim --app=diverge --issue_width=2" "$DIR"
run_test "--driver=rtlsim --app=diverge --issue_width=4" "$DIR"
run_test "--driver=simx --app=diverge --issue_width=2" "$DIR"
run_test "--driver=simx --app=diverge --issue_width=4" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_1/ALU_scaling"
run_test "--driver=rtlsim --app=diverge --issue_width=2 --num_alu_blocks=1 --num_alu_lanes=2" "$DIR"
run_test "--driver=rtlsim --app=diverge --issue_width=4 --num_alu_blocks=4 --num_alu_lanes=4" "$DIR"
run_test "--driver=simx --app=diverge --issue_width=2 --num_alu_blocks=1 --num_alu_lanes=2" "$DIR"
run_test "--driver=simx --app=diverge --issue_width=4 --num_alu_blocks=4 --num_alu_lanes=4" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_1/FPU_scaling"
run_test "--driver=rtlsim --app=vecaddx --issue_width=2 --num_fpu_blocks=1 --num_fpu_lanes=2" "$DIR"
run_test "--driver=rtlsim --app=vecaddx --issue_width=4 --num_fpu_blocks=4 --num_fpu_lanes=4" "$DIR"
run_test "--driver=simx --app=vecaddx --issue_width=2 --num_fpu_blocks=1 --num_fpu_lanes=2" "$DIR"
run_test "--driver=simx --app=vecaddx --issue_width=4 --num_fpu_blocks=4 --num_fpu_lanes=4" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_1/FPU_PE_scaling"
run_test "--driver=rtlsim --app=dogfood --args=\"-tfmadd\" --fma_pe_ratio=2" "$DIR"
run_test "--driver=rtlsim --app=dogfood --args=\"-tftoi\" --fcvt_pe_ratio=2" "$DIR"
run_test "--driver=rtlsim --app=dogfood --args=\"-tfdiv\" --fdiv_pe_ratio=2" "$DIR"
run_test "--driver=rtlsim --app=dogfood --args=\"-tfsqrt\" --fsqrt_pe_ratio=2" "$DIR"
run_test "--driver=rtlsim --app=dogfood --args=\"-tfclamp\" --fncp_pe_ratio=2" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_1/LSU_scaling"
run_test "--driver=rtlsim --app=vecaddx --issue_width=2 --num_lsu_blocks=1 --num_lsu_lanes=2" "$DIR"
run_test "--driver=rtlsim --app=vecaddx --issue_width=4 --num_lsu_blocks=4 --num_lsu_lanes=4" "$DIR"
run_test "--driver=simx --app=vecaddx --issue_width=2 --num_lsu_blocks=1 --num_lsu_lanes=2" "$DIR"
run_test "--driver=simx --app=vecaddx --issue_width=4 --num_lsu_blocks=4 --num_lsu_lanes=4" "$DIR"

#########################
# BASIC CONFIGURATION 2 #
#########################

echo "===========Testing basic configurations 2==========="
DIR="$ROOT_DIR/Basic_configurations_2/disable_DPI"
if [ "$XLEN" == "64" ]; then
    run_test "--driver=rtlsim --app=dogfood --args=\"-xtrig -xbar -xgbar\" --dpi_disable --fpu_fpnew" "$DIR"
    run_test "--driver=opae --app=dogfood --args=\"-xtrig -xbar -xgbar\" --dpi_disable --fpu_fpnew" "$DIR"
    run_test "--driver=xrt --app=dogfood --args=\"-xtrig -xbar -xgbar\" --dpi_disable --fpu_fpnew" "$DIR"
else
    run_test "--driver=rtlsim --app=dogfood --dpi_disable --fpu_fpnew" "$DIR"
    run_test "--driver=opae --app=dogfood --dpi_disable --fpu_fpnew" "$DIR"
    run_test "--driver=xrt --app=dogfood --dpi_disable --fpu_fpnew" "$DIR"
fi

DIR="$ROOT_DIR/Basic_configurations_2/startup_address"
make -C tests/regression/dogfood clean-kernel
STARTUP_ADDR=0x80000000 make -C tests/regression/dogfood
run_test "--driver=simx --app=dogfood" "$DIR"
run_test "--driver=rtlsim --app=dogfood" "$DIR"
make -C tests/regression/dogfood clean-kernel

DIR="$ROOT_DIR/Basic_configurations_2/disable_zicond"
run_test "--driver=rtlsim --app=demo --ext_zicond_disable" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_2/test_128-bit_memory_block"
run_test "--driver=opae --app=mstress -mem_block_size=16" "$DIR"
run_test "--driver=xrt --app=mstress -mem_block_size=16" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_2/test_XLEN-bit_memory_block"
run_test "--driver=opae --app=mstress -mem_block_size=$XSIZE" "$DIR"
run_test "--driver=simx --app=mstress -mem_block_size=$XSIZE" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_2/test_memory_coalescing"
run_test "--driver=rtlsim --app=mstress --threads=8 -mem_block_size=16" "$DIR"
run_test "--driver=simx --app=mstress --threads=8 -mem_block_size=16" "$DIR"

DIR="$ROOT_DIR/Basic_configurations_2/test_single-bank_memory"
if [ "$XLEN" == "64" ]; then
    run_test "--driver=opae --app=mstress --platform_memory_banks=1 --platform_memory_addr_width=48" "$DIR"
    run_test "--driver=xrt --app=mstress --platform_memory_banks=1 --platform_memory_addr_width=48" "$DIR"
else
    run_test "--driver=opae --app=mstress --platform_memory_banks=1 --platform_memory_addr_width=32" "$DIR"
    run_test "--driver=xrt --app=mstress --platform_memory_banks=1 --platform_memory_addr_width=32" "$DIR"
fi

DIR="$ROOT_DIR/Basic_configurations_2/test_larger_memory_address"
if [ "$XLEN" == "64" ]; then
    run_test "--driver=opae --app=mstress --platform_memory_addr_width=49" "$DIR"
    run_test "--driver=xrt --app=mstress --platform_memory_addr_width=49" "$DIR"
else
    run_test "--driver=opae --app=mstress --platform_memory_addr_width=33" "$DIR"
    run_test "--driver=xrt --app=mstress --platform_memory_addr_width=33" "$DIR"
fi

DIR="$ROOT_DIR/Basic_configurations_2/test_memory_banks_interleaving"
run_test "--driver=opae --app=mstress --platform_memory_interleave=1" "$DIR"
run_test "--driver=opae --app=mstress --platform_memory_interleave=0" "$DIR"

#########################
# STRESS CONFIGURATIONS #
#########################

echo "===========Stress Tests==========="

# Test verilator reset values
DIR="$ROOT_DIR/Stress_configurations/verilator_reset_values"
run_test "--driver=opae --cores=2 --clusters=2 --l2cache --l3cache --app=dogfood --verilator_reset_value=1 --socket_size=1 --dcache_writeback=1 --l2_writeback=1 --l3_writeback=1" "$DIR"
run_test "--driver=xrt --app=sgemmx --args=\"-n128\" --verilator_reset_value=1 --l2cache" "$DIR"

echo "===benchmarking complete==="


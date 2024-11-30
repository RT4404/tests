# Copyright Â© 2019-2023
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

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR=$SCRIPT_DIR/..

show_usage()
{
    echo "Vortex BlackBox Test Driver v1.0"
    echo "Usage: $0 [[--clusters=#n] [--cores=#n] [--warps=#n] [--threads=#n] [--l2cache] [--l3cache] [[--driver=#name] [--app=#app] [--args=#args] [--debug=#level] [--scope] [--perf=#class] [--rebuild=#n] [--log=logfile] [--help]]"
}

show_help()
{
    show_usage
    echo "  where"
    echo "--driver: gpu, simx, rtlsim, oape, xrt"
    echo "--app: any subfolder test under regression or opencl"
    echo "--class: 0=disable, 1=pipeline, 2=memsys"
    echo "--rebuild: 0=disable, 1=force, 2=auto, 3=temp"
}

add_option() {
    if [ -n "$1" ]; then
        echo "$1 $2"
    else
        echo "$2"
    fi
}

DEFAULTS() {
    DRIVER=simx
    APP=sgemm
    DEBUG=0
    DEBUG_LEVEL=0
    SCOPE=0
    HAS_ARGS=0
    PERF_CLASS=0
    CONFIGS="$CONFIGS"
    REBUILD=2
    TEMPBUILD=0
    LOGFILE=run.log
}

parse_args() {
    DEFAULTS
    for i in "$@"; do
        case $i in
            # general configs
            --driver=*) DRIVER=${i#*=} ;;
            --app=*)    APP=${i#*=} ;;
            --clusters=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_CLUSTERS=${i#*=}") ;;
            --cores=*)  CONFIGS=$(add_option "$CONFIGS" "-DNUM_CORES=${i#*=}") ;;
            --warps=*)  CONFIGS=$(add_option "$CONFIGS" "-DNUM_WARPS=${i#*=}") ;;
            --threads=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_THREADS=${i#*=}") ;;
            --barriers=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_BARRIERS=${i#*=}") ;;
            --socket_size=*) CONFIGS=$(add_option "$CONFIGS" "-DSOCKET_SIZE=${i#*=}") ;;
            --xlen=*) CONFIGS=$(add_option "$CONFIGS" "-DXLEN=${i#*=}") ;;
            --flen=*) CONFIGS=$(add_option "$CONFIGS" "-DFLEN=${i#*=}") ;;
            
            # cache configs
            --l2cache)  CONFIGS=$(add_option "$CONFIGS" "-DL2_ENABLE") ;;
            --l3cache)  CONFIGS=$(add_option "$CONFIGS" "-DL3_ENABLE") ;;
            --l1cache_disable) CONFIGS=$(add_option "$CONFIGS" "-DL1_DISABLE");;
            
            --l1_line_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL1_LINE_SIZE=${i#*=}") ;;

            --num_icaches=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_ICACHES=${i#*=}") ;;
            --icache_size=*) CONFIGS=$(add_option "$CONFIGS" "-DICACHE_SIZE=${i#*=}") ;;
            --icache_num_ways=*) CONFIGS=$(add_option "$CONFIGS" "-DICACHE_NUM_WAYS=${i#*=}") ;;
            --icache_mreq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DICACHE_MREQ_SIZE=${i#*=}") ;;
            --icache_mshr_size=*) CONFIGS=$(add_option "$CONFIGS" "-DICACHE_MSHR_SIZE=${i#*=}") ;;
            --icache_crsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DICACHE_CRSQ_SIZE=${i#*=}") ;;
            --icache_mrsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DICACHE_MRSQ_SIZE=${i#*=}") ;;
            --icache_disable) CONFIGS=$(add_option "$CONFIGS" "--DICACHE_DISABLE") ;;

            --num_dcaches=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_DCACHES=${i#*=}") ;;
            --dcache_writeback=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_WRITEBACK=${i#*=}") ;;
            --dcache_size=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_SIZE=${i#*=}") ;;
            --dcache_num_ways=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_NUM_WAYS=${i#*=}") ;;
            --dcache_mreq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_MREQ_SIZE=${i#*=}") ;;  
            --dcache_mshr_size=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_MSHR_SIZE=${i#*=}") ;;
            --dcache_crsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_CRSQ_SIZE=${i#*=}") ;;
            --dcache_mrsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_MRSQ_SIZE=${i#*=}") ;;
            --dcache_num_banks=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_NUM_BANKS=${i#*=}") ;;
            --dcache_repl_policy=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_REPL_POLICY=${i#*=}") ;;
            --dcache_dirtybytes=*) CONFIGS=$(add_option "$CONFIGS" "-DDCACHE_DIRTYBYTES=${i#*=}") ;;
            --dcache_disable) CONFIGS=$(add_option "$CONFIGS" "--DDCACHE_DISABLE") ;;

            --l2_writeback=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_WRITEBACK=${i#*=}") ;;
            --l2_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_CACHE_SIZE=${i#*=}") ;;
            --l2_num_ways=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_NUM_WAYS=${i#*=}") ;;
            --l2_mreq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_MREQ_SIZE=${i#*=}") ;;
            --l2_mshr_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_MSHR_SIZE=${i#*=}") ;;
            --l2_crsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_CRSQ_SIZE=${i#*=}") ;;
            --l2_mrsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_MRSQ_SIZE=${i#*=}") ;;
            --l2_banks=*) CONFIGS=$(add_option "$CONFIGS" "-DL2_NUM_BANKS=${i#*=}") ;;
            
            --l3_writeback=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_WRITEBACK=${i#*=}") ;;
            --l3_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_CACHE_SIZE=${i#*=}") ;;
            --l3_num_ways=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_NUM_WAYS=${i#*=}") ;;
            --l3_mreq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_MREQ_SIZE=${i#*=}") ;;
            --l3_mshr_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_MSHR_SIZE=${i#*=}") ;;
            --l3_crsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_CRSQ_SIZE=${i#*=}") ;;
            --l3_mrsq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_MRSQ_SIZE=${i#*=}") ;;
            --l3_banks=*) CONFIGS=$(add_option "$CONFIGS" "-DL3_NUM_BANKS=${i#*=}") ;;
            --memory_banks=*) CONFIGS=$(add_option "$CONFIGS" "-DMEMORY_BANKS=${i#*=}") ;;
            --num_mem_ports=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_MEM_PORTS=${i#*=}") ;;
            
            # memory system configs
            --mem_block_size=*) CONFIGS=$(add_option "$CONFIGS" "-DMEM_BLOCK_SIZE=${i#*=}") ;;
            --mem_addr_width=*) CONFIGS=$(add_option "$CONFIGS" "-DMEM_ADDR_WIDTH=${i#*=}") ;;
            --stack_log2_size=*) CONFIGS=$(add_option "$CONFIGS" "-DSMEM_LOG_SIZE=${i#*=}") ;;
            --stack_size=*) CONFIGS=$(add_option "$CONFIGS" "-DSTACK_SIZE=${i#*=}") ;;
            --stack_base_addr=*) CONFIGS=$(add_option "$CONFIGS" "-DSTACK_BASE_ADDR=${i#*=}") ;;
            --startup_addr=*) CONFIGS=$(add_option "$CONFIGS" "-DSTARTUP_ADDR=${i#*=}") ;;
            --user_base_addr=*) CONFIGS=$(add_option "$CONFIGS" "-DUSER_BASE_ADDR=${i#*=}") ;;
            --io_base_addr=*) CONFIGS=$(add_option "$CONFIGS" "-DIO_BASE_ADDR=${i#*=}") ;;
            --page_table_base_addr=*) CONFIGS=$(add_option "$CONFIGS" "-DPAGE_TABLE_BASE_ADDR=${i#*=}") ;;
            --mem_page_size=*) CONFIGS=$(add_option "$CONFIGS" "-DMEM_PAGE_SIZE=${i#*=}") ;;
            --mem_page_log2_size=*) CONFIGS=$(add_option "$CONFIGS" "-DMEM_PAGE_LOG2_SIZE=${i#*=}") ;;
            
            # local memory configs
            --lmem_enable) CONFIGS=$(add_option "$CONFIGS" "-DLMEM_ENABLE") ;;
            --lmem_disable) CONFIGS=$(add_option "$CONFIGS" "-DLMEM_DISABLE") ;;
            --lmem_base_addr=*) CONFIGS=$(add_option "$CONFIGS" "-DLMEM_BASE_ADDR=${i#*=}") ;;
            --lmem_log_size=*) CONFIGS=$(add_option "$CONFIGS" "-DLMEM_LOG_SIZE=${i#*=}") ;;
            --lmem_num_banks=*) CONFIGS=$(add_option "$CONFIGS" "-DLMEM_NUM_BANKS=${i#*=}") ;;
            
            # execution unit configs
            --num_alu_lanes=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_ALU_LANES=${i#*=}") ;;
            --num_fpu_lanes=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_FPU_LANES=${i#*=}") ;;
            --num_lsu_lanes=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_LSU_LANES=${i#*=}") ;;
            --num_sfu_lanes=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_SFU_LANES=${i#*=}") ;;
            --num_alu_blocks=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_ALU_BLOCKS=${i#*=}") ;;
            --num_fpu_blocks=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_FPU_BLOCKS=${i#*=}") ;;
            --num_lsu_blocks=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_LSU_BLOCKS=${i#*=}") ;;
            --num_sfu_blocks=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_SFU_BLOCKS=${i#*=}") ;;
            
            # latency and FPU configs
            --fpuq_size=*) CONFIGS=$(add_option "$CONFIGS" "-DFPUQ_SIZE=${i#*=}") ;;
            --latency_imul=*) CONFIGS=$(add_option "$CONFIGS" "-DLATENCY_IMUL=${i#*=}") ;;
            --latency_fma=*) CONFIGS=$(add_option "$CONFIGS" "-DLATENCY_FMA=${i#*=}") ;;
            --latency_fdiv=*) CONFIGS=$(add_option "$CONFIGS" "-DLATENCY_FDIV=${i#*=}") ;;
            --latency_fsqrt=*) CONFIGS=$(add_option "$CONFIGS" "-DLATENCY_FSQRT=${i#*=}") ;;
            --latency_fcvt=*) CONFIGS=$(add_option "$CONFIGS" "-DLATENCY_FCVT=${i#*=}") ;;
            --latency_fncp=*) CONFIGS=$(add_option "$CONFIGS" "-DLATENCY_FNCP=${i#*=}") ;;
            --fma_pe_ratio=*) CONFIGS=$(add_option "$CONFIGS" "-DFMA_PE_RATIO=${i#*=}") ;;
            --fdiv_pe_ratio=*) CONFIGS=$(add_option "$CONFIGS" "-DFDIV_PE_RATIO=${i#*=}") ;;
            --fsqrt_pe_ratio=*) CONFIGS=$(add_option "$CONFIGS" "-DSQRT_PE_RATIO=${i#*=}") ;;
            --fcvt_pe_ratio=*) CONFIGS=$(add_option "$CONFIGS" "-DCVT_PE_RATIO=${i#*=}") ;;
            --fncp_pe_ratio=*) CONFIGS=$(add_option "$CONFIGS" "-DNCP_PE_RATIO=${i#*=}") ;;

            # pipeline configs
            --issue_width=*) CONFIGS=$(add_option "$CONFIGS" "-DISSUE_WIDTH=${i#*=}") ;;
            --ibuf_size=*) CONFIGS=$(add_option "$CONFIGS" "-DIBUF_SIZE=${i#*=}") ;;
            --lsu_line_size=*) CONFIGS=$(add_option "$CONFIGS" "-DLSU_LINE_SIZE=${i#*=}") ;;
            --lsuq_in_size=*) CONFIGS=$(add_option "$CONFIGS" "-DLSUQ_IN_SIZE=${i#*=}") ;;
            --lsuq_out_size=*) CONFIGS=$(add_option "$CONFIGS" "-DLSUQ_OUT_SIZE=${i#*=}") ;;
            --gbar_enable) CONFIGS=$(add_option "$CONFIGS" "-DGBAR_ENABLE") ;;
            
            # virtual memory configs
            --vm_enable) CONFIGS=$(add_option "$CONFIGS" "-DVM_ENABLE") ;;
            --vm_addr_mode=*) CONFIGS=$(add_option "$CONFIGS" "-DVM_ADDR_MODE=${i#*=}") ;;
            --pt_level=*) CONFIGS=$(add_option "$CONFIGS" "-DPT_LEVEL=${i#*=}") ;;
            --pte_size=*) CONFIGS=$(add_option "$CONFIGS" "-DPTE_SIZE=${i#*=}") ;;
            --num_pte_entry=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_PTE_ENTRY=${i#*=}") ;;
            --pt_size_limit=*) CONFIGS=$(add_option "$CONFIGS" "-DPT_SIZE_LIMIT=${i#*=}") ;;
            --pt_size=*) CONFIGS=$(add_option "$CONFIGS" "-DPT_SIZE_LIMIT=${i#*=}") ;;
            --tlb_size=*) CONFIGS=$(add_option "$CONFIGS" "-DTLB_SIZE=${i#*=}") ;;

            # ISA extension configs, (these are enabled by default)
            --ext_m_disable) CONFIGS=$(add_option "$CONFIGS" "-DEXT_M_DISABLE") ;;
            --ext_f_disable) CONFIGS=$(add_option "$CONFIGS" "-DEXT_F_DISABLE") ;;
            --ext_d_disable) CONFIGS=$(add_option "$CONFIGS" "-DEXT_D_DISABLE") ;;
            --ext_c_disable) CONFIGS=$(add_option "$CONFIGS" "-DEXT_C_DISABLE") ;;
            --ext_a_disable) CONFIGS=$(add_option "$CONFIGS" "-DEXT_A_DISABLE") ;;
            --ext_zicond_disable) CONFIGS=$(add_option "$CONFIGS" "-DEXT_ZICOND_DISABLE") ;;
            
            # tensor core configs
            --tc_size=*) CONFIGS=$(add_option "$CONFIGS" "-DTC_SIZE=${i#*=}") ;;
            --tc_num=*) CONFIGS=$(add_option "$CONFIGS" "-DTC_NUM=${i#*=}") ;;
            --num_tcu_lanes=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_TCU_LANES=${i#*=}") ;;
            --num_tcu_lanes=*) CONFIGS=$(add_option "$CONFIGS" "-DNUM_TCU_BLOCKS=${i#*=}") ;;
            
            # dpi and synthesis options
            --fpu_dpi) CONFIGS=$(add_option "$CONFIGS" "-DFPU_DPI") ;;
            --imul_dpi) CONFIGS=$(add_option "$CONFIGS" "-DIMUL_DPI") ;;
            --fpu_dpi) CONFIGS=$(add_option "$CONFIGS" "-DIDIV_DPI") ;;
            --dpi_disable) CONFIGS=$(add_option "$CONFIGS" "-DDPI_DISABLE") ;;
            
            # fpu_fpnew
            --fpu_fpnew) CONFIGS=$(add_option "$CONFIGS" "-DFPU_FPNEW") ;;

            # platform
            --platform_memory_banks=*) CONFIGS=$(add_option "$CONFIGS" "-DPLATFORM_MEMORY_BANKS=${i#*=}") ;;
            --platform_memory_addr_width=*) CONFIGS=$(add_option "$CONFIGS" "-DPLATFORM_MEMORY_ADDR_WIDTH=${i#*=}") ;;
            --platform_memory_interleave=*) CONFIGS=$(add_option "$CONFIGS" "-DPLATFORM_MEMORY_INTERLEAVE=${i#*=}") ;;

            # verilator
            --verilator_reset_value=*) CONFIGS=$(add_option "$CONFIGS" "-DVERILATOR_RESET_VALUE=${i#*=}") ;;

            # I/O configs
            --io_cout_size=*) CONFIGS=$(add_option "$CONFIGS" "-DIO_COUT_SIZE=${i#*=}") ;;
            --io_mpm_size=*) CONFIGS=$(add_option "$CONFIGS" "-DIO_MPM_SIZE=${i#*=}") ;;
            
            # performance/debug options
            --perf=*)   CONFIGS=$(add_option "$CONFIGS" "-DPERF_ENABLE"); PERF_CLASS=${i#*=} ;;
            --debug=*)  DEBUG=1; DEBUG_LEVEL=${i#*=} ;;
            --scope)    SCOPE=1; ;;
            --args=*)   HAS_ARGS=1; ARGS=${i#*=} ;;
            --rebuild=*) REBUILD=${i#*=} ;;
            --log=*)    LOGFILE=${i#*=} ;;
            --help)     show_help; exit 0 ;;
            *)          show_usage; exit 1 ;;
        esac
    done

    if [ $REBUILD -eq 3 ];
    then
        REBUILD=1
        TEMPBUILD=1
    fi
}

set_driver_path() {
    case $DRIVER in
        gpu) DRIVER_PATH="" ;;
        simx|rtlsim|opae|xrt) DRIVER_PATH="$ROOT_DIR/runtime/$DRIVER" ;;
        *) echo "Invalid driver: $DRIVER"; exit 1 ;;
    esac
}

set_app_path() {
    if [ -d "$ROOT_DIR/tests/opencl/$APP" ]; then
        APP_PATH="$ROOT_DIR/tests/opencl/$APP"
    elif [ -d "$ROOT_DIR/tests/regression/$APP" ]; then
        APP_PATH="$ROOT_DIR/tests/regression/$APP"
    else
        echo "Application folder not found: $APP"
        exit 1
    fi
}

build_driver() {
    local cmd_opts=""
    [ $DEBUG -ne 0 ] && cmd_opts=$(add_option "$cmd_opts" "DEBUG=$DEBUG_LEVEL")
    [ $SCOPE -eq 1 ] && cmd_opts=$(add_option "$cmd_opts" "SCOPE=1")
    [ $TEMPBUILD -eq 1 ] && cmd_opts=$(add_option "$cmd_opts" "DESTDIR=\"$TEMPDIR\"")
    [ -n "$CONFIGS" ] && cmd_opts=$(add_option "$cmd_opts" "CONFIGS=\"$CONFIGS\"")

    if [ -n "$cmd_opts" ]; then
        echo "Running: $cmd_opts make -C $DRIVER_PATH > /dev/null"
        eval "$cmd_opts make -C $DRIVER_PATH > /dev/null"
    else
        echo "Running: make -C $DRIVER_PATH > /dev/null"
        make -C $DRIVER_PATH > /dev/null
    fi
}

run_app() {
    local cmd_opts=""
    [ $DEBUG -eq 1 ] && cmd_opts=$(add_option "$cmd_opts" "DEBUG=1")
    [ $TEMPBUILD -eq 1 ] && cmd_opts=$(add_option "$cmd_opts" "VORTEX_RT_PATH=\"$TEMPDIR\"")
    [ $HAS_ARGS -eq 1 ] && cmd_opts=$(add_option "$cmd_opts" "OPTS=\"$ARGS\"")

    if [ $DEBUG -ne 0 ]; then
        if [ -n "$cmd_opts" ]; then
            echo "Running: $cmd_opts make -C $APP_PATH run-$DRIVER > $LOGFILE 2>&1"
            eval "$cmd_opts make -C $APP_PATH run-$DRIVER > $LOGFILE 2>&1"
        else
            echo "Running: make -C $APP_PATH run-$DRIVER > $LOGFILE 2>&1"
            make -C $APP_PATH run-$DRIVER > $LOGFILE 2>&1
        fi
    else
        if [ -n "$cmd_opts" ]; then
            echo "Running: $cmd_opts make -C $APP_PATH run-$DRIVER"
            eval "$cmd_opts make -C $APP_PATH run-$DRIVER"
        else
            echo "Running: make -C $APP_PATH run-$DRIVER"
            make -C $APP_PATH run-$DRIVER
        fi
    fi
    status=$?
    return $status
}

main() {
    parse_args "$@"
    set_driver_path
    set_app_path

    # execute on default installed GPU
    if [ "$DRIVER" = "gpu" ]; then
        run_app
        exit $?
    fi

    if [ -n "$CONFIGS" ]; then
        echo "CONFIGS=$CONFIGS"
    fi

    if [ $REBUILD -ne 0 ]; then
        BLACKBOX_CACHE=blackbox.$DRIVER.cache
        LAST_CONFIGS=$(cat "$BLACKBOX_CACHE" 2>/dev/null || echo "")

        if [ $REBUILD -eq 1 ] || [ "$CONFIGS+$DEBUG+$SCOPE" != "$LAST_CONFIGS" ]; then
            make -C $DRIVER_PATH clean-driver > /dev/null
            echo "$CONFIGS+$DEBUG+$SCOPE" > "$BLACKBOX_CACHE"
        fi
    fi

    export VORTEX_PROFILING=$PERF_CLASS

    make -C "$ROOT_DIR/hw" config > /dev/null
    make -C "$ROOT_DIR/runtime/stub" > /dev/null

    if [ $TEMPBUILD -eq 1 ]; then
        # setup temp directory
        TEMPDIR=$(mktemp -d)
        mkdir -p "$TEMPDIR"
        # build stub driver
        echo "running: DESTDIR=$TEMPDIR make -C $ROOT_DIR/runtime/stub"
        DESTDIR="$TEMPDIR" make -C $ROOT_DIR/runtime/stub > /dev/null
        # register tempdir cleanup on exit
        trap "rm -rf $TEMPDIR" EXIT
    fi

    build_driver
    run_app
    status=$?

    if [ $DEBUG -eq 1 ] && [ -f "$APP_PATH/trace.vcd" ]; then
        mv -f $APP_PATH/trace.vcd .
    fi

    if [ $SCOPE -eq 1 ] && [ -f "$APP_PATH/scope.vcd" ]; then
        mv -f $APP_PATH/scope.vcd .
    fi

    exit $status
}

main "$@"

#!/bin/sh

# Script to run all Vortex tests with varying configurations

# Define parameter ranges
CLUSTERS_LIST="1 2 4 8"
CORES_LIST="1 2 4 8"
WARPS_LIST="4 8 16 32"
THREADS_LIST="4 8 16 32"
TESTS_LIST="vecadd sgemm conv3 psort saxpy sfilter sgemm2 sgemm3 psum oclprintf dotproduct transpose spmv stencil lbm nearn guassian kmeans blackscholes bfs"

# Timeout setting (in seconds) - 20 minutes = 1200 seconds
TIMEOUT_DURATION=1200

# Log file to capture results
LOGFILE="full_run_results.log"
echo "Vortex Automated Test Run - $(date)" > $LOGFILE

# Function to log and print messages
log_message() {
    echo "$1" | tee -a $LOGFILE
}

# Function to display the help message
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --clusters        Run tests with varying clusters"
    echo "  --cores           Run tests with varying cores"
    echo "  --warps           Run tests with varying warps"
    echo "  --threads         Run tests with varying threads"
    echo "  --l2cache         Enable L2 cache for the tests"
    echo "  --l3cache         Enable L3 cache for the tests"
    echo "  --test <test>     Run a specific test (use 'all' to run all tests)"
    echo "  --help            Display this help message and exit"
    echo
    echo "Examples:"
    echo "  $0 --clusters --test vecadd           Run vecadd with varying clusters"
    echo "  $0 --cores --l2cache --test all       Run all tests with varying cores and L2 cache enabled"
    echo "  $0 --warps --threads --l3cache        Run tests with varying warps and threads, with L3 cache enabled"
    exit 0
}

# Function to run a test with given parameters and enforce a timeout
run_test() {
    local clusters=$1
    local cores=$2
    local warps=$3
    local threads=$4
    local l2cache=$5
    local l3cache=$6
    local test=$7

    # Build blackbox command
    CACHE_OPTIONS=""

    # If L2 cache is enabled (l2cache=1), add the --l2cache flag
    if [ $l2cache -eq 1 ]; then
        CACHE_OPTIONS="$CACHE_OPTIONS --l2cache"
    fi

    # If L3 cache is enabled (l3cache=1), add the --l3cache flag
    if [ $l3cache -eq 1 ]; then
        CACHE_OPTIONS="$CACHE_OPTIONS --l3cache"
    fi
    
    COMMAND="./ci/blackbox.sh --clusters=$clusters --cores=$cores --warps=$warps --threads=$threads $CACHE_OPTIONS --app=$test --driver=simx"

    # Log the command being executed
    log_message "Running: $COMMAND (timeout: $TIMEOUT_DURATION seconds)"

    # Use 'timeout' to limit the duration of the command to $TIMEOUT_DURATION seconds
    timeout $TIMEOUT_DURATION $COMMAND >> $LOGFILE 2>&1
    status=$?

    # Check if the test timed out or completed
    if [ $status -eq 124 ]; then
        log_message "Test $test timed out after $TIMEOUT_DURATION seconds with clusters=$clusters, cores=$cores, warps=$warps, threads=$threads"
    elif [ $status -eq 0 ]; then
        log_message "Test $test passed with clusters=$clusters, cores=$cores, warps=$warps, threads=$threads, l2cache=$l2cache, l3cache=$l3cache"
    else
        log_message "Test $test failed with clusters=$clusters, cores=$cores, warps=$warps, threads=$threads, l2cache=$l2cache, l3cache=$l3cache"
    fi

    log_message "------------------------------------------------------"
}

# Function to run tests with different L2 and L3 configurations
run_test_with_caches() {
    local clusters=$1
    local cores=$2
    local warps=$3
    local threads=$4
    local test=$5

    # Run without L2 or L3
    run_test $clusters $cores $warps $threads 0 0 $test

    # Run with only L2 if requested
    if [ $run_l2 -eq 1 ] && [ $run_l3 -eq 0 ] && [ $cores -gt 1]; then
        run_test $clusters $cores $warps $threads 1 0 $test
    fi

    # Run with only L3 if requested
    if [ $run_l3 -eq 1 ] && [ $run_l2 -eq 0 ] && [ $clusters -gt 1]; then
        run_test $clusters $cores $warps $threads 0 1 $test
    fi

    # Run with both L2 and L3 if requested
    if [ $run_l2 -eq 1 ] && [ $run_l3 -eq 1 ]; then
        if [ $cores -gt 1 ]; then
            run_test $clusters $cores $warps $threads 1 0 $test
        fi
        if [ $clusters -gt 1 ]; then
        run_test $clusters $cores $warps $threads 0 1 $test
        fi
        if [ $cores -gt 1 ] && [ $clusters -gt 1 ]; then
        run_test $clusters $cores $warps $threads 1 1 $test
        fi
    fi
}

# Flags to determine which tests to run
run_clusters=0
run_cores=0
run_warps=0
run_threads=0
run_l2=0
run_l3=0
specified_test=""

# Parse command-line arguments
while [ "$1" != "" ]; do
    case $1 in
        --clusters )   run_clusters=1 ;;
        --cores )      run_cores=1 ;;
        --warps )      run_warps=1 ;;
        --threads )    run_threads=1 ;;
        --l2cache )    run_l2=1 ;;
        --l3cache )    run_l3=1 ;;
        --test )       shift; specified_test=$1 ;;
        --help )       show_help ;;
        * )            log_message "Invalid option: $1"; exit 1 ;;
    esac
    shift
done

# Determine which tests to run based on the specified test argument
if [ "$specified_test" = "all" ]; then
    TESTS_TO_RUN=$TESTS_LIST
else
    TESTS_TO_RUN=$specified_test
fi

# Run tests with varying clusters (other parameters fixed)
if [ $run_clusters -eq 1 ]; then
    log_message "Starting cluster tests..."
    for clusters in $CLUSTERS_LIST; do
        for test in $TESTS_TO_RUN; do
            run_test_with_caches $clusters 1 4 4 $test
        done
    done
fi

# Run tests with varying cores (other parameters fixed)
if [ $run_cores -eq 1 ]; then
    log_message "Starting core tests..."
    for cores in $CORES_LIST; do
        for test in $TESTS_TO_RUN; do
            run_test_with_caches 1 $cores 4 4 $test
        done
    done
fi

# Run tests with varying warps (other parameters fixed)
if [ $run_warps -eq 1 ]; then
    log_message "Starting warp tests..."
    for warps in $WARPS_LIST; do
        for test in $TESTS_TO_RUN; do
            run_test_with_caches 1 1 $warps 4 $test
        done
    done
fi

# Run tests with varying threads (other parameters fixed)
if [ $run_threads -eq 1 ]; then
    log_message "Starting thread tests..."
    for threads in $THREADS_LIST; do
        for test in $TESTS_TO_RUN; do
            run_test_with_caches 1 1 4 $threads $test
        done
    done
fi

log_message "Test run complete!"


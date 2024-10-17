#!/bin/bash

LOGFILE="test_results.log"

# baseline test
echo "==========Running Baseline Tests...==========" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --perf=2 >> $LOGFILE 2>&1

# disable l1 cache
echo "===========l1 cache disable=============" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --l1cache_off >> $LOGFILE 2>&1

# l1 cache size (default=16384)
echo "===========l1 cache size test===========" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --icache_size=8192 --dcache_size=8192 --perf=2 >> $LOGFILE 2>&1 #small
./ci/blackboxthree.sh --app=sgemm --icache_size=32768 --dcache_size=32768 --perf=2 >> $LOGFILE 2>&1 #large

# l2 cache size (default=1048576)
echo "===========l2 cache size test=============" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --l2_size=524288 --l2cache --cores=4 --perf=2 >> $LOGFILE 2>&1 #small
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --perf=2 >> $LOGFILE 2>&1 #default
./ci/blackboxthree.sh --app=sgemm --l2_size=2097152 --l2cache --cores=4 --perf=2 >> $LOGFILE 2>&1 #large

# l3 cache size (default=1048576)
echo "===========l3 cache size test=========" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --l3_size=524288 --l3cache --clusters=4 --perf=2 >> $LOGFILE 2>&1 #small
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --perf=2 >> $LOGFILE 2>&1 #default
./ci/blackboxthree.sh --app=sgemm --l3_size=2097152 --l3cache --clusters=4 --perf=2 >> $LOGFILE 2>&1 #large

# l1 cache ways (default 1)
echo "==========l1 cache ways===========" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --icache_ways=2 --dcache_ways=2 --perf=2 >> $LOGFILE 2>&1 #x2
./ci/blackboxthree.sh --app=sgemm --icache_ways=4 --dcache_ways=4 --perf=2 >> $LOGFILE 2>&1 #x4

# l2 cache ways (default 2)
echo "============l2 cache ways=============" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --l2_ways=1 --perf=2 >> $LOGFILE 2>&1 #x0.5
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --perf=2 >> $LOGFILE 2>&1 #default
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --l2_ways=4 --perf=2 >> $LOGFILE 2>&1 #x2
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --l2_ways=8 --perf=2 >> $LOGFILE 2>&1 #x4

# l3 cache ways (default 4)
echo "============l3 cache ways===========" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --l3_ways=2 --perf=2 >> $LOGFILE 2>&1 #x0.5
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --perf=2 >> $LOGFILE 2>&1 #default
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --l3_ways=8 --perf=2 >> $LOGFILE 2>&1 #x2
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --l3_ways=16 --perf=2 >> $LOGFILE 2>&1 #x4

# l1 mreq size (default 4)
echo "============l1 mreqsize==============" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --icache_mreq_size=2 --dcache_mreq_size=2 --perf=2 >> $LOGFILE 2>&1
./ci/blackboxthree.sh --app=sgemm --icache_mreq_size=8 --dcache_mreq_size=8 --perf=2 >> $LOGFILE 2>&1
./ci/blackboxthree.sh --app=sgemm --icache_mreq_size=16 --dcache_mreq_size=16 --perf=2 >> $LOGFILE 2>&1

# l2 mreq size (default 4)
echo "============l2 mreqsize=============" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --l2_mreq_size=2 --perf=2 >> $LOGFILE 2>&1
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --l2_mreq_size=8 --perf=2 >> $LOGFILE 2>&1
./ci/blackboxthree.sh --app=sgemm --l2cache --cores=4 --l2_mreq_size=16 --perf=2 >> $LOGFILE 2>&1

# l3 mreq size
echo "==========l3 mreqsize=============" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --l3_mreq_size=2 --perf=2 >> $LOGFILE 2>&1
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --l3_mreq_size=8 --perf=2 >> $LOGFILE 2>&1
./ci/blackboxthree.sh --app=sgemm --l3cache --clusters=4 --l3_mreq_size=16 --perf=2 >> $LOGFILE 2>&1

# tc_size (default 8)
echo "============tc_size===============" | tee -a $LOGFILE
./ci/blackboxthree.sh --app=sgemm --tc_size=4 >> $LOGFILE 2>&1
./ci/blackboxthree.sh --app=sgemm --tc_size=16 >> $LOGFILE 2>&1

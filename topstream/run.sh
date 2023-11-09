#!/bin/bash

WORKDIR="/home/ubuntu"
AFL_ARGS_BASE="-c $WORKDIR/topstream/restart.sh -i $WORKDIR/results/sample -o $WORKDIR/results/toptea -N tcp://127.0.0.1/8888 -P TOPSTREAM -D 10000 -q 2 -s 2 -E -K -R"
TARGET="$WORKDIR/topstream/topstream-fuzz"
AFL="$WORKDIR/aflnet/afl-fuzz"

run_fuzz() {
    local test_case="$1"
    local ip="$2"
    local port="$3"
    local ip2="$4"
    local port2="$5"
    
    # Run master without -d
    $AFL -M "${test_case}_master" $AFL_ARGS_BASE $TARGET $ip $port $ip2 $port2 &
    
    # Run two slaves without specifying -d, as -S implies it
    $AFL -S "${test_case}_slave1" $AFL_ARGS_BASE $TARGET $ip $port $ip2 $port2 &
    $AFL -S "${test_case}_slave2" $AFL_ARGS_BASE $TARGET $ip $port $ip2 $port2 &
}

# Using insufficient arguments
run_fuzz "test1" 127.0.0.1 127.0.0.1 127.0.0.1 8888 127.0.0.1 9999 

# Using invalid service provider IP or port
run_fuzz "test2" 777.256.256.256 8888 127.0.0.1 9999
run_fuzz "test3" 127.0.0.1 9999999 127.0.0.1 9999

# Competing with an already bound port
run_fuzz "test4" 127.0.0.1 8888 127.0.0.1 8888

# Using special characters or formats as arguments
run_fuzz "test5" "!!!." 8888 127.0.0.1 9999
run_fuzz "test6" 127.0.0.1 "####" 127.0.0.1 9999
run_fuzz "test7" 127.0.0.1 8888 "localhost" "localhost"

# Correct fuzzing
run_fuzz "test8" 127.0.0.1 8888 127.0.0.1 9999

# Wait for all fuzzing instances to finish
wait

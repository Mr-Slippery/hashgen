#!/usr/bin/env bash
echo "#define TABLE_SIZE ((uint32_t)$2)" > table.c
python3 params.py $3 > params_def.c

for i in $(seq $4 $5)
do
    echo "CHECK: $1 $2 $3 $i"
    python3 nums.py $1 $i > nums.c
    ./klee_c.sh hash.c 2>&1 > klee.run
    grep "ASSERTION FAIL" klee.run | wc -l > result.dat
    RESULT=$(cat result.dat)
    if (( $RESULT < 1 ))
    then
        echo "FAILED: $1 $2 $3 $i"
        DIR="failed_$1_$2_$3_$i"
        mkdir "${DIR}"
        cp hash.c nums.c params_def.c table.c "${DIR}"
    fi
    grep 'data:' klee.run | cut -c 18- | sed s/[\']//g > params.dat
    PARAMS=$(cat params.dat)
    echo ${PARAMS}
    echo "memcpy(&params[0], \"${PARAMS}\", PARAMS_LEN);" > params.c
    gcc hash.c -o hash
    ./hash > hashes.data
    python3 collisions.py hashes.data
    echo "COLLISIONS: $?"
done

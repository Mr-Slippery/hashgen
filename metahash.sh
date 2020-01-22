#!/usr/bin/env bash

for size in $(seq $1 $2)
do
    ./hashgen.sh $size $size $3 $4 $5 2>&1
done

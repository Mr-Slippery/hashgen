#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

#define HASH_KEY_LEN (4)

#include "table.c"

#include "params_def.c"

#ifdef KLEE
#include <klee/klee.h>
#include <assert.h>
#endif

#include <stdbool.h>

#ifndef KLEE
#include <stdio.h>
#include <string.h>
#endif

static bool operation(bool table[], size_t table_size,
                      uint32_t nums[], size_t nums_len, 
                      uint8_t params[], size_t n)
{
    size_t i;
    uint32_t h;
    for (i = 0; i < nums_len; ++i) {
        h = hash(nums[i]);
        if ( (h >= table_size) || table[h]) {
            return false;
        }
        table[h] = true;
    }
    return true;
}

#include "nums.c"

int main(/*@unused@*/ int argc, /*@unused@*/ char *argv[])
{
#ifdef KLEE
    klee_make_symbolic(params, sizeof params, "params");
#else
    #include "params.c"
#endif
    bool table[TABLE_SIZE] = {false};

#ifdef KLEE
    assert(!operation(table, TABLE_SIZE, nums, NUMS_LEN, params, PARAMS_LEN));
#else
    printf("id index\n");
    operation(table, TABLE_SIZE, nums, NUMS_LEN, params, PARAMS_LEN);
    {
        size_t i;
        for (i = 0; i < NUMS_LEN; ++i)
            printf("%u %u\n", nums[i], hash(nums[i]));
    }
#endif

    return 0;
}
import sys
# generate random integer values
from random import seed
from random import randint
# seed random number generator
seed(int(sys.argv[2]))
# generate some integers
nums = set()
req_len = int(sys.argv[1])
while True:
    value = randint(0, 4294967295)
    if value in nums:
        continue
    nums.add(value)
    if len(nums) == req_len:
        break
print(
"""
#include <stdint.h>

#define NUMS_LEN ({})
uint32_t nums[NUMS_LEN] = {{
""".format(len(nums)), end='')

i = 0
for num in nums:
    if i > 0 and i % 5 == 0:
        print("")
    i += 1
    print("{},".format(num), end='')

print(
"""
};
""")

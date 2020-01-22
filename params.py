import sys
params_len = int(sys.argv[1])
print(
"""
#define PARAMS_LEN ({})

uint8_t params[PARAMS_LEN];

uint32_t hash (uint32_t data) {{
    uint32_t hash = HASH_KEY_LEN;

    hash  += data;
""".format(params_len), end='')

for i in range(0, int(params_len / 2)):
    print(
"""
    hash ^= hash << params[{}];
    hash += hash >> params[{}];
""".format(2*i, 2*i+1),
    end='')

print(
"""
    return hash % TABLE_SIZE;
}
""")
#!/usr/bin/env bash
set -euo pipefail

KLEE_IMAGE="klee/klee"
docker pull "${KLEE_IMAGE}"
RUN="docker run -v $(pwd):$(pwd) --rm ${KLEE_IMAGE}"

CLANG_BIN=/tmp/llvm-60-install_O_D_A/bin
CLANGXX="${RUN} ${CLANG_BIN}/clang++"
CLANG="${RUN} ${CLANG_BIN}/clang"

KLEE_INCLUDE=/home/klee/klee_src/include
KLEE_BUILD=/home/klee/klee_build
KLEE_BIN="${KLEE_BUILD}/bin"

KLEE="${RUN} ${KLEE_BIN}/klee"
KTEST="${RUN} ${KLEE_BIN}/ktest-tool"

if [[ "${1}" != "replay" ]]
then
FILE=${1-main.cc}

if [ ! -f "${FILE}" ]
then	
cat << EOF > "${FILE}"
#include <klee/klee.h>
#include <assert.h>

constexpr size_t N = 2;

int main(int argc, char *argv[])
{
    float f;
    klee_make_symbolic(&f, sizeof f, "f");
    klee_assert(f * f != 2.0f);
    return 0;
}
EOF
fi

${CLANG} -g -emit-llvm -DKLEE -I"${KLEE_INCLUDE}" -c "$(pwd)/${FILE}" -o "$(pwd)/${FILE%%.*}.bc"

#${KLEE} --libc=uclibc --posix-runtime "$(pwd)/${FILE%%.*}.bc" -sym-files 1 64
time ${KLEE} "$(pwd)/${FILE%%.*}.bc"
#time ${KLEE} -emit-all-errors "$(pwd)/${FILE%%.*}.bc"

ERROR_FILE="$(basename "$(find -L klee-last -name '*.assert.err')")"
${KTEST} "$(pwd)/klee-last/${ERROR_FILE%%.*}.ktest"
else
KTEST_FILE="${2}"
${KTEST} "$(pwd)/${KTEST_FILE}"
fi

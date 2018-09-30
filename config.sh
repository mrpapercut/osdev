#!/bin/sh
SYSTEM_HEADER_PROJECTS="libc kernel"
PROJECTS="libc kernel"

export CROSS_COMPILER="$(pwd)/cross-compiler" # Location of cross-compiler
export TARGET=i686-elf

if ! echo $PATH | grep -Eq "$CROSS_COMPILER/bin:"; then
    export PATH="$CROSS_COMPILER/bin:$PATH"
fi

export MAKE=${MAKE:-make}
export HOST=${HOST:-$(./default-host.sh)}

export AR=${HOST}-ar
export AS=${HOST}-as
export CC=${HOST}-gcc

export PREFIX=/usr
export EXEC_PREFIX=$PREFIX
export BOOTDIR=/boot
export LIBDIR=$EXEC_PREFIX/lib
export INCLUDEDIR=$PREFIX/include

export CFLAGS='-O2 -g'
export CPPFLAGS=''

# Configure the cross-compiler to use the desired sysroot
export SYSROOT="$(pwd)/sysroot"
export CC="$CC --sysroot=$SYSROOT"

# Work around that the -elf gcc targets doesn't have a system include directory
# because it was configured with --without-headers rather than --with-sysroot.
if echo "$HOST" | grep -Eq -- '-elf($|-)'; then
    export CC="$CC -isystem=$INCLUDEDIR"
fi

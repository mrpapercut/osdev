#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/mysia.kernel isodir/boot/mysia.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "mysia" {
    multiboot /boot/mysia.kernel
}
EOF
grub-mkrescue -o mysia.iso isodir

#!/bin/sh
set -e

. ./clean.sh

rm -f mysia.iso

. ./iso.sh

. ./clean.sh

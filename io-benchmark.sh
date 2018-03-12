#!/usr/bin/env bash

# Author: Phil Huang <phil_huang@edge-core.com>
# Support: support@edge-core.com

# References:
# http://benjr.tw/34632
# https://wsgzao.github.io/post/fio/
# https://askubuntu.com/questions/724228/how-to-find-the-number-of-cpu-cores-including-virtual

# Fail on error
set -e

# Fail on unset var usage
set -o nounset

DISK="/dev/sdb"

# Install fio if not exist
if ! which fio &> /dev/null; then
    echo "Install Flexible I/O Tester (FIO)"
    apt update -y
    apt install fio -y
fi

# Show FIO version
fio --version

# Running Random 4K Testing
# Rule:
# 1. Block size 4k
# 2. IO Depth 128
# 4. Only 4 thread

# Random Read
function random_read {
fio -filename=$(DISK) \
    -direct=1 \
    -iodepth＝128 \
    -thread \
    -rw=randread \
    -ioengine=libaio \
    -bs=4k \
    -size=4G \
    -numjobs=$(cat /proc/cpuinfo | grep processor | wc -l) \
    -runtime=120 \
    -group_reporting \
    -name=random_read_report \
    > random_write_report_$(date '+%Y%m%d_%H_%M_%S')
}

function random_write {
fio -filename=$(DISK) \
    -direct=1 \
    -iodepth 128 \
    -thread \
    -rw=randwrite \
    -ioengine=libaio \
    -bs=4k \
    -size=4G \
    -numjobs=$(cat /proc/cpuinfo | grep processor | wc -l) \
    -runtime=120 \
    -group_reporting \
    -name=random_write_report \
    > random_write_report_$(date '+%Y%m%d_%H_%M_%S')
}

random_read
random_write

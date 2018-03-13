#!/usr/bin/env bash

# Author: Phil Huang <phil_huang@edge-core.com>

# References:
# http://benjr.tw/34632
# https://wsgzao.github.io/post/fio/
# https://askubuntu.com/questions/724228/how-to-find-the-number-of-cpu-cores-including-virtual

# Fail on error
set -e

# Fail on unset var usage
set -o nounset

DISK="/dev/sdb"

if which onl-platform-show &> /dev/null;
then
    onl-platform-show > onl-platform-show_information
else
    echo "Please run the script on ONL"
    exit 1
fi

# Install fio if not exist
if ! which fio &> /dev/null; then
    echo "Install Flexible I/O Tester (FIO)"
    apt update -y
    apt install fio -y
fi

# Show FIO version
fio --version

# Show Platform Name
echo $(onl-platform-show | grep "Platform Name")

function refresh {
    # Clear the memory cache
    echo "Refresh the memory cache"
    sync && echo 3 > /proc/sys/vm/drop_caches
    sleep 1
}

# Running Random 4K Testing 
# Rule:
# 1. Block size 4k
# 2. IO Depth 128
# 4. Only 4 thread

# Random Read
function random_read {

refresh

echo "Start Running Random 4k Read Testing"
fio -filename=${DISK} \
    -direct=1 \
    -iodepth=128 \
    -thread \
    -rw=randread \
    -ioengine=libaio \
    -bs=4k \
    -size=4G \
    -numjobs=$(cat /proc/cpuinfo | grep processor | wc -l) \
    -runtime=120 \
    -group_reporting \
    -name=random_read_report \
    > random_read_report_$(date '+%Y%m%d_%H_%M_%S')
echo
}

function random_write {

refresh

echo "Start Running Random 4k Write Testing"
fio -filename=${DISK} \
    -direct=1 \
    -iodepth=128 \
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
echo
}

random_read
random_write


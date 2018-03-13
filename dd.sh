#!/usr/bin/env bash

# Author: Phil Huang <phil_huang@edge-core.com>

# References:
# https://www.cyberciti.biz/faq/howto-linux-unix-test-disk-performance-with-dd-command/
# https://www.binarytides.com/linux-test-drive-speed/

# Fail on error
set -e

# Fail on unset var usage
set -o nounset

# Variable
DISK=/dev/sdb
echo "Make sure you choose correct disk for testing: ${DISK}"

# Touch a New Report
REPORT_NAME=dd_report_$(date '+%Y%m%d_%H_%M_%S')
touch ${REPORT_NAME}

# Check whether dd is exist or not 
if ! which dd &> /dev/null; then
    "Please install dd for disk I/O testing"1
    exit 1
fi

# Clear the memory cache
echo "Fresh the memory cache"
sync && echo 3 > /proc/sys/vm/drop_caches
sleep 1


# Rule:
# 1. Block size is 4k
# 2. Use random data (/dev/urandom)
# 3. Create 128MB file
#
# Example:
# dd if=path/to/input_file of=/path/to/output_file bs=block_size count=number_of_blocks

# Write Testing
echo "===================" >> ${REPORT_NAME}
echo "Write Speed Testing" >> ${REPORT_NAME}
echo "===================" >> ${REPORT_NAME}
dd oflag=direct,nonblock \
   if=/dev/urandom \
   of=./4k_file \
   bs=4k \
   count=32768 \
   >> ${REPORT_NAME} 2>&1

echo "" >> ${REPORT_NAME}

# Read Testing
echo "==================" >> ${REPORT_NAME}
echo "Read Speed Testing" >> ${REPORT_NAME}
echo "==================">> ${REPORT_NAME}
dd oflag=nonblock \
   if=./4k_file \
   of=/dev/null \
   bs=1024 \
   count=512 \
   >> ${REPORT_NAME} 2>&1

cat ${REPORT_NAME}
rm 4k_file

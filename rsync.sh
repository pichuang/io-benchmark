#!/usr/bin/env bash

# Author: Phil Huang <phil_huang@edge-core.com>
# The sciprt just use it for developing only.

set -x

SRC="/Users/roan/code/io-benchmark"
DST="/root/"
DST_IP="192.168.100.3"

rsync -avh ${SRC} root@${DST_IP}:${DST}
#!/bin/bash

iperf -c $1 -u -i 1 -t $2 -b 20m -l 100

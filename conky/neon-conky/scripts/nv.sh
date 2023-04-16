#!/usr/bin/env fish


# a script to collect relevent nvidia information for conky

set nvUsage (nvidia-smi -q | grep "Gpu" | awk '{print $3" "$4}')
set nvFreq  (nvidia-smi -q | grep -m 1 "Graphics" | awk  '{print $3" "$4 }')
set nvMemUsage (nvidia-smi -q | grep -m 1 "Memory" | awk '{print $1" "$4}')

echo $nvUsage
echo $nvFreq
echo $nvMemUsage

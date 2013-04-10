#!/bin/bash

input=($(echo $*))
dic=~/epwing/Shogakukan
result=$(./eb.sh $dic "${input[0]}")
echo "$result" | head -n 1
result=$(echo "$result" | sed -e "1d")
echo "$result" | sed ':a;N;$!ba;s/\n/ /g;s/　//g'


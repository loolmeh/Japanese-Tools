#!/bin/bash

input=($(echo $*))
dic=~/epwing/Kanjigen
./eb.sh $dic "${input[0]}" | sed ':a;N;$!ba;s/\n/|/g;s/\s//g'

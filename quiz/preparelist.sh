#!/bin/bash

query="$@"
list=$query
total=$(wc -l $list | sed 's/\s.*//g')
total=$((total + 1))

for i in $(seq 1 $total); do
  word=$(awk "NR==$i" $list)
  chknji=$(echo $word | perl -CIO -pi -e 's/\p{Han}/foo/g')
  chknji=$(echo "$chknji" | grep -o "foo")
  if [[ ! -z $chknji ]]; then
  lookup=$(bash ../jmdict/jm.sh "$word" | head -n 1)
  kanji=$(echo "$lookup" | sed 's/ \[.*//g')
  reading=$(echo "$lookup" | grep -o '\[.*\]' | sed 's/\[//g; s/\]//g')
  def=$(echo "$lookup" | sed 's/.*\]//g')
    if [[ ! $lookup = 'Unknown word.' ]] && [[ $word == $kanji ]] ; then
  echo "$kanji|$reading|$def"
    fi
  fi
done

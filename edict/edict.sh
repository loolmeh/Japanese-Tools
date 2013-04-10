#!/bin/bash

input=($(echo "$*"))
Eon=0

lkup()
{
  query="$1"
  result=$(sed -n "/$query/p" edict_processed | sort -nr | awk -F'\t' '{print "(frq: " $1 "%) " $11 " [" $12 "] " $13}' | head -n 15)
}

seperate()
{
  query="$(echo "$@" | sed 's/\s/.*/g')"
}
  
seperate "${input[@]}"
lkup "$query"

if [[ -z $result ]]; then
  echo "No result."
else
  echo "$result"
fi


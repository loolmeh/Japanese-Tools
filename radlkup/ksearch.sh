#!/bin/bash

input="$@"
input=($input)

insertspaces()
{
input=$(echo "$input" | sed 's/./& /g')
input=($input)
}

preparesearch()
{
search=
for i in ${input[@]} ; do
  search="/$i/"" && $search"
done
search=$(echo "$search" | sed 's/ && $//g')
}

dolookup()
{
result=$(awk "$search "'{ print $1 }' kanji)
result=$(echo $result | sed ':a;N;$!ba;s/\n/ /g')
result=($result)
}

insertspaces
preparesearch
dolookup

mresult="${result[@]}"
mresult=($mresult)
oresult="${result[@]}"
oresult=($oresult)
remaining=
flength=1
ilength=0
while [[ ! $flength -eq $ilength ]] && [[ ! $flength -gt 20 ]]; do
  ilength=${#mresult[@]}
  remaining=()
  for i in ${oresult[@]} ; do
    #lookup the current component from original results
    input=()
    input=$i  
    preparesearch
    dolookup
    nresult="${result[@]}"
    #remove the original component from the list
    nresult=($(echo "$nresult" | sed "s/$i//g"))
    #append new result to list of remaining components
    remaining="$remaining${nresult[@]}"
      
  done
  input=()
  input=$remaining
  insertspaces
  oresult="${input[@]}"
  oresult=($oresult)
  mresult="${mresult[@]} $remaining"
  mresult=($mresult)
  flength=${#mresult[@]}
done
echo "${mresult[@]}"

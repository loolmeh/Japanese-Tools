#!/bin/bash

query="$@"

if [[ -z "$query"  ]]; then

## random doujin
  dmax=$(curl -s "http://www.fakku.net/doujinshi/newest" | \
         grep -o "Page.*of.*<b>.*" | grep -o "of.*" | \
         sed 's/of.*<b>//g ; s/<..>//g')
  dmax=$((dmax + 1))
  let "drand = $RANDOM % $dmax"
  d="$(lynx -dump http://www.fakku.net/doujinshi/newest/page/$drand)"
  d="$( echo "$d" | grep -o ".*/doujinshi/.*" | \
        sed 's/[0-9]*\. //g ; s/.*newest.*//g ; s/.*tag.*//g ; s/.*\/english//g ; s/.*\/japanese.*//g ; s/.*series.*//g ; s/.*artists.*//g ; s/.*popular.*//g ; s/.*random.*//g ; s/.*favorites.*//g ; s/.*controversial.*//g ; s/\s//g ; /^$/d'
     )"
##random manga

  mmax=$(curl -s "http://www.fakku.net/manga/newest" | \
         grep -o "Page.*of.*<b>.*" | grep -o "of.*" | \
         sed 's/of.*<b>//g ; s/<..>//g')
  mmax=$((mmax + 1))
  let "mrand = $RANDOM % $mmax"
  m="$(lynx -dump http://www.fakku.net/manga/newest/page/$mrand)"
  m="$(echo "$m" | grep -o ".*/manga/.*" | sed 's/[0-9]*\. //g ; s/.*newest.*//g ; s/.*tag.*//g ; s/.*\/english//g ; s/.*series.*//g ; s/.*artists.*//g ; s/.*popular.*//g ; s/.*random.*//g ; s/.*favorites.*//g ; s/.*controversial.*//g ; s/.*\/japanese.*//g ; s/\s//g ; /^$/d'
      )"
  dm="$d $m"
  echo "$dm" | sort -R | head -n 1

else
  search=$(echo -ne "$query" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
  smax=$(curl -s "http://www.fakku.net/search/$search" | \
         grep -o "Page.*of.*<b>.*" | grep -o "of.*" | \
         sed 's/of.*<b>//g ; s/<..>//g')
  smax=$((smax + 1))
  let "srand = $RANDOM % $smax"
  s="$(lynx -dump http://www.fakku.net/search/$search/page/$srand)"
  s="$( echo "$s" | grep -oE ".*/manga/.*|.*/doujinshi/.*" | sed 's/[0-9]*\. //g ; s/.*newest.*//g ; s/.*tag.*//g ; s/.*\/english//g ; s/.*series.*//g ; s/.*artists.*//g ; s/.*popular.*//g ; s/.*random.*//g ; s/.*favorites.*//g ; s/.*controversial.*//g ; s/.*\/japanese.*//g ; s/\s//g ; /^$/d'
      )"
  echo "$s" | sort -R | head -n 1
fi

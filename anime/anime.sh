#!/bin/bash
# get anime from anidb

query="$*"
urltitle()
{
   local name="$(wget --user-agent="Mozilla" -qO- "$@" | gunzip |\
   awk '/<h1 class="anime">/ {gsub(/.*<h1 class="anime">/,"");gsub(/<\/h1>.*/,"");print}')"
   echo "$name" | sed 's/^Anime: //'
}


   wget -qO- "http://anisearch.outrance.pl/?task=search&query=$query" |\
      awk 'BEGIN{ RS="\">"}{gsub(/.*<anime aid="/,"");print}' |\
      grep -o "^[0-9]\+" | sort -u | head -5 |\
      while read i; do echo "http://anidb.net/a$i - $(urltitle "http://anidb.net/a$i")"; done
}


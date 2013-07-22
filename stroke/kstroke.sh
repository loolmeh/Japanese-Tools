#!/bin/bash

kanji="$@"

s=$(
   lynx -dump "http://www.google.co.uk/search?output=search&sclient=psy-ab&q=site:kakijun.jp+$kanji" | \
   grep -o "http://kakijun.jp/page/.*\.html" | head -n 1 | \
   sed 's/http:\/\/kakijun.jp\/page\///g ; s/\.html//g') 
echo "http://kakijun.jp/gif/$s.gif"

exit 0

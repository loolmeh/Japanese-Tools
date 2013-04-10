#!/bin/bash

query="$@"

if [[ -z $query ]]; then

p=$RANDOM
let "p %= 10000001"
s=$( lynx -dump "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=$p" ); 
echo $s | \
grep -o "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=[0-9]*" | \
sort -R | head -n 1

else

p=$RANDOM
let "p %= 20"
s=$( lynx -dump "http://www.pixiv.net/search.php?word=$query&p=$p" )
s=$( echo $s | grep -o "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=[0-9]*" )
s1=$( lynx -dump "http://www.pixiv.net/search.php?word=$query" )
s1=$( echo $s | grep -o "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=[0-9]*" ); 
s="$s1 $s"
echo -e "$s" | sed 's/\s/\n/g' | sort -R | head -n 1
fi

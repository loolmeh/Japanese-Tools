#!/bin/bash

query=$(echo "$*")
s=$( lynx -dump "http://danbooru.donmai.us/posts?&tags=""$query" )
echo $s | \
grep -o "http://danbooru.donmai.us/posts/[0-9]*" | \
sort -R | head -n 1

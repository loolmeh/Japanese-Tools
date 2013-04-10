#!/bin/bash

url="en.wikipedia.org/wiki/"

input=($(echo $*))
Don=0
Son=0

# direct look up
lookup()
{
  qurl="$url$query"
  result=$(
  curl -s "$qurl" | sed '/<div id="mw-content-text"/,/<\/p>/!d' | grep "<p><b>" | html2text -utf8 | sed ':a;N;$!ba;s/\n/ /g' | head -n 20
  )
} 

# look up disambiguation page only
disamb()
{
  qurl="$url$query"
  result=$(
  curl -s "$qurl" | sed '/table>/,/Retrieved/!d' | html2text -utf8 | sed 's/Retrieved from.*//g;s/This disambiguation.*//g;s/\[Disambiguation.*//g;s/.*internal_link.*//g;s/.*the link to.*//g;s/(disambiguation)&.*//g' | sed '/^$/d' | head -n 20
  )
}

# look up search page only
search()
{
  qurl="http://en.wikipedia.org/w/index.php?title=Search&search=$query&fulltext=Search"
  result=$(
  curl -s "$qurl" | \
  sed '/table>/,//!d' | \
  sed "/mw-search-results/,//!d" | html2text -utf8 | \
  head -n 20 
  )
}

#shorten url using waa.ai
shorten()
{
  surl=$(curl -s "http://api.waa.ai/?url="$qurl) 
}

# search page option
if [[ "${input[0]}" == "+search" || "${input[0]}" == "+s" ]]; then
  Son=1
  #remove options
  query=$(echo "$@" | sed 's/\+[a-z]*\s//g;s/\s+.*$//g')
  #url encode
  query=$(echo -ne "$query" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
  search
fi

## make query ready for wikipedia urls
query=$(echo "${input[@]}" | sed 's/+.*\s//g;s/\s+.*$//g') #remove any pesky options
query=$(echo "$query" | sed 's/\s/_/g') #replace spaces by underscores
temp1=$(echo -ne "$query" | grep -o "^." | tr '[:lower:]' '[:upper:]') #make first letter capital
temp2=$(echo -ne "$query" | sed 's/^.//g')
query="$temp1$temp2"

# check if it's a disambiguation page
test1=$(curl -s "en.wikipedia.org/wiki/$query" | grep -o "may refer to")
# check for a disambiguate option
test2=$(echo "${input[@]}" | grep -o "+d")

if [[ ! -z $test1 ]] && [[ $Son == 0 ]]; then
  Don=1
  disamb
fi

if [[ ! -z $test2 ]]; then
  Don=1
  # prepare keyword
  query=$query"_(disambiguation)"
  # url encode
  query=$(echo -ne "$query" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
  disamb
fi

#direct lookup
if [[ $Don == 0 && $Son == 0 ]]; then
  lookup
fi

if [[ -z $result ]]; then
  echo "No result."
else
  shorten
  echo "More at $surl"
  echo "$result"
fi

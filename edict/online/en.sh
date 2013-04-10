#!/bin/bash

query=$( echo "$*" | sed 's/ /%20/g')

curl -s "http://www.csse.monash.edu.au/~jwb/cgi-bin/wwwjdic.cgi?1ZDE"$query | html2text -utf8 | head -n 10

echo "more at http://www.csse.monash.edu.au/~jwb/cgi-bin/wwwjdic.cgi?1MDE"$query

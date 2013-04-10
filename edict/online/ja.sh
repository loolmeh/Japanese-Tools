#!/bin/bash

curl -s "http://www.csse.monash.edu.au/~jwb/cgi-bin/wwwjdic.cgi?1ZUQ"$1 | html2text -utf8 | head -n 10

echo "more at http://www.csse.monash.edu.au/~jwb/cgi-bin/wwwjdic.cgi?1MUQ"$(echo -ne "$1" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')

exit 0

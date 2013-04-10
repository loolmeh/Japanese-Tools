#!/bin/bash

curl -s "http://www.csse.monash.edu.au/~jwb/cgi-bin/wwwjdic.cgi?9ZIG"$1 | html2text -utf8

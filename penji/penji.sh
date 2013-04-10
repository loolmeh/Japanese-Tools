#!/bin/bash

if [[ $# -ne 1 ]]; then
echo "Please enter one kanji."

else
  base="http://www.yamasa.cc/ocjs/"
  query=$(echo -ne "$*" | sed 's/ /+/g' | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
  url=$(curl -s "http://www.yamasa.cc/ocjs/kanjidic.nsf/SortedByKanji2THEnglish/"$query"?OpenDocument" | html2text | grep hw.gif | sed -e 's/ //g' | sed -e 's/gif.*/gif/g')
  url=$base$url
  surl=$(curl -s "http://waa.ai/api.php?url="$url)
  echo $surl
fi

exit 0
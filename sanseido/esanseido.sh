#!/bin/bash

if [[ -z "$*" ]]; then
echo "Enter a japanese word."

else
  q=$(echo -ne "$*" | sed 's/ /+/g' | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
  result=$(curl -s "http://www.sanseido.net/User/Dic/Index.aspx?TWords="$q"&st=0&DORDER=171615&DailyJE=checkbox" | sed -e '/wordBody/,/dl>/!d' | sed -e 's/<[^>]*>//g' | tr '\n' ' ' | sed -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [[ -z $result ]]; then 
  echo "No Result"
  else
    echo $result
  fi

fi
exit 0

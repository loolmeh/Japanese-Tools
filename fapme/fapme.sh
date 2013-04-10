#!/bin/sh
# Random doujin from fakku

# escape function
_escape()
{
   while read -r pipe; do
      echo "$pipe" | sed -e 's/[ ]/-/g' -e 's/[^a-Z0-9-]//g' -e 's/--*/-/g'
   done
}

# mode function
_mode()
{
   echo "$1" | sed "s/$2//"
}

# search function
_search()
{
   local SEARCH="$@"
   local MAX=$(wget "$SEARCH" -qO - | sed -n 's/.*href=".*\/page\/\(.*\)" title=.*>Last<\/a>.*/\1/p')
   [[ -n "$MAX" ]] && echo "$SEARCH/page/$((RANDOM%($MAX+1)))"
   [[ -n "$MAX" ]] || echo "$SEARCH"
}

urltitle()
{
   local name="$(wget -qO- "$@" | awk '/<title>/ {gsub(/.*<title>/,"");gsub(/<\/title>.*/,"");print}')"
   echo "$name"
}

main() {
   local URL=""
   local MANGA=""
   local SEARCH="$@"
   local MODE=0

   [[ "$SEARCH" == +vn* ]] && {
      SEARCH="$(echo $SEARCH | sed 's/\+vn//')"
      SEARCH=$(echo $SEARCH)
      [[ -n "$SEARCH" ]] || wget -qS "http://vndb.org/v/rand" -O /dev/null 2>&1 | sed -n 's/..Location:.\(.*\)/\1/p' |\
         while read i; do echo "$i - $(urltitle $i)"; done
      [[ -n "$SEARCH" ]] && wget -q "http://vndb.org/v/all?sq=$SEARCH" -O - | grep -o "/v[0-9]\+" | sed '$d' | sort -u |\
         head -5 | while read i; do echo "http://vndb.org$i - $(urltitle "http://vndb.org$i")"; done
      return;
   }
   [[ "$SEARCH" == +original* ]] && MANGA="manga/" \
   && SEARCH="$(echo $SEARCH | sed 's/\+original//')"
   SEARCH=$(echo $SEARCH)

   if [[ -n "$SEARCH" ]]; then
      MODE=4
      [[ "$SEARCH" == tag:* ]]      && MODE=1 && SEARCH="$(_mode "$SEARCH" "tag:")"
      [[ "$SEARCH" == artist:* ]]   && MODE=2 && SEARCH="$(_mode "$SEARCH" "artist:")"
      [[ "$SEARCH" == series:* ]]   && MODE=3 && SEARCH="$(_mode "$SEARCH" "series:")"
   fi

   SEARCH=$(echo $SEARCH)
   [[ $MODE -eq 4 ]] || SEARCH="$(echo "$SEARCH" | _escape)"
   [[ $MODE -eq 0 ]] && URL="http://www.fakku.net/${MANGA}newest"
   [[ $MODE -eq 1 ]] && URL="$(_search "http://www.fakku.net/${MANGA}tags/$SEARCH")"
   [[ $MODE -eq 2 ]] && URL="$(_search "http://www.fakku.net/${MANGA}artists/$SEARCH")"
   [[ $MODE -eq 3 ]] && URL="$(_search "http://www.fakku.net/${MANGA}series/$SEARCH")"
   if [[ $MODE -eq 4 ]]; then
      SEARCH="$(echo -n $SEARCH | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')"
      URL="$(_search "http://www.fakku.net/${MANGA}search/$SEARCH")"
   fi

   local DUMP="$(wget "$URL" -qO -)"
   if [[ "$(echo "$DUMP" | grep "Your search did not return any results")" ]]; then
      echo "No fap material found :("
      return
   fi

   local MATCH="$(echo "$DUMP" | sed -n 's/.*<h2><a href="\(.*\)" title=.*/\1/p' | sort -R | head -n1)"
   [[ -n "$MATCH" ]] && echo "http://www.fakku.net$MATCH"
   [[ -n "$MATCH" ]] || echo "No fap material found. Maybe the tag was wrong?"
}
main "$@"

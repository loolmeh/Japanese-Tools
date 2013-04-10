#!/bin/bash

url="http://tatoeba.org/eng/sentences/show/"

isocode=( "acm" "afr" "ain" "ang" "ara" "arz" "ast" "avk" "bel" "ben" "ber" "bos" "bre" "bul" "cat" "ces" "cha" "cmn" "cycl" "cym" "dan" "deu" "dsb" "ell" "eng" "epo" "est" "eus" "ewe" "fao" "fin" "fra" "fry" "gla" "gle" "glg" "grn" "heb" "hin" "hrv" "hsb" "hun" "hye" "ido" "ile" "ina" "ind" "isl" "ita" "jbo" "jpn" "kat" "kaz" "kor" "ksh" "kur" "lad" "lat" "lit" "lld" "lvs" "lzh" "mal" "mar" "mlg" "mon" "mri" "\N" "nan" "nds" "nld" "nob" "non" "nov" "oci" "orv" "oss" "pes" "pms" "pnb" "pol" "por" "que" "qya" "roh" "ron" "rus" "san" "scn" "sjn" "slk" "slv" "spa" "sqi" "srp" "swe" "swh" "tat" "tel" "tgk" "tgl" "tha" "tlh" "toki" "tpi" "tpw" "tur" "uig" "ukr" "urd" "uzb" "vie" "vol" "wuu" "xal" "xho" "yid" "yue" "zsm" )

input=($(echo "$*"))

Von=0
Oon=0
Eon=0
Uon=0
Ton=0
Aon=0
Lon=0
Tron=0


helpmsg()
{
  echo "Usage: <lang1> <lang2> <keyword(s)> <options> or <lang1> <keywords> <options> or just <keyword> <options>"
  echo "Options: +e/+exact: exact match, leaving it out returns non-exact. +s/+short: sort by shorter sentences. +a/+add <arg>: add a sentence to tatoeba. +u/+user <arg>: filter by user. +t/+tag \"arg\": filter by tag. +tr/+translation: search in linked translations +l/+list: filter by list name. +v/+version: print software and csv versions +h/+help: print this message."
  echo "output is randomized by default." 
}

version()
{
  tatoparser --version | head -n 1
  echo -ne "sentences.csv grabbed on "
  ls -l ~/tatodata/sentences.csv | awk '{print $6 " " $7 ", 2013"}' 
}

testiso()
{
  isiso=0
  for i in "${isocode[@]}"
  do
    if [[ $i == "$1" ]]; then
      isiso=1
    break
    fi
  done
}

parse()
{
  oifs=$IFS
    if [[ $Son == 1 ]]; then
  parsed=$(
  IFS=""
  tatoparser -i -r ".*$1.*" ${options[@]} | \
  awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | \
  sort -R | \
  head -n 20
  )
  IFS=$oif
  parsed=$(echo $parsed | awk -v q=$url -F'\t' '{print $2 " " q $1 }')
    else
  parsed=$(
  IFS=""
  tatoparser -i -r ".*$1.*" ${options[@]} | \
  head -n 100 | \
  sort -R | \
  head -n 20
  )
  IFS=$oif
  parsed=$(echo $parsed | awk -v q=$url -F'\t' '{print $2 " " q $1 }')
    fi
  IFS=$oifs
}

parse1()
{
  oifs=$IFS
    if [[ $Son == 1 ]]; then
  parsed1=$(
  IFS=""
  tatoparser -i -r ".*$1.*" -l "$2" ${options[@]} | \
  awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | \
  head -n 20
  )  
  IFS=$oif
  parsed1=$(echo $parsed1 | awk -v q=$url -F'\t' '{print $2 " " q $1 }')
    else
  parsed1=$(
  IFS=""
  tatoparser -i -r ".*$1.*" -l "$2" ${options[@]} | \
  head -n 100 | \
  sort -R | \
  head -n 20
  )
  IFS=$oif
  parsed1=$(echo $parsed1 | awk -v q=$url -F'\t' '{print $2 " " q $1 }')
    fi
  IFS=$oifs
}

parse2()
{
  oifs=$IFS
    if [[ $Son == 1 ]]; then
  parsed2=$(
  IFS=""
  tatoparser -i -r ".*$1.*" -l "$2" --is-translatable-in "$3" --display-first-translation "$3" ${options[@]} | \
  awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | \
  head -n 20
  )
  IFS=$oif
  parsed2=$(echo $parsed2 | awk -v q=$url -F'\t' '{print $2 " " $3 " " q $1 }')
    else
  parsed2=$(
  IFS=""
  tatoparser -i -r ".*$1.*" -l "$2" --is-translatable-in "$3" --display-first-translation "$3" ${options[@]} | \
  head -n 100 | \
  sort -R | \
  head -n 20
  )
  IFS=$oif
  parsed2=$(echo $parsed2 | awk -v q=$url -F'\t' '{print $2 " " $3 " " q $1 }')
    fi
  IFS=$oifs
}

input2="+"$(echo $* | cut -d'+' -f 2-)
input2=($(echo $input2))


i=0
while :
do
  m="${input2[$i]}" 
case "$m" in
  +e | +exact)
    Eon=1
    i=$[$i+1]
    ;;
  +u | +user)
    Uon=1
    ustr=$(echo $* | grep -o "+u.*" | sed 's/^+u\s//g;s/\s+.*//g;s/\s*^//g')
    i=$[$i+2]
    ;;
  +t | +tag)
    Ton=1
    tstr=$(echo $* | grep -o "+t.*" | sed 's/^+t\s//g;s/\s+.*//g;s/\s*^//g')
    i=$[$i+2]
    ;;
  +s | +short)
    Son=1
    i=$[$i+1]
    ;;
   +l | +list)
    Lon=1
    lstr=$(echo $* | grep -o "+l.*" | sed 's/^+l\s//g;s/\s+.*//g;s/\s*^//g')
    i=$[$i+2]
    ;;
  +tr | +translation)
     Tron=1
     trstr=$(echo $* | grep -o "+tr.*" | sed 's/^+tr\s//g;s/\s+.*//g;s/\s*^//g')
     i=$[$i+2]
     ;;
   *)
    break
    ;;
esac

done

q1=${input[0]}
q2=${input[1]}

if [[ "$q1" == "+v" ]] || [[ "$q1" == "+version" ]]; then
  Oon=1
  version
fi

if [[ "$q1" == "+h" ]] || [[ "$q1" == "+help" ]]; then
  Oon=1
  helpmsg
fi

username=
hashedpass=
if [[ "$q1" == "+a" ]] || [[ "$q1" == "+add" ]]; then
Oon=1
astr=$(echo "$*" | cut -d' ' -f 2-)
astr="$(echo -ne "$astr" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')"
  out=$(curl -b "CakeCookie[User]=username|$username,password|$hashedpass" --data "selectedLang=auto&value=$astr" http://tatoeba.org/epo/sentences/add_an_other_sentence )
  id=$(echo "$out" | grep -o 'id=.translate_[0-9]*' | sed 's/^.*_//g')
  if [[ -z $id  ]]; then
    echo "Sorry the server might be down. Try again later."
  else
    id="$url$id"
    echo "Sentence successfully added: "$id
  fi
fi

test=$(echo $* | sed 's/^\s*//g' | grep -o "^+")
test2=$(echo $* | sed 's/^\s*//g' | cut -d'+' -f 2 | cut -d' ' -f1 | grep -o "[lvutha]")
if [[ ! -z $test ]] && [[ -z $test2 ]]; then
  echo "Please put your options at the end, thanks."
  exit 0
fi

options=()

if [[ $Uon == 1 ]]; then
  options[0]="-u"
  options[1]="$ustr"
fi

if [[ $Ton == 1 ]]; then
  options[2]="-g"
  options[3]="$tstr"
fi

if [[ $Lon == 1 ]]; then
  options[4]="--in-list"
  options[5]="$lstr"
fi

if [[ $Tron == 1 ]]; then
  trstr=$(echo "$trstr" | sed 's/\s/\./g')
  options[6]=" -p"".*$trstr.*"
fi

testiso "$q1"
if [[ $isiso == 1 ]]; then
  q1on=1
else
  q1on=0
fi

testiso "$q2"
if [[ $isiso == 1 ]]; then
  q2on=1
else
  q2on=0
fi

if [[ $q1on == 0 ]]&& [[ $Oon == 0 ]] && [[ $Eon == 0 ]]; then
  
  query=$(echo "$@" | cut -d'+' -f 1 | sed 's/\s$//g')
  query=$(echo "$query" | sed 's/\s/\.\*/g')
  parse "$query"
  test=$( echo "$parsed" | grep -o "/show/$")
  if [[ -z $parsed ]] || [[ ! -z $test ]]; then
    echo "No result."
  else
    printf "$parsed"
  fi
fi

if [[ $q1on == 0 ]]&& [[ $Oon == 0 ]] && [[ $Eon == 1 ]]; then
  
  query=$(echo "$@" | cut -d'+' -f 1 | sed 's/\s$//g')
  parse "$query"
  test=$( echo "$parsed" | grep -o "/show/$")
  if [[ -z $parsed ]] || [[ ! -z $test ]]; then
    echo "No result."
  else
    printf "$parsed"
  fi
fi

if [[ $q1on == 1 ]] && [[ $q2on == 0 ]] && [[ $Oon == 0 ]] && [[ $Eon == 0 ]]; then
  
  query=$(echo $@ | cut -d' ' -f 2-)
  query=$(echo "$query" | cut -d'+' -f 1 | sed 's/\s$//g')
  query=$(echo $query | sed 's/\s/\.\*/g')
  parse1 "$query" "$q1"
  test1=$( echo "$parsed1" | grep -o "/show/$")
  if [[ -z $parsed1 ]] || [[ ! -z $test1 ]]; then
    echo "No result."
  else
    printf "$parsed1"
  fi
fi

if [[ $q1on == 1 ]] && [[ $q2on == 0 ]] && [[ $Oon == 0 ]] && [[ $Eon == 1 ]]; then
  
  query=$(echo "$@" | cut -d' ' -f 2-)
  query=$(echo "$query" | cut -d'+' -f 1 | sed 's/\s$//g')
  parse1 "$query" "$q1"
  test1=$( echo "$parsed1" | grep -o "/show/$")
  if [[ -z $parsed1 ]] || [[ ! -z $test1 ]]; then
    echo "No result."
  else
    printf "$parsed1"
  fi
fi

if [[ $q1on == 1 ]] && [[ $q2on == 1 ]] && [[ $Oon == 0 ]] && [[ $Eon == 0 ]] ; then 
  
  query=$(echo "$@" | cut -d' ' -f 3-)
  query=$(echo "$query" | cut -d'+' -f 1 | sed 's/\s$//g')
  query=$(echo "$query" | sed 's/\s/\.\*/g')
  parse2 "$query" "$q1" "$q2"
  test2=$( echo "$parsed2" | grep -o "/show/$")
  if [[ -z $parsed2 ]] || [[ ! -z $test2 ]]; then
    echo "No result."
  else
    printf "$parsed2"
  fi
fi

if [[ $q1on == 1 ]] && [[ $q2on == 1 ]] && [[ $Oon == 0 ]] && [[ $Eon == 1 ]]; then
  
  query=$(echo "$@" | cut -d' ' -f 3-)
  query=$(echo "$query" | cut -d'+' -f 1 | sed 's/\s$//g')
  parse2 "$query" "$q1" "$q2"
  test2=$( echo "$parsed2" | grep -o "/show/$")
  if [[ -z $parsed2 ]] || [[ ! -z $test2 ]]; then
    echo "No result."
  else
    printf "$parsed2"
  fi
fi
exit 0

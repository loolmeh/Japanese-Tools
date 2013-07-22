#!/bin/bash

query="$@"
tmp=$(cat temp/tmp)
line=$(echo "$tmp")
word=$(echo "$line" | sed 's/|.*//g')
reading=$(echo "$line" | grep -o "|.*|" | sed "s/|//g")
def=$(echo $line | sed 's/.*|//g')
fline="$word [$reading] $def"
level=$(cat temp/clvl | sed 's/\s.*//g')
total=$(cat temp/clvl | sed 's/.*\s//g')
user=$DMB_SENDER
misfile=$user"mis"
corfile=$user"cor"

if [[ ! -d temp ]];then
  mkdir -p temp
fi

if [[ ! -f temp/tmp ]];then
  touch temp/tmp
fi

if [[ ! -f temp/clvl ]]; then
  touch temp/clvl
fi

if [[ ! -d temp/stats ]];then
  mkdir -p temp/stats
fi

if [[ ! -f temp/stats/$misfile ]];then
  touch temp/stats/$misfile
fi

if [[ ! -f temp/stats/$corfile ]];then
  touch temp/stats/$corfile
  echo "0 0" > temp/stats/$corfile
fi

randomw()
{
  randn=
  let "randn = $RANDOM % $total"
  line=$(awk "NR==$randn" vocab/$level)
  echo "$line" > temp/tmp
  word=$( echo "$line" | sed 's/|.*//g')
}

checkreading()
{
  reading=$(echo "$line" | grep -o "|.*|" | sed "s/,/ /g; s/|//g")
  reading=($reading)
  iscorrect=0
  for i in "${reading[@]}"; do
    if [ "$query" == "$i" ]; then
    iscorrect=1
    fi
  done
  
}

getlvl()
{
  list=$(ls vocab)
  list=($list)
  c=0
  for i in ${list[@]} ; do
  size[$c]=$(wc -l vocab/$i | sed 's/\s.*//g')
  c=$((c+1))
  done
}

printlvl()
{
  t=${#list[@]}
  t=$((t-1))
  for i in $(seq 0 $t) ; do
  echo -ne "${list[$i]} (${size[$i]})  "
  done
}

getstats()
{
  cor=$(cat temp/stats/$corfile | sed 's/\s.*//g')
  mis=$(cat temp/stats/$corfile | sed 's/.*\s//g')
}

addcor()
{
  cor=$((cor+1))
  echo "$cor $mis" > temp/stats/$corfile
}

addmis()
{
  mis=$((mis+1))
  echo "$cor $mis" > temp/stats/$corfile
  echo "$word" >> temp/stats/$misfile 
}

printstats()
{
  getstats
  tot=$((mis+cor))
  acc=$(echo "$cor/$tot*100" | bc -l)
  acc=$(printf "%.2f" $acc)
  echo "$user has answered $cor/$tot correctly, with an accuracy of $acc%."
  echo -ne "words that need attention: "
  awk '{print}' temp/stats/$misfile | tail -n 15 | sed ':a;N;$!ba;s/\n/ /g'
}

hashira=$(echo "$query" | perl -CIO -pi -e "s/\p{Hiragana}/foo/g" )
hashira=$(echo "$hashira" | grep -o "foo")
if [[ ! -z $hashira ]]; then
  checkreading
  if [[ $iscorrect == 1 ]]; then
    echo "correct!"
    echo "$fline"
    getstats
    addcor
    sleep 2
    randomw
    echo "Please read: $word"
  else
    echo "Sorry, Wrong reading."
    getstats
    addmis
  fi
fi

if [[ $query == "skip" ]] || [[ $query == "Skip" ]]; then
  echo "Skipping $word"
  echo "$fline"
  sleep 2
  randomw
  echo "Please read: $word"
fi

query=($query)
if [[ ${query[0]} == "stats" ]] && [[ -z ${query[1]} ]] ; then
  printstats
fi

if [[ ${query[0]} == "stats" ]] && [[ ! -z ${query[1]} ]] ; then
  user=${query[1]}
  misfile=$user"mis"
  corfile=$user"cor"
  if [[ ! -f temp/stats/$misfile ]]; then
    echo "Not a valid user."
  else
    printstats
  fi
fi

getlvl

if [[ -z $query ]]; then
  echo "Please enter a valid level. Levels available:"
  printlvl
fi

if [[ -z $hashira ]] && [[ ! $query == "skip" ]] && [[ ! -z $query ]] && [[ ! $query == "stats" ]]; then
  islevel=0
  for i in "${list[@]}" ; do
    if [[ $query == $i ]]; then
      islevel=1
    fi
  done
  if [[ $islevel == 1 ]]; then
    level=$query
    total=$(wc -l vocab/$query | sed 's/\s.*//g')
    echo "$level $total" > temp/clvl
    randomw
    echo "Please read: $word"
  else
    echo "Not a valid level."
    printlvl
  fi
fi


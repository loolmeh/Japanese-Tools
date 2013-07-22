#!/bin/bash

query="$@"
cnick=$DMB_SENDER
line=$(cat temp/tmp)
word=$(echo "$line" | sed 's/|.*//g')
reading=$(echo "$line" | grep -o "|.*|" | sed "s/|//g")
def=$(echo $line | sed 's/.*|//g')
fline="$word [$reading] $def"
level=$(cat temp/clvl | sed 's/\s.*//g')
total=$(cat temp/clvl | sed 's/.*\s//g')
user=$cnick
misfile=$user"mis"
corfile=$user"cor"
score=$(cat temp/score/$cnick)
start=$(cat temp/ttmp)

if [[ ! -d temp ]];then
  mkdir -p temp
fi

if [[ ! -f temp/tmp ]];then
  touch temp/tmp
fi


if [[ ! -d temp/score ]];then
  mkdir -p temp/score
fi

if [[ ! -f temp/score/$cnick ]];then
  touch temp/score/$cnick
  echo "0" > temp/score/$cnick
fi

if [[ ! -d temp/elo ]];then
  mkdir -p temp/elo
fi

if [[ ! -f temp/elo/$cnick ]];then
  touch temp/elo/$cnick
  echo "1500" > temp/elo/$cnick
fi

if [[ ! -f temp/elorank ]];then
  touch temp/elorank
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

if [[ ! -f temp/ttmp ]];then
  touch temp/ttmp
fi

if [[ -z $start ]];then
start=$(date +%s)
echo "$start" > temp/ttmp
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

gamescore()
{

c=0
echo "" > temp/score/final

for i in $(ls temp/score); do
names[$c]=$i
scores[$c]=$(cat temp/score/$i)
echo "${names[$c]} ${scores[$c]}" >> temp/score/final
c=$((c+1))
done

top=$(cat temp/score/final | sort -nrk 2 | awk 'NR==1 {print $1}')
topsc=$(cat temp/score/final | sort -nrk 2 | awk 'NR==1 {print $2}')
next=$(cat temp/score/final | sort -nrk 2 | awk 'NR==2 {print $1}')
nextsc=$(cat temp/score/final | sort -nrk 2 | awk 'NR==2 {print $2}')

if [[ $topsc == $nextsc ]];then
  echo "it's a tie. $topsc-$nextsc"
else
  echo "The winner is $top. $topsc-$nextsc"
fi

}

elo()
{
  rating1=$1
  rating2=$2
  score1=$3
  score2=$4
  e=0
  if [[ ! $score1 -eq $score2 ]]; then

    if [[ $score1 -gt $score2 ]];then
      e=$(octave --eval "120-(1/(1+(10^(($rating2-$rating1)/400)))*120)" | grep -o 'ans.*' | sed 's/[ans= ]//g;')
      final1=$(echo "$rating1 + $e" | bc -l)
      final2=$(echo "$rating2 - $e" | bc -l)
    else
      e=$(octave --eval "120-(1/(1+(10^(($rating1-$rating2)/400)))*120)" | grep -o 'ans.*' | sed 's/[ans= ]//g;')
      final1=$(echo "$rating1 - $e" | bc -l)
      final2=$(echo "$rating2 + $e" | bc -l)
    fi

  else

    if [[ $rating1 -eq $rating2 ]];then
      final1=$rating1
      final2=$rating2
    else
      
      if [[ $rating1 -gt $rating2 ]];then
        e=$(octave --eval "(120-(1/(1+(10^(($rating1-$rating2)/400)))*120)) - (120-(1/(1+(10^(($rating2-$rating1)/400)))*120))" | grep -o 'ans.*' | sed 's/[ans= ]//g;')
        final1=$(echo "$rating1 - $e" | bc -l)
        final2=$(echo "$rating2 + $e" | bc -l)
      else
        e=$(octave --eval "(120-(1/(1+(10^(($rating2-$rating1)/400)))*120)) - (120-(1/(1+(10^(($rating1-$rating2)/400)))*120))" | grep -o 'ans.*' | sed 's/[ans= ]//g;')
        final1=$(echo "$rating1 + $e" | bc -l)
        final2=$(echo "$rating2 - $e" | bc -l)
      fi

    fi

  fi
}

getelo()
{
  rating1=$(cat temp/elo/$top)
  rating2=$(cat temp/elo/$next)
}

calctime()
{
  max=100
  start=$(cat temp/ttmp)
  secs=$(date +%s)
  time=$(( secs - start ))
  remain=$((max - time))
  if [[ $time -gt $max ]];then
  echo "Game over."
  gamescore
  getelo
  elo $rating1 $rating2 $topsc $nextsc
  echo "$final1" > temp/elo/$top
  echo "$final2" > temp/elo/$next
  rm -rf temp/score
  rm -f temp/ttmp
  exit 0
  fi
  echo "$remain seconds remaining."
  
}

reset()
{
  nicks=($(ls temp/score))
  for i in "${nicks[@]}" ;do
  echo "0" > temp/score/$i
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
    calctime
    score=$(cat temp/score/$cnick)
    score=$((score + 1))
    echo "$score" > temp/score/$cnick
    echo "correct! Your score is $score."
    echo "$fline"
    getstats
    addcor
    sleep 1
    randomw
    echo "Please read: $word"
  else
    calctime
    score=$(cat temp/score/$cnick)
    score=$((score - 1))
    echo "$score" > temp/score/$cnick
    echo "Sorry, Wrong reading. Your score is $score."
    getstats
    addmis
  fi
fi

if [[ $query == "skip" ]] || [[ $query == "Skip" ]]; then
  calctime
  echo "Skipping $word. Your score is unchanged: $score"
  echo "$fline"
  sleep 1
  randomw
  echo "Please read: $word"
fi

if [[ $query == "reset" ]];then
  reset
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

if [[ -z $hashira ]] && [[ ! $query == "skip" ]] && [[ ! -z $query ]] && [[ ! $query == "stats" ]] && [[ ! $query == "rating" ]]; then
  calctime
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

if [[ $query == "rating" ]];then
  elols=$(ls temp/elo)
  ratings=()
  c=0
  echo "" > temp/elorank
  for i in ${elols[@]} ; do
    ratings[$c]=$(cat temp/elo/$i)
    echo "$i ${ratings[$c]}" >> temp/elorank
  c=$((c+1))
  done
  echo "Current ratings: "
  cat temp/elorank | sort -nrk 2
fi

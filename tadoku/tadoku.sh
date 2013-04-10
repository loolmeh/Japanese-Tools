#!/bin/bash

user=$DMB_SENDER #swap with a username for use on the command line
file=./data/$user
date=$(date -u +"%Y年%m月%d日")
input=($(echo $*))
password="password" # change this

amanga=()
abook=()
asent=()
agame=()
afgame=()
aanime=()

Mon=0
Bon=0
Son=0
Gon=0
FGon=0
Aon=0

if [[ "$user" == "banned" ]] || [[ "$user" == "banned2" ]] ; then
  echo "Sorry you're banned."
  exit 1
fi

if [[ ! -d "data" ]];then
  mkdir -p data
fi

if [[ ! -f $file ]];then
  touch $file
  echo -ne "0\t-\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0" > $file
fi

if [[ ! -s $file ]]; then
  echo -ne "0\t-\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0" > $file
fi

id=$[$(awk -F'\t' 'NR==1 {print $1; exit}' $file)+1]
tbook=$(awk -F'\t' 'NR==1 {print $4; exit}' $file)
tmanga=$(awk -F'\t' 'NR==1 {print $6; exit}' $file)
tgame=$(awk -F'\t' 'NR==1 {print $8; exit}' $file)
tfgame=$(awk -F'\t' 'NR==1 {print $10; exit}' $file)
tanime=$(awk -F'\t' 'NR==1 {print $12; exit}' $file)
tsent=$(awk -F'\t' 'NR==1 {print $14; exit}' $file)
total=$(awk -F'\t' 'NR==1 {print $15; exit}' $file)

helpmsg()
{
  echo "options: +b/+book <num>: update book pgs read. +b/+book dr <num>: update double-rowed book pgs read. +m/+manga <num>: update manga pgs read. +g/+game <num>: update game screens read. +fg/+fullgame <num>: update fullgame screens read. +a/+anime <num>: update minutes of anime subs read. +s/+sentence <num>: update number of sentences read. u/undo: delete the previous update. h/history <pg num>: list all update entries 5 per page. h/history +u <nick> <pg num>: list updates for a certain user, 5 entries per page. s/summary: list a summary of all updates. r/rank: rank all participants. ra/rates: display conversion rates. he/help: display the help message" 
}

rates()
{
  echo "rates: everything is converted to the equivalent of a page in a novel published in the tankobon format. 1 book pg= 1 pg, 1 double-rowed book pg= 1.5 pg 5 manga pgs= 1 pg, 20 game screens = 1 pg, 6 fullgame screens = 1 pg, 5 mins of anime= 1 pg, 17 sentences = 1 pg." 
}

interval()
{
  a=()
  i=0
  for ((j=5;j<=$id;j+=5))
  do
    a[i++]=$[$j-4]
    a[i++]=$j
  done

  if [[ $id -lt 5 ]]; then
    a[i++]=1
    a[i++]=$id
 else
  if [[ $[$id%5] == 1 ]]; then
    a[i++]=$id
  elif [[ $[$id%5] -gt 1 ]]; then
    a[i++]=$[$[$id/5*5]+1]
    a[i++]=$id
  fi
 fi

  m=${#a[@]}
  if [[ $[m%2] == 0 ]];then
  maxpg=$[m/2]
  else
  maxpg=$[$[m/2]+1]
  fi
}

history_()
{
  interval
  if [[ $pg == $maxpg ]]; then
    ll=$[$m-1]
    ll=${a[$ll-1]}
    ul=$m
    ul=${a[$ul-1]}
  else
    ll=$[$[$pg*2]-1]
    ll=${a[$ll-1]}
    ul=$[$pg*2]
    ul=${a[$ul-1]}
  fi
  if [[ $pg < $maxpg || $pg == $maxpg ]]; then
    echo "Displaying page $pg/$maxpg for $user"
    awk -v l=$ll -v u=$ul -F'\t' 'NR>=l && NR<=u {printf "%s %s ", $1, $2}; NR>=l && NR<=u && ($3!=0) {printf "Book: %s ", $3}; NR>=l && NR<=u && ($5!=0) {printf "Manga: %s ", $5}; NR>=l && NR<=u && ($7!=0) {printf "Game: %s ", $7}; NR>=l && NR<=u && ($9!=0) {printf "FullGame: %s ", $9}; NR>=l && NR<=u && ($11!=0) {printf "Anime: %s ", $11}; NR>=l && NR<=u && ($13!=0) {printf "Sentence: %s ", $13}; NR>=l && NR<=u {printf "Total: %s\n", $15}' $file
  else
    echo "$user: This page number isn't in your history."
  fi
}

rank()
{
  lnames=$(ls ./data)
  lnames=($(echo $lnames))
  tscore=()
  j=0
  for i in "${lnames[@]}"
  do
    tscore[$j]=$(awk -F'\t' 'NR==1 {print $15; exit}' ./data/$i)
    j=$[$j+1]
  done

  n=${#lnames[@]}
  fsort=
  for i in $(seq 0 $[$n-1]); do
    fsort="$(echo -ne "${lnames[$i]} ${tscore[$i]}\n""$fsort")"
  done
  
  if [[ -z $fsort ]];then
    echo "No records to rank."
  else
    echo "$fsort" | sort -nrk 2
  fi
}

add()
{
  sed -e "1i $id\t$date\t$book\t$tbook\t$manga\t$tmanga\t$game\t$tgame\t$fgame\t$tfgame\t$anime\t$tanime\t$sent\t$tsent\t$total" -i $file
}

sumup()
{
  tbook=$[$book+$tbook]
  tmanga=$[$manga+$tmanga]
  tgame=$[$game+$tgame]
  tfgame=$[$fgame+$tfgame]
  tanime=$[$anime+$tanime]
  tsent=$[$sent+$tsent]
  total=$(printf "%.1f" $(bc -l <<<"$tbook+($tmanga/5)+($tgame/20)+($tfgame/6)+($tanime/5)+($tsent/17)"))
}

summary()
{
  printf "$user: You have read a total of $total pgs: "
  if [[ ! $tbook == "0" ]];then
   printf "$tbook pgs of books "
  fi
  if [[ ! $tmanga == "0" ]];then
   printf "$tmanga pgs of manga "
  fi
  if [[ ! $tgame == "0" ]];then
   printf "$tgame game screens "
  fi
  if [[ ! $tfgame == "0" ]];then 
   printf "$tfgame pgs of fullgame screens "
  fi
  if [[ ! $tanime == "0" ]];then
   printf "$tanime pgs worth of anime minutes "
  fi
  if [[ ! $tsent == "0" ]];then
   printf "$tsent pgs worth of sentences"
  fi
  printf ".\n"
}

undo()
{
  sed -i '1d' $file
}

reset()
{
  rm -rf ./data
  echo "All records have been deleted."
}

resetusr()
{
  rm -f ./data/$1
  echo "All records for $1 have been deleted."
}

rmzusr()
{
  if [[ "$total" == "0" ]];then
  rm -f $file
  fi
}

i=0
while :
do
  m="${input[$i]}" 
case "$m" in
  +m | +manga)
    Mon=1
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: New quantity has to be a number. Use the format +o/+option <number>"
        exit 1
    fi
    amanga[$i]=${input[$i+1]}
    i=$[$i+2]
    ;;
  +b | +book)
    Bon=1
    if [[ "${input[$i+1]}" == "dr" ]]; then
      n="${input[$i+2]}"
      abook[$i]=$[$n*3/2]
      i=$[$i+3]
     else
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: New quantity has to be a number. Use the format +o/+option <number>"
        exit 1
    fi
    abook[$i]=${input[$i+1]}
    i=$[$i+2]
     fi
    ;;
  +g | +game)
    Gon=1
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: New quantity has to be a number. Use the format +o/+option <number>"
        exit 1
    fi
    agame[$i]=${input[$i+1]}
    i=$[$i+2]
    ;;
  +fg | +fullgame)
    FGon=1
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: New quantity has to be a number. Use the format +o/+option <number>"
        exit 1
    fi
    afgame[$i]=${input[$i+1]}
    i=$[$i+2]
    ;;
  +a | +anime)
    Aon=1
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: New quantity has to be a number. Use the format +o/+option <number>"
        exit 1
    fi
    aanime[$i]=${input[$i+1]}
    i=$[$i+2]
    ;;
  +s | +sentence)
    Son=1
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: New quantity has to be a number. Use the format +o/+option <number>"
        exit 1
    fi
    asent[$i]=${input[$i+1]}
    i=$[$i+2]
    ;;
   *)
    break
    ;;

esac

done

if [[ -z $input ]]; then
  helpmsg
fi

manga=0
for i in "${amanga[@]}"
do
  manga=$[$i+$manga]
done

book=0
for i in "${abook[@]}"
do
  book=$[$i+$book]
done

game=0
for i in "${agame[@]}"
do
  game=$[$i+$game]
done

fgame=0
for i in "${afgame[@]}"
do
  fgame=$[$i+$fgame]
done

anime=0
for i in "${aanime[@]}"
do
  anime=$[$i+$anime]
done

sent=0
for i in "${asent[@]}"
do
  sent=$[$i+$sent]
done

if [[ $Mon == 1 || $Bon == 1 || $Son == 1 || $Gon == 1 || \
      $FGon == 1 || $Aon == 1 ]]; then
  sumup
  add
  printf "$user: "
    if [[ $Bon == 1 ]];then
  printf "$book book pgs, "
    fi
    if [[ $Mon == 1 ]];then
  printf "$manga (%.2f) manga pgs, " $(bc -l <<< "scale=2; $manga/5") 
    fi
    if [[ $Gon == 1 ]];then
  printf "$game (%.2f) game screens, " $(bc -l <<< "scale=2; $game/20")
    fi
    if [[ $FGon == 1 ]];then
  printf "$fgame (%.2f) full game screens, " $(bc -l <<< "scale=2; $fgame/6")
    fi
    if [[ $Aon == 1 ]];then
  printf "$anime (%.2f) mins of anime, " $(bc -l <<< "scale=2; $anime/5")
    fi
    if [[ $Son == 1 ]];then
  printf "$sent (%.2f) sentences, " $(bc -l <<< "scale=2; $sent/17")
    fi
  printf "for a total of $total pages.\n"
fi

if [[ ${input[0]} == "undo" ]] || [[ ${input[0]} == "u" ]]; then
  if [[ $[$id-1] == 0 ]]; then
    echo "$user: No more updates to delete."
  else
    undo
    total=$(awk -F'\t' 'NR==1 {print $15; exit}' $file)
    echo "$user: Deleted last update. Your adjusted total page count is: $total"
  fi
fi

rmzusr

if ([[ "${input[0]}" == "history" ]] || [[ "${input[0]}" == "h" ]]) && \
   [[ "${input[1]}" == "+u" ]] ; then
  tst="${input[2]}"
  if [[ -z $(ls -l ./data | grep $tst) ]]; then
    echo "No Such user." ; exit 1
  else
   user=$tst
   file=./data/$user
   id=$[$(awk -F'\t' 'NR==1 {print $1; exit}' $file)+1]
   input[1]="${input[3]}"
   input[2]=
  fi
fi

if [[ "${input[0]}" == "history" ]] || [[ "${input[0]}" == "h" ]]; then
  if [[ -z $(ls -l ./data | grep -w -E "^.*$user$") ]]; then
    echo "$user: Sorry, no history is available for you."
    exit 1
  fi
  pg=1
  id=$[$id-1]
  v=0
  if [[ ! -z "${input[1]}" ]] ; then
    if [[ "${input[1]}" =~ [0-9] ]] && \
       [[ ! ${input[1]} -eq 0 ]] && \
       [[ ! ${input[1]} -lt 0 ]]; then
      pg=${input[1]}
    else
      echo "$user: Not a valid Page number."
      v=1
    fi
  fi
  if [[ $v == 0 ]]; then
  history_
  fi
fi

if [[ "${input[0]}" == "rank" ]] || [[ "${input[0]}" == "r" ]]; then
  rank
fi

if [[ "${input[0]}" == "summary" ]] || [[ "${input[0]}" == "s" ]]; then
  if [[ -z $(ls -l ./data | grep -w -E "^.*$user$") ]]; then
    echo "$user: Sorry, no summary is available for you."
    exit 1
  fi
  summary
fi

if [[ "${input[0]}" == "rates" ]] || [[ "${input[0]}" == "ra" ]]; then
  rates
fi

if [[ "${input[0]}" == "help" ]] || [[ "${input[0]}" == "he" ]]; then
  helpmsg
fi

if [[ "${input[0]}" == "reset" ]] && [[ "${input[1]}" == "$password" ]]; then
  reset
fi

if [[ "${input[0]}" == "reset" ]] && [[ "${input[1]}" == "+u" ]] && [[ "${input[3]}" == "$password" ]]; then
  tst="${input[2]}"
  if [[ -z $(ls -l ./data | grep $tst) ]]; then
    echo "No Such user." ; exit 1
  else
   user=$tst
   file=./data/$user
   resetusr $user
  fi
fi

exit 0

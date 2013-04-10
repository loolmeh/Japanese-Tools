#!/bin/bash

user=$DMB_SENDER
adate=($(date -u +"%Y年%m月%d日 %a %H時%M分"))
jdays=( "Sat" "(土)" "Sun" "(日)" "Mon" "(月)" "Tue" "(火)" "Wed" "(水)" "Thu" "(木)" "Fri" "(金)")
input=($(echo $*))
anew=()
arev=()
new=0
rev=0
Non=0
Ron=0
file=./data/$user
password="password"
msg=("Praise the lords of memory. A new level! (yes it's all thanks to the lords of memory not your hard work)" "Work harder anki slave, just because you got a new level doesn't mean you can slack off!" "Oh my god a new level. Someone stop this beast." "Yay, new level. Now go suck your anki deck some more." "New level unlocked: Anki slave extraordinaire" "Congrats. New level. Now go drown some more in a pool of anki labor sweat and forget about this thing you call your \"life\"." )

if [[ "$user" == "banned" ]] || [[ "$user" == "banned2" ]] ; then
  echo "Sorry you're banned."
  exit 1
fi

if [[ ! -d "data" ]]; then
  mkdir -p data
fi

if [[ ! -f $file ]]; then
  touch $file
  echo -ne "0\t-\t0\t0\t0\t0\t0\t0" > $file
fi

if [[ ! -s $file ]]; then
  echo -ne "0\t-\t0\t0\t0\t0\t0\t0" > $file
fi

id=$[$(awk -F'\t' 'NR==1 {print $1; exit}' $file)+1]
tnew=$(awk -F'\t' 'NR==1 {print $4; exit}' $file)
trev=$(awk -F'\t' 'NR==1 {print $6; exit}' $file)
total=$(awk -F'\t' 'NR==1 {print $7; exit}' $file)
score=$(awk -F'\t' 'NR==1 {print $8; exit}' $file)

helpmsg()
{
  echo -ne "options: +n/+new <number>: update for new cards added. "
  echo -ne "+r/+review <number>: update for cards reviewed. "
  echo -ne "u/undo: delete the previous update. "
  echo -ne "h/history <page number>: list all updates 5 entries per page. "
  echo -ne "h/history +u <nick> <pg number>: list all updates for a certain user. "
  echo -ne "s/summary: list a summary of all updates. "
  echo -ne "r/rank: display a rank for all participants by score. "
  echo -ne "ra/rates: display info about how the scores are calculated. "
  echo "he/help: display help message."
}

rates()
{
  echo "rates: new card= 2 points review card= 1 point." 
}

getjday()
{
  for ((i=0;i<14;i=i+2))
  do
   if [[ "$1" == "${jdays[$i]}" ]]; then
    adate[1]="${jdays[$i+1]}"
   fi
  done
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
    awk -v l=$ll -v u=$ul -F'\t' 'NR==l,NR==u {print $1" "$2" New:"$3" Reviewed: "$5" Score: "$8}' $file
  else
    echo "$user: This page number isn't in your history."
  fi
}

rank()
{
  lnames=$(ls ./data)
  lnames=($(echo $lnames))
  tscore=()
  tlevels=()
  j=0
  for i in "${lnames[@]}"
  do
    tscore[$j]=$(awk -F'\t' 'NR==1 {print $8; exit}' ./data/$i)
    level ${tscore[$j]}
    tlevels[$j]=$level
    j=$[$j+1]
  done

  n=${#lnames[@]}
  fsort=
  for i in $(seq 0 $[$n-1]); do
    fsort="$(echo -ne "${lnames[$i]} ${tscore[$i]} L:${tlevels[$i]}\n""$fsort")"
  done
  
  if [[ -z $fsort ]];then
    echo "No records to rank."
  else
    echo "$fsort" | sort -nrk 2
  fi
}

summary()
{
  echo "$user: You have done $total cards, $trev reviews and $tnew new cards."
}

undo()
{
  sed -i '1d' $file
}

add()
{
  sed -e "1i $id\t$sdate\t$new\t$tnew\t$rev\t$trev\t$total\t$score" -i $file
}

sumup()
{
  tnew=$[$new+$tnew]
  trev=$[$rev+$trev]
  total=$[$new+$rev+$total]
  score=$[$[$new*2]+$rev+$score]
}

level()
{
  level=$(echo "define max(a, b) { if (a>b) return a else return b }

define log(a, b) { return l(a)/l(b) }

define int(number) {

auto oldscale

oldscale = scale

scale = 0

number /= 1 /* round number down */

scale = oldscale

return number

}

define level(score) { return int(max(3*(log(score+1, 2)-7), 0)) }

print level($1)" | bc -l )
}

cmplevel()
{
  isnlvl=0
  oscore=$(awk -F'\t' 'NR==2 {print $8; exit}' $file)
  nlevel=$level
  level $oscore
  if [[ $nlevel -gt $level ]];then
    isnlvl=1
  fi
}

reset()
{
  rm -rf ./data
  echo "all records have been deleted." 
}

resetusr()
{
  rm -f ./data/$1
  echo "All records for $1 have been deleted."
}

rmzusr()
{
  if [[ $score == 0 ]];then
  rm -f $file
  fi
}

rmsg()
{
  num=$RANDOM
  let "num %= 6"
  echo ${msg[$num]}
}

i=0
while :
do
  m="${input[$i]}" 
case "$m" in
  +n | +new)
    Non=1
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: New quantity has to be a positive integer. Use the format +n/+new <number>"
        exit 1
    fi
    anew[$i]=${input[$i+1]}
    i=$[$i+2]
    ;;
  +r | +review)
    Ron=1
    if [[ ! ${input[$i+1]} =~ ^[0-9]+$ ]]; then
        echo "Error: Review quantity has to be a positive integer. Use the format +r/+review <number>"
        exit 1
    fi
    arev[$i]=${input[$i+1]}
    i=$[$i+2]
    ;;
   *)
    break
    ;;
esac

done

if [[ -z $input ]];then
  helpmsg
fi

getjday "${adate[1]}"
sdate="$(echo "${adate[@]}")"

for i in "${anew[@]}"
do
  new=$[$i+$new]
done


for i in "${arev[@]}"
do
  rev=$[$i+$rev]
done

if [[ $Ron == 1 || $Non == 1 ]]; then
  sumup
  add
  level $score
  echo "$user: $new new cards added, $rev cards reviewed. Your score is: $score points. L:$level"
  cmplevel
  if [[ $isnlvl == 1 ]];then
    rmsg
  fi
fi

if [[ ${input[0]} == "undo" ]] || [[ ${input[0]} == "u" ]]; then
  if [[ $[$id-1] == 0 ]]; then
    echo "$user: No more updates to delete."
  else
    undo
    score=$(awk -F'\t' 'NR==1 {print $8; exit}' $file)
    echo "$user: Deleted last update. Your adjusted score is: $score"
  fi
fi

rmzusr

if ([[ "${input[0]}" == "history" ]] || [[ "${input[0]}" == "h" ]]) && [[ "${input[1]}" == "+u" ]] ; then
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

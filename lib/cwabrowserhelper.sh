#!/bin/bash

if [ "$USER" == "root" -o $(id -u) -eq 0 ]; then
  echo "Absolutely, no way are you running me as root!"
  exit 1
fi

cmd=$1
shift

((i=0))

for arg in $@; do
  case $arg in
    "--") ((i++)) ;;
    *) 
      if [ -z "${argv[$i]}" ]; then
        argv[$i]="$arg"
      else
        argv[$i]="${argv[$i]} $arg"
      fi
  esac
  len=$i
done

for ((i=0;i<=len;i++)); do
  echo ${argv[$i]} | egrep -q '^\/(home|work)\/${USER:0:1}\/${USER}\/.+'
  val1=$?
  echo ${argv[$i]} | egrep -q '^\/shares\/.+\/.+'
  val1=$?

  if (((val1 + val2) > 1 )); then
    echo "There's something fishing going on here."
    exit 1
  fi
done

case "$cmd" in
  write)  dd bs=$((1024*128)) of="${argv[0]}" ;;
  read)   dd bs=$((1024*128)) if="${argv[0]}" ;;
  zip)    cd ${argv[0]}; zip -q -r - "${argv[1]}" ;;
  rm)     rm -r "${argv[0]}" ;;
  rename) mv "${argv[0]}" "${argv[1]}" ;;
  stat)   stat -c "%s" "${argv[0]}" ;;
  mkdir)  mkdir "${argv[0]}" ;;
  lines)  wc -l "${argv[0]}" | awk '{ print $1 }' ;;
  type)   file -bi "${argv[0]}" ;;
  list)   find "${argv[0]}" ! -path "${argv[0]}" ! -type l ! -iname '.*' -maxdepth 1 -type ${argv[1]} \
            -printf "%f::%s::%u::%g::%m::%CD %Cr %CZ\n" | sort -f ;;
  *) echo "No way, Jose!"; exit 1 ;;
esac

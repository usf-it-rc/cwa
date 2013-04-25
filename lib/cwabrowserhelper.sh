#!/bin/bash

PATH=/bin:/usr/bin

cmd=$1
shift

case "$cmd" in
  rm|cat|chmod|dd|mv) exec $cmd $@ ;;
  *) echo "No way, Jose"; exit 1 ;;
esac

#!/usr/bin/env bash


if [ $# -ne 3 ]
then
  echo "Usage: $0 <directoy> <find> <replace>"
  exit 1
fi

find $1 -name "*.d" | xargs sed -i "s/$2/$3/gi"
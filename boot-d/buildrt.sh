#!/usr/bin/env bash

files=$(find ../rt/ -name *.dis -printf "%p ")

#echo $files

./bin/disc -sharedlib -o bin/libdisrt.so $files


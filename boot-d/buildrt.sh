#!/usr/bin/env bash

files=$(find ../runtime/rt/ -name *.dis -printf "%p ")

#echo $files

./bin/disc --no-runtime -sharedlib -o bin/libdisrt.so $files $@


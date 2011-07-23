#!/usr/bin/env bash

llc -o "${1}.o" -filetype=obj $1
gcc -g -o "${1}.bin" "${1}.o" 
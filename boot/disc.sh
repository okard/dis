#!/usr/bin/env bash

LD_LIBRARY_PATH=./lib/linux32/:$LD_LIBRARY_PATH

./bin/disc $@
#gdb --args ./bin/disc $@

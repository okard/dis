#!/usr/bin/env bash

#64 or 32 bit linux
osbit=$(getconf LONG_BIT)

# if 64bit os add 32 bit lib path
if [[ "$osbit" == "64" ]]; then
	LD_LIBRARY_PATH=./lib/linux32/:$LD_LIBRARY_PATH
fi


./bin/disc $@
#gdb --args ./bin/disc $@

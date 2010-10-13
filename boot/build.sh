#!/usr/bin/env bash


SOURCE="src/disc.d"
LIBDIR="./lib/linux32"

dmd -I. -L-L$LIBDIR -L-lffi -L-lLLVM-2.8 -L$LIBDIR/libllvm-c-ext.a -L-ldl -L-lstdc++ -od.obj $SOURCE -ofbin/disc


DMD=dmd
DFLAGS=-w -debug -gc -Isrc -unittest
EXE=bin/disc
LIBDIR=./lib/linux32
SOURCE=src/disc.d src/dlf/basic/*.d src/dlf/dis/*.d src/dlf/ast/*.d src/dlf/gen/*.d src/dlf/gen/llvm/*.d

LDFLAGS=-L-L$(LIBDIR) -L-lffi -L-lLLVM-2.8 -L$(LIBDIR)/libllvm-c-ext.a -L-ldl -L-lstdc++
OBJDIR=.obj

all:
	$(DMD) $(DFLAGS) $(LDFLAGS) $(SOURCE) -od$(OBJDIR) -of$(EXE)
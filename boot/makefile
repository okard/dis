

DMD=dmd
DFLAGS=-w -debug -gc -Isrc
EXE=bin/disc
LIBDIR=./lib/linux32
SOURCE=src/disc.d src/disc/basic/*.d src/disc/dis/*.d src/disc/ast/*.d

LDFLAGS=-L-L$(LIBDIR) -L-lffi -L-lLLVM-2.8 -L$(LIBDIR)/libllvm-c-ext.a -L-ldl -L-lstdc++
OBJDIR=.obj

all:
	$(DMD) $(DFLAGS) $(LDFLAGS) $(SOURCE) -od$(OBJDIR) -of$(EXE)
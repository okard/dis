

DMD=dmd
DFLAGS=-w -debug -gc -Isrc -unittest
EXE=bin/disc
LIBDIR=./lib/linux32

SOURCE=src/disc.d src/dlf/basic/*.d src/dlf/*.d src/dlf/dis/*.d src/dlf/ast/*.d src/dlf/sem/*.d src/dlf/gen/*.d src/dlf/gen/c/*.d
RESIMPORT=-Jsrc/dlf/gen/c/

#$(shell find src/dlf/ -type f -name '*.d')


LDFLAGS=-L-L$(LIBDIR) -L-ldl -L-lstdc++
OBJDIR=.obj

all:
	$(DMD) $(DFLAGS) $(LDFLAGS) $(RESIMPORT) $(SOURCE) -od$(OBJDIR) -of$(EXE) 

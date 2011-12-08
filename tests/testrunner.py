#!/usr/bin/env python3

import os, sys, re
import subprocess

# Settings:
TEST_DIR = os.path.dirname(__file__) # test path (is script path)
DISC = "../boot-d/disc.sh" # the compiler executable
OBJDIR = os.path.join(TEST_DIR, ".objdis") # object files for test compilation
BINDIR = os.path.join(TEST_DIR, ".testbin") # test binaries

# Colors from blenders build script
HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
ENDC = '\033[0m'

SPECCOMPRESULT = 'CompileResult'
SPECRUNRESULT = 'RunResult'

# -----------------------------------------------------------------------------
# Main Function
def main(argv=None):
    #prepare
    if not os.path.exists(BINDIR):
        os.makedirs(BINDIR)
    
    #get testfiles
    testfiles = sum([[os.path.join(f[0], g) for g in f[2] if re.search('.*\.dis',g)] for f in os.walk(TEST_DIR)], [])

    #run tests
    for testfile in testfiles:
        print(testfile)
        spec = extractTestSpec(testfile)
        compileTest(spec, testfile)
        runTest(spec, testfile)
    pass

# -----------------------------------------------------------------------------

# spec matcher
specMatcher = re.compile("^//#(?P<key>.+):(?P<value>.+)$", re.I|re.U)

# Extract Test Specs
def extractTestSpec(testfile):
    spec = dict()
    #find specs in file
    file = open(testfile, 'r')
    for line in file:
        entry = specMatcher.search(line)
        if entry :
            spec[entry.group('key').strip()] = entry.group('value').strip()
             
    file.close()  
    return spec

# -----------------------------------------------------------------------------   
# Compile as single test
def compileTest(spec, testfile):
    
    try:
        binname = os.path.basename(testfile);
        binname = binname.replace('.', '_')
        binname += '_bin'
        # create command string
        cmd = [DISC]
        cmd.append(testfile)
        cmd.append("-o")
        cmd.append(os.path.join(BINDIR, binname))
        #print(cmd)
        # disc file -o outfile
        fnull = open(os.devnull, 'w')
        ret = subprocess.call(cmd, stdout = fnull) #stdout = fnull
        fnull.close()
        
        #look for expected CompileResult
        if SPECCOMPRESULT in spec:
            expected = int(spec[SPECCOMPRESULT])
            if expected == ret:
                print(OKGREEN+"Success"+ENDC);
            else:
                if ret == 0:
                    print(FAIL+"Compiled but has not to"+ENDC);
                elif ret == 1:
                    print(FAIL+"Usage Error"+ENDC);
                elif ret == 2:
                    print(FAIL+"Lexer Error"+ENDC);
                elif ret == 3:
                    print(FAIL+"Parser Error"+ENDC);
                elif ret == 4:
                    print(FAIL+"Semantic Error"+ENDC);
                else:
                    print(FAIL+"Unkown Result: {0}".format(ret)+ENDC);
        else:
            print(WARNING+"Missing Spec (Result: {0})".format(ret)+ENDC);
        #return binary at success
        return os.path.join(BINDIR, binname)
    except OSError:
        #return null?
        print("Cant start compiler")
        return None
 
# -----------------------------------------------------------------------------
# Run a single test
def runTest(spec, testExec):
    pass
    
# -----------------------------------------------------------------------------
# run main
if __name__ == "__main__":
    sys.exit(main(sys.argv))
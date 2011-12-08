#!/usr/bin/env python3

import os, sys, re
import subprocess

# Settings:
TEST_DIR = os.path.dirname(__file__) # test path (is script path)
DISC = "../boot-d/disc.sh" # the compiler executable
OBJDIR = ".objdis" # object files for test compilation
BINDIR = ".testbin" # test binaries

# -----------------------------------------------------------------------------
# Main Function
def main(argv=None):
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
    # create command string
    try:
        ret = subprocess.call([DISC])
        #-1 usage
        #-2 lexer
        #-3 parser
        #-4 semantic
    except OSError:
        print("Cant start compiler");
  
    pass
 
# -----------------------------------------------------------------------------
# Run a single test
def runTest(spec, testExec):
    pass
    
# -----------------------------------------------------------------------------
# run main
if __name__ == "__main__":
    sys.exit(main(sys.argv))
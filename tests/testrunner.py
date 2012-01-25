#!/usr/bin/env python3

import os, sys, re
import subprocess

# Settings:
TEST_DIR = os.path.dirname(__file__) # test path (is script path)
DISC = os.path.join(TEST_DIR, "../boot-d/disc.sh") # the compiler executable
LIBDIR = os.path.join(TEST_DIR, "../boot-d/bin/") # libraries e.g. runtime
OBJDIR = os.path.join(TEST_DIR, ".objdis") # object files for test compilation
BINDIR = os.path.join(TEST_DIR, ".testbin") # test binaries

# Colors from blenders build script
HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
ENDC = '\033[0m'

SPECDESC = 'Desc'
SPECCOMPRESULT = 'CompileResult'
SPECRUNRESULT = 'RunResult'

# -----------------------------------------------------------------------------
# Main Function
def main(argv=None):
    #prepare
    if not os.path.exists(BINDIR):
        os.makedirs(BINDIR)
    
    #get testfiles
    testfiles = sorted(sum([[os.path.join(f[0], g) for g in f[2] if re.search('.*\.dis',g)] for f in os.walk(TEST_DIR)], []))

    #run tests
    for testfile in testfiles:
        spec = extractTestSpec(testfile)
        
        sys.stdout.write("(")
        binary = compileTest(spec, testfile)
        sys.stdout.write(")")
        
        sys.stdout.write("(")
        runTest(spec, binary)
        sys.stdout.write(")")
        print(" Desc: {0} ({1})".format(spec.get(SPECDESC, ""), testfile),)
   
    # print results
    

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
                sys.stdout.write(OKGREEN+"Compile Success"+ENDC);
                return os.path.join(BINDIR, binname)
            else:
                if ret == 0:
                    sys.stdout.write(FAIL+"Compiled but has not to"+ENDC);
                elif ret == 1:
                    sys.stdout.write(FAIL+"Usage Error"+ENDC);
                elif ret == 2:
                    sys.stdout.write(FAIL+"Lexer Error"+ENDC);
                elif ret == 3:
                    sys.stdout.write(FAIL+"Parser Error"+ENDC);
                elif ret == 4:
                    sys.stdout.write(FAIL+"Semantic Error"+ENDC);
                else:
                    sys.stdout.write(FAIL+"Unkown Result: {0}".format(ret)+ENDC);
        else:
            sys.stdout.write(WARNING+"Missing Spec (Result: {0})".format(ret)+ENDC);
        #return binary at success
        return None
    except OSError:
        #return null?
        sys.stdout.write("Cant start compiler")
        return None
 
# -----------------------------------------------------------------------------
# Run a single test
def runTest(spec, testExec):
    
    if testExec == None:
        sys.stdout.write(FAIL+"No Binary"+ENDC);
        return
        
    runenv = os.environ
    runenv["LD_LIBRARY_PATH"] = LIBDIR + ":" + runenv["LD_LIBRARY_PATH"]
     
    cmd = [testExec]
    fnull = open(os.devnull, 'w')
    ret = subprocess.call(cmd, stdout = fnull, env=runenv) #stdout = fnull
    fnull.close()
    
    expected = int(spec[SPECRUNRESULT])
    
    if ret == expected:
        sys.stdout.write(OKGREEN+"Exc Success: {0}".format(ret)+ENDC);
    else:
        sys.stdout.write(OKGREEN+"Exc Failed: {0}".format(ret)+ENDC);
    
    #run file
    
    
# -----------------------------------------------------------------------------
# run main
if __name__ == "__main__":
    sys.exit(main(sys.argv))
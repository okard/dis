#!/usr/bin/env python3

import os, sys, re
import subprocess

# Settings:
TEST_DIR = os.path.dirname(__file__) # test path (is script path)
DISC = os.path.join(TEST_DIR, "../boot-cpp/bin/disc") # the compiler executable
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
        
        normalFile = os.path.abspath(testfile)
        normalFile = normalFile[len(os.path.abspath(TEST_DIR))+1:]
        
        print(" {1} '{0}'".format(spec.get(SPECDESC, ""), normalFile),)
   
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
            
            color = FAIL
            expected = int(spec[SPECCOMPRESULT])
            
            #detect status
            if expected == ret:
                color = OKGREEN
                
            if ret == 0:
                write(color, "Compiled");
            elif ret == 1:
                write(color, "Usage Error");
            elif ret == 2:
                write(color, "Lexer Error");
            elif ret == 3:
                write(color, "Parser Error");
            elif ret == 4:
                write(color, "Semantic Error");
            else:
                write(color, "Unkown Result: {0}".format(ret));
           
            if ret == 0:
				#TODO check if file exists
                return os.path.join(BINDIR, binname)
            else:
                return None
           
        else:
            write(WARNING, "Missing Spec (Result: {0})".format(ret));
        #return binary at success
        return None
    except OSError:
        #return null?
        sys.stdout.write("Can't start compiler")
        return None
 
# -----------------------------------------------------------------------------
# Run a single test
def runTest(spec, testExec):
    
    # check if binary is available
    if testExec == None or not os.path.isfile(testExec):
        color = FAIL
        if int(spec.get(SPECCOMPRESULT, "0")) != 0:
            color = OKGREEN
        write(color, "No Binary");
        return
        
        
    #LD Path
    runenv = os.environ
    if "LD_LIBRARY_PATH" not in  runenv:
        runenv["LD_LIBRARY_PATH"] = ""
        
    runenv["LD_LIBRARY_PATH"] = LIBDIR + ":" + runenv["LD_LIBRARY_PATH"]
     
    # Run File
    cmd = [testExec]
    fnull = open(os.devnull, 'w')
    ret = subprocess.call(cmd, stdout = fnull, env=runenv)
    fnull.close()
    
    expected = int(spec.get(SPECRUNRESULT, "0"))
    
    color = FAIL
    if expected == ret:
        color = OKGREEN
        
    # print result
    if ret == 0:
        write(color, "Execution Success: {0}".format(ret))
    else:
        write(color, "Execution Failed: {0}".format(ret));
    
# -----------------------------------------------------------------------------
# Helper Function for colored output 
def write(color, msg):
    sys.stdout.write(color);
    sys.stdout.write(msg);
    sys.stdout.write(ENDC);
    
# -----------------------------------------------------------------------------
# run main
if __name__ == "__main__":
    sys.exit(main(sys.argv))

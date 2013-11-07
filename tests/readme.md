# Dis Language Tests


* error: compile errors
* fails: run fails
* runnable: runnable tests
* examples: some examples to show language features

-------------------------------------------------------------

* lexer tests
	

* parser tests
	* error-parser //parsing fails
	* error-sem //parsing ok but semantic fails
	* valid //complete valid
	
* semantic tests
	* error
	* valid
	
* runtime tests
	* compile time error
	* run time error
	* valid
	
* bugs - tests which have a id

* full - complex tests
	* valid
	* error-lex
	* error-parser
	* error-sem
	* error-run
	
Valid tests should be able to compile to a binary
	
# Test runner

The current testrunner script is a python3 script that runs the compile on each test
and analyze the results

# Test specs

* Starts with //#
* Format //#<key>:<value>

* Available keys:
	- Desc<string> - description of test
	- CompileResult<num> - return value of compiler
	- RunResult<num> - return value of the executable
	- Type<string> - category?

* Example
	//# Desc: simple empty main
	//# CompileResult: 0
	//# RunResult: 0
	//# Type: Runnable

* TODO
	command line args for compile / run
		//# compile-args: $disc -od -o $out $sources
		//# run-args: $exc 1 2
	enviroment for compile/run
		//# compile-env: foo=bar
		//# run-env: foo=bar
	
	additional files for compile 
	
	stdout //multiple times?
		//# stdout: Error: (0,0) Invalid Literal
		//# stdout: Error: Can't compile
	stderr


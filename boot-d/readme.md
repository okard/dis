
# Dis Programming Language

Bootstrap Compiler written in D2

## Structure

* src/ Source Code of Compiler
    - dlf - dis language framework
    - dlf.basic - commmon classes and functions
    - dlf.ast - the syntax tree definition
    - dlf.dis - lexer and parser for the dis programming language
    - dlf.sem - semantic analysis
    - dlf.gen - code generation, c99 and llvm
    - disc - dis compiler code
    - llvm.* - llvm d bindings
* lib/ 

## Build Instructions

With valid D2 & Tools (gnu make) in PATH type in console:

$ make


## Usage

To use the dis boot compiler it is required you have gcc and tools available through PATH.

To build the runtime type

$ ./buildrt.sh under Linux (bash)

To build a program you can use the wrapper script or start the compiler directly:

$ ./disc.sh -o basic001 ../tests/runnable/basic001.dis
$ ./bin/disc -o basic001 ../tests/runnable/basic001.dis 

At the moment the search path handling for disrt library (dis runtime) is only partial implemented



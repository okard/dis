
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
* lib

## Build Instructions

With valid D2 & Tools in PATH type in console:

$ make


# Todo List

## Language Design

* Remove package/import system and replace it with a mod/use system
	* each source file can be module?
	* use foo = mod ast; //import module into module foo
	* use mod ast; 		 //import module ast directly in container mod
	* mod a = "abc"		 //external module
* Syntax for Attribute ( ´´´#[foo="abc"], #[foo("abc")]´´´ )
	- Clearify Language-Attributes and User-Defined-Attributes
* Alias Support
* Mixins (Special Inlined Functions)
* Keyword "_" for placeholdings (explicit unused) etc?
* Documentation
* Inline Asm 
* Trait Implementation/ Extension Methods best way?
* User String literals?
* Managed Arrays? stack/heap allocation/growable
* Clean up syntax

## boot-cpp

* Remove complete object stuff (really?)
* Implement trait handling
* Implement lookup stuff in parser not in lexer PARTIAL
* Improve error handling, eof and try parse stuff
	- See dis/include/ParserError.hpp
* Signal/Slot Parser Events/Control Layer
	- Improve Line/Column/OffsetStart/OffsetEnd Handling in Parser <-> Lexer
* Implement DocComments
	- Lexing
	- Parsing
* Implement JSON/XML Output for Documentation Generation
* get to state to test CTE stuff in interpreter
* add a quick type resolving in parser for builtin types

## tests
* update old tests
* create lexer tests
* extend test runner script

## Other

* clean up doc/articles/ 
	- naming scheme for files?
	- split types / memory mangement
* think about directory structure (with src/ component folders etc)

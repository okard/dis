# Todo List

## Language Design

* Remove package/import system and replace it with a mod/use system
	- WIP
	- doc/articles/module_system.md
* Syntax for Attribute ( ´´´#[foo="abc"], #[foo("abc")]´´´ )
	- Clearify Language-Attributes and User-Defined-Attributes
* Alias Support
* Mixins (Special Inlined Functions)
	- a CT Call via $$<expr>() 
* Keyword "_" for placeholdings (explicit unused) etc?
* Documentation
	- Doc Comment Parser / Save Doc Comments
* Inline Asm 
	- Pure string handled by Codegen Backend?
* Trait Implementation/ Extension Methods best way?
	- function and trait syntax -> def trait::func(self: type) ???
* User String literals?
	- C++11 "foobar"b ???
* Managed Arrays? stack/heap allocation/growable
	- General Memory Handling 
	- $RT.MemHandler = adasd //compile time configuration?
		- Startup initialization at runtime???
		- Data Segments in Binary?
* Clean up syntax
	- Clean consistent looking
	- Also Parser Cleanup and optimize
* Make clear when where ';' var decl in loops ...
	- Parser looking garbage 
* function definition without name? -> func decl vs lambda expr
	- Parser looking strange 
* remove () from If(){} YES DONE
* statement labels?? -> for break/continue/(break?)/etc "abc_loop": for() { break "abc_loop"; }
* Variadic Templates
* Match Pattern Syntax
* reintroduce ref keyword?
* Fix semicolon stuff

## boot-cpp

* Remove complete object stuff (really?)
	- Keep for future?
* Implement trait handling
* Implement lookup stuff in parser not in lexer 
	- Remove from Lexer DONE
	- Implement in Parser (Required??)
* Improve error handling, eof and try parse stuff
	- See dis/include/ParserError.hpp
	- Not sure what is the best way?
* Signal/Slot Parser Events/Control Layer
	- Improve Line/Column/OffsetStart/OffsetEnd Handling in Parser <-> Lexer
* Implement DocComments
	- Lexing
	- Parsing
* Implement JSON/XML Output for Documentation Generation
* Implement DOT Output for analysis purposes (Verify Parse Tree)
* get to state to test CTE stuff in interpreter
	- WIP
* Full Interpreter?
	- Make possible to Function calls via FFI???
	- Use LLVM JIT?
* Pure UTF8 Source Code Files 
	- Fix Lexer
* Move datatype parsing to kind of precedence parsing

## tests
* update old tests
* create lexer tests
* extend test runner script

## Other

* clean up doc/articles/ 
	- naming scheme for files?
	- split types / memory mangement
* think about directory structure (with src/ component folders etc)

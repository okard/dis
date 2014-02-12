# Todo List

## Language Design

* Remove package/import system and replace it with a mod/use system
	* each source file can be module?
	* use foo = mod ast; //import module into module foo
	* use mod ast; 		 //import module ast directly in container mod
	* mod a = "abc"		 //external module
* Remove complete object stuff
* Implement trait handling
* Implement lookup stuff in parser not in lexer
* Improve error handling, eof and try parse stuff
	- See dis/include/ParserError.hpp
* Signal/Slot Parser Events/Control Layer
* Implement DocComments
* Implement JSON/XML Output for Documentation Generation
* Keyword "_" for placeholding etc?
* Delete boot-d
* Syntax for Attribute ( ´´´#[foo="abc"], #[foo("abc")]´´´ )


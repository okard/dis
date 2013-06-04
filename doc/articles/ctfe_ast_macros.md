# DRAFT CTFE and AST Macros

These document describes brainstorming about Compile-Time-Function-Execution (CTFE) and Macros running
on the AST. These parts of the dis programming language are a requirement to support the meta programming
paradigma.

All stuff related to compile time access using the symbol **$**


## Access to general compile time informations

    $ - Compile Time Object

Scope Properties:

    $.File - Current File Name (Full path)
    $.Line - Current Line
    $.Col - Current Column
    $.Decl - Current Declaration (String)


## Access compile time informations for source code elements

    $(expr) - Compile Time Access Call Expression

Information about types:

    $(type).sizeof - size of the type
    $(type).fqn - full qualified name of the type

Information about variables

    $(variable).offset - offset in stack scope (ptr)
    $(variable).type - type info see above


Notice Type Infos can also be accessed at runtime. Which type informations getting compiled into the binary
can be configured. To access type information at runtime is still a todo;

## Working with AST Nodes

    $.AstNode - access to ast node at compiler level

    //Manipulate AST Nodes
    //Run at semantic interpreter
    $.AstNode
        .replace(astnode)
                (string (bytearray intepreted as text))
        .dump(File)
        .append
        
    //function using AstNodes?
	def function( a : $.AstNode) : $.AstNode
	
	$.ast.Decl
	
	$(expr).astNode;

## CTFE statements?

	$if($flag[ARCH_x32)])
	{}
	$flag(ARCH_x32)
	{}
 
## Explicit Functions execution

Additional to *$.* and *$()* the expression *$identifier()* can be used to enforce ctfe, 
also the compiler can decide to run functions at compile time when they are not explicitly called as CTFE. 
To be shure that a function can and will be run at compile time these expression can be used.

    $$type() - Execution Call Expression

Example

    $$fak(5) - Calling fak(5) at compile time

## Special Functions

Include the file as binary data

	var data = $.include_bin(path);
			   $include_bin(path);


## Internal Structure

The compiler needs an embedded interpreter to run on the ast structure, also in the part of implementation of
the interpreter there can maybe created a VM instruction set (bytecode) and a VM implementation to handle the execution.
The VM implementation can be used to mixing binary and script code of the same language (also JITed?).



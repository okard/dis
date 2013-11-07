# Dis Language Overview Version 0.1


## Functions

	<func> = "def" ['scope'::]'funcname'( 'paramname' [ : <type>]) [<body_func>]
	<body_func> = "=" <statement> | 

	def add( a: int32, b: int32) = a + b;

	def print( msg: []byte) 
	{
		printf(msg);
	}

## Variables, Values & Constants

	const 'name' : <type> [ "=" <initializer> ]
	let 'name' : <type> [ "=" <initializer> ]
	var 'name' : <type> [ "=" <initializer> ]


## Struct/Unions/Aliases/Delegate/Variants/Enum/Arrays


## Classes
	
	"obj" 'name' [ "(" <obj_tpl> ")" ] <body_class>

## Trait
	"trait"

## Attributes

	"#" "[" <attr> "]"







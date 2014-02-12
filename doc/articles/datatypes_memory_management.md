# Thoughts about data types and memory management

## Introduction to data types

The most programming languages have two different data types. The primitive data types are the basic of all possible types. The primitive types in native languages can often be handled directly by the cpu. Other data types are compositions of the primitive types.

### Builtin primitive data types

For dis as a native language has a common set of primitive data types showed by the following list

* Boolean: 
	- bool
	
* Numbers: (flaged with signed/unsigned and bit length)
	- Signed Numbers: 	i8,i16,i32,i64, 
	- Unsigned Numbers:	u8,u16,u32,u64

* Floating Point Numbers:
	- f32 (IEEE 754)
	- f64 (IEEE 754)
	
* Pointers
	- Unsafe: *
	- Safe: ~ &
	
### Complex Builtin Types:

* delegates
  delegates are a special type of a function pointer and can contain the object context when points to a class function or a function which requires a memory context like lambdas

* closures
  similiar to delegates containts an enviroment pointer to work in
	
### Runtime Types

Types which are available in language and requires runtime functions:

* arrays (directly and runtime)
  arrays stores a multiple count of a data type. In dis there are a primary array with no checks and a safer advanced array type defined in the runtime.
  
  []type
  [const expr]type
  
* Maps
  
  [type]type
	
* Sets
  [type]
	

### User types 

The other kind of data types are user defined types, the available user defined types are also often a part of the programming paradigm the language support, e.g. Classes/Objects for the object orientied programming

* structs 
  structs are a composition of other types

* classes  
  basic type for object orientied programming

* enums
  enumerations, a kind of a constant list

* variants
  A type which can be store different other types

These are common user defined types, if it's meaning is not clear for you use google and wikipedia.


### Compile time types and other stuff

Some user defined types exist only during compile time.

* alias
	semantic evaluation
	
* traits
	semantic check 

A special case is a closure, which is special case of a lambda function, basically it is a function pointer like a delegate it has a seperate memory block to duplicate local content of the context the function got created. This memory block is transfered to the anymous function which generates from the lambda expression.

## Instancing and memory management

Datatypes alone are not that useful, to make them useful it is required to create instances of these data types. The critical part is where is the storage of the instances, common computer systems have a ram for that, and the os splits it in a stack and a heap part.

### Value Types vs Reference Types

* Primitive types usually handled as value types and get automatically copied.
* Classes get handled as reference implicitly.
* Structs get automatically copied.

### Memory Locations
    
* Stack
* Heap
* TLS?

### Garbage Collections

Dis should have a garbage collector, but has the freedom to choose how heap objects will get managed.

### Garbage Collection and Primary Types

* Primitive types normally stored on the Stack and get copied
* Primitive in the heap get boxed for the garbage collector

## Handling in Dis

Classes:

    struct myobj{};

    var x : myobj = myobj();        //stack allocated
    var y : ref myobj = myobj();    //heap allocated
    
    var x : myobj;  //stack allocated (Copy Constructor Calls)
    var x : &myobj; //reference type GC allocated
    var x : *myobj; //raw ptr unsafe

    //Implicit typing
    def bar(x) = x;
    bar(x); // becomes bar(x: ref myobj)
    bar(y); // is allowed

    //Explicit typing
    def foo(x : myobj) = x;
    foo(x) // requires implemented copy operator without -> Error
    foo(y) // also requires copy copy operator



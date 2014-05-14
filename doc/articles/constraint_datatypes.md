

# contraint data types


	def foo(a : | is_number(a) |)
	
	
run contraint expression |<expr>| at compile time
result is a boolean true or false
when true matched when false not
	
	$$is_number($(a).type)
	
can define compile time function and specialcation to proof
	
	
	def abc(a : | is_foo(a)|)
	
	struct foo { }
	
	def $foo(a) = false
	def $foo(a:foo) = true
	
	var i : i8 = 0;
	var f : foo;
	
	abc(i); //error
	abc(f); //ok
	
	here easier def abc(a : foo); 
	
	
Runtime values?
	array size x and so on?
	
	
## TODO
	* Is is useful???
	
	

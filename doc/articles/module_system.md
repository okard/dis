# Dis Module System - DRAFT V0.1


# Example Project Structure

## Parts

	* external libs (static/dynamic)
	* internal libs (static/dynamic)
	* main app
	
## Directory Core Structure

	src/libcore/
	src/libutils/
	src/libapp/
	src/app/
	
## Ends in following modules

	name		type			path 	
	----------------------------------------	
	libcore 	static lib  	libcore::
	libutils 	static lib		libutils::
	libapp		dyn lib			libapp::
	app			executable		app::
	

## File Contents


* FileName
	_.dis

	Automatically imports
		folder(_.dis).files(*.dis) ?

* File Content

	mod abc;		//import from folder abc (requires _.dis)
					//import file abc.dis as abc:: ...
	mod foo;		//import from folter foo (requires _.dis)
	
	use abc;		//search symbols also in abc::
	use foo;		//search symbols also in foo::
	
	use abc::{Call} //import abc::Call as Call
	
	use foo = a::b::c; // alias for namespace/module or type
	
	//syntax to directly import files?
		//cte macro?
	    use("file.dis");
	    
	//link external crates?

# Modules and Imports

special named files: _.dis
	
	* all contents starts with path parent_folder(_.dis)
	  for example abc/_.dis all starts with abc::

mod abc {}







# Dis Programming Language

* Native
* Flexible
* Modern
* Consistent
* Multi-paradigm
* Completly OSS
* Influences: C++, D, Rust

## Start with respository

	$ git submodule update --init --recursive
	
	# set push url
	$ git remote set-url --push origin <url>
	
	# push all
	$ git push --recurse-submodules=on-demand 
	
## Repository Structure
    
* boot-cpp/
	
	Bootstrap Compiler written in C++ 
    
* doc/
    
    Documentation
  
* mod/libstd	standard library
* mod/runtime 	selfhosted runtime
* mod/disc		selfhosted compiler
* mod/libdis 	selfhosted libdis
* mod/libplf 	selfhosted libplf
    
* tests/
    
    Language tests

## Examples

Examples for the dis programming languages can found [here](https://github.com/okard/dis/tree/master/tests/runnable "Examples")

The language design is still in progress so theres no warranty that theses files are up to date.

## Contact

    Jabber: okard on jabber.ccc.de
    

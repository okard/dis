/******************************************************************************
*    Dis Programming Language 
*    disc - Bootstrap Dis Compiler
*
*    disc is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    disc is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with disc.  If not, see <http://www.gnu.org/licenses/>.
*
******************************************************************************/
module dlf.gen.c.CCodeWriter;

import std.stdio;
import std.file;
import std.path;

/**
* ANSI C Code Writer
*/
struct CCodeWriter
{
    //TODO CPackage[] list; // list of generated cpackages???
    //TODO Parameter?

    /**
    * A Package
    */
    public class CPackage
    {
        /// Header File
        public File Header;
        
        /// Source File
        public File Source;

        /**
        * Private Ctor
        */
        private this()
        {
        }

        /**
        * Start a package
        */
        public void start(string guard)
        {
            //write include guards
            Header.writefln("#ifndef %s", guard);
            Header.writefln("#define %s", guard);
        }

        /**
        * Close Package
        */
        public void close()
        {
            //end include guards
            Header.writeln("#endif");
        }

        /**
        *  Write Include to Header File
        */
        public void include(string filename)
        {
            //check state for writing include
            Header.writefln("#include \"%s\"", filename);
        }

        //state 
        //create variable

        //Create function declaration
        //Create struct declaration 

        //openBlock
        //closeBlock

        //openStruct
        //addField()
        //closeStruct

        //buffer for other declaration if at the moment is one opened
        //so it can be appended when possible
        //add temp headers?
    }


    //internal classes for functions and structs
  

    CPackage Package(string dir, string name)
    {
        auto pack = new CPackage();
        assert(dir.isDir());
        //TODO use std.path
        //pack.Header = File(dir+name.h, "w");
        //pack.Source = File(dir+name.c, "w");
        return pack;
    }

}
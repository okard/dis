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

/**
* ANSI C Code Writer
*/
class CCodeWriter
{

    /**
    * A Package
    */
    public class CPackage
    {
        /// Header File
        public File Header;
        
        /// Source File
        public File Source;
   

        //start
        //close

        //state 
        //create variable

        //openBlock
        //closeBlock

        //openStruct
        //addField()
        //closeStruct
    }


    // auto f = File("test.txt", "w");

    CPackage createPackage(string dir, string name)
    {
        //dir/name.h
        //dir/name.c
        return new CPackage();
    }

}
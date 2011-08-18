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
module dlf.gen.c.CCodeGen;

import dlf.ast.Visitor;
import dlf.ast.Declaration;
import dlf.gen.CodeGen;

/**
* C Code Generator
*/
class CCodeGen : CodeGen//, Visitor
{
    ///Compile Context
    private Context ctx;

    ///Compiler Flags
    private string[] compilerFlags = [ "-std=c99", "-c", "-Wall", "-g" ];

    //Linker Flags

    /**
    * Ctor
    */
    this(Context ctx)
    {
        this.ctx = ctx;
    }

    /**
    * Compile Package
    */
    void compile(PackageDeclaration pd)
    {
        //compile imports?
        //create a CModule
        //include default header dish.h

        //resulting c files

        //if executable, create c main 
        //embed runtime etc

        //def(C) declarations???? create definitions
    }

    //package -> c package (header, src)

    // Steps:
    //1. package -> *.c, *.h -> List of c files (Path: .objdis/src/*.c,*.h)
    //2. *.c -> *.obj -> List of Objects (Compiler Options)
    //3. *.obj -> binary (Linker Options)

    //debug infos with #line

}
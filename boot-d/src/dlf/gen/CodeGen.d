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
module dlf.gen.CodeGen;

import dlf.Context;

//a compiling interface creates object files
//a linker interface link them together to final program

/**
* CodeGen Interface
* Object Generation
*/
interface ObjectGen
{
    import dlf.ast.Declaration;
    
    string compile(PackageDecl pd);

    //package to object file
    //string compile(Context ctx, PackageDecl pd);
}

/**
* Binary Generation
* aka Link object files together
*/
interface BinaryGen
{
    import dlf.Context;

    void link(Context ctx, string[] objfiles);
}


//Generic Code Gen Exception?

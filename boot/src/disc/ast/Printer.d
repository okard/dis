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
module disc.ast.Printer;

import disc.ast.Node;
import disc.ast.Type;
import disc.ast.Declaration;
import disc.ast.Statement;
import disc.ast.Expression;

import std.stdio;

/**
* AST Printer
*/
class Printer
{

    /**
    * Print FunctionDeclaration
    */
    public void print(FunctionDeclaration fd)
    {
        writef("Function(%s): %s(", toString(fd.mType.mCallingConv), fd.mName);

        foreach(string key, ubyte index; fd.mArgumentNames)
        {
            auto t = fd.mType.mArguments[index];
            writef("%s %s, ", key, t.toString()); 
        }
        
        if(fd.mType.mVarArgs)
            write("...");

        writefln(") %s", fd.mType.mReturnType.toString());
        //fd.mType.mReturnType
    }

    /**
    * Print Package Declaration
    */
    public void print(PackageDeclaration pd)
    {
        writefln("Package: %s",  pd.mName);
    }

    /**
    * Calling Convention to String
    */
    private static string toString(FunctionType.CallingConvention cc)
    {
        switch(cc)
        {
        case FunctionType.CallingConvention.C: return "C";
        case FunctionType.CallingConvention.Dis: return "Dis";
        default: return "";
        }
    }
} 

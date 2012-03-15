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
module dlf.ast.Special;

import std.array;

import dlf.ast.Node;

/**
* Identifier 
*/
struct CompositeIdentifier
{ 
    string[] idents;

    //typed parts?, 
    //packages, datatypes, declarations
    //Composite Parts can reference to ast nodes
    //Node[uint] refs

    /**
    * Return first component
    * e.g. for this.xxx.yyy
    */
    string first()
    {
        return idents[0];
    }

    /**
    * Return last 
    */
    string last()
    {
        return idents[idents.length-1];
    }

    /**
    * Index Access for Types
    */
    public string opIndex(int i)
    {
        return idents[i];
    }

      /**
    * Index Access for Types
    */
    public string opIndex(long l)
    {
        return idents[l];
    }

    /**
    * To string with default seperator
    */
    string toString()
    {
        return join(idents, ".");
    }

    /**
    * to string with given seperator
    */
    string toString(string sep)
    {
        return join(idents, sep);
    }

    /**
    * Append a part
    */
    void append(string part)
    {
        idents ~= part;
    }

    /**
    * Count of elements
    */
    @property
    auto length()
    {
        return idents.length;
    }
}


/*
mixin?
interface SymbolTableOwner
{
    //getter for symbol table
    SymbolTable SymTable();
}
*/



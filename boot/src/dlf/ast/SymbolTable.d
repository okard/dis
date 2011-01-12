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
module dlf.ast.SymbolTable;

import dlf.ast.Declaration;


/**
* SymbolTable
*/
class SymbolTable
{
    /// Prev Symbol Table
    private SymbolTable mPrev;
    
    //save the symbols mangled in AST?
    //in other ways the name can be duplicated avaiable

    /// the symbols
    private Declaration mSymbols[string];
    
    /**
    * Create new SymbolTable
    */
    public this(SymbolTable parent)
    {
        this.mPrev = parent;
    }

    /**
    * Index Access for Types
    */
    public Declaration opIndex(string identifier)
    {
        return mSymbols[identifier];
    }

    /**
    * Creates a new SymbolTable
    */
    public SymbolTable push()
    {
        auto st = new SymbolTable(this);
        return st;
    }

    /**
    * Popes Table and get parent
    */
    public SymbolTable pop()
    {
        return mPrev;
    }

    /**
    * Is Head
    */
    public bool isHead()
    {
        return !(mPrev is null);
    }

} 

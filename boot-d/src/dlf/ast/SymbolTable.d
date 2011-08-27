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
final class SymbolTable
{
    /// Prev Symbol Table
    private SymbolTable mPrev;
    
    //safe owner of symboltable
    //private Node owner

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
    * Op Index Assign
    */
    public Declaration opIndexAssign(Declaration dec, string name)
    {
        mSymbols[name] = dec;
        return dec;
    }

    /**
    * Apply Operator
    * Allow foreach iteration over symboltable
    */
    int opApply(int delegate(ref Declaration) dg)
    {   
        int result = 0;
    
        foreach(string key, Declaration value; mSymbols)
        {
            result = dg(value);

            if (result)
                break;
        }
        return result;
    }

    /**
    * Symbol Table contains entry
    */
    public bool contains(string value)
    {
        return cast(bool)(value in mSymbols);
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
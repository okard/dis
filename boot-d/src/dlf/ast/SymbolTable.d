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

import dlf.ast.Node;
import dlf.ast.Declaration;


/**
* SymbolTable
*/
final class SymbolTable
{
    //Prev Table
    public SymbolTable Prev;
    //Next Table
    public SymbolTable Next;

    /// Owner Node of SymbolTable
    public Node Owner;

    //TODO Use Interface for SymbolTable owner
    
    /// the symbols
    private Declaration mSymbols[string];
    
    /**
    * Create new SymbolTable
    */
    public this(Node Owner, SymbolTable prev)
    {
        this.Owner = Owner;
        this.Prev = prev;
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
    * Assign Entry
    */
    public void assign(T : Declaration)(T symbol, void delegate(T symA, T symB) concat)
    {
        //append to function table
        if(!this.contains(symbol.Name))
            this[symbol.Name] = symbol;
        else
        {
            //types must match
            if(this[symbol.Name].Kind != symbol.Kind)
                throw new Exception("Wrong kind of symbol already in symbol table");
   
            concat(this[symbol.Name].to!T, symbol);
        }
    }


    private struct Entry
    {
        //type: variable, function, class, struct 
        //binding: extern 
    }

} 

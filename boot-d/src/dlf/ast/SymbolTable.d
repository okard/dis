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
* TypeDecl
*/
final struct SymbolTable
{
    /// Owner Node of SymbolTable
    public Node Owner;

    //TODO Use Interface for SymbolTable owner
    
    /// the symbols
    private Declaration symbols[string];
    
    /**
    * Create new SymbolTable
    */
    public this(Node Owner)
    {
        this.Owner = Owner;
    }

    /**
    * Index Access for Types
    */
    public Declaration opIndex(string identifier)
    {
        return symbols[identifier];
    }

    /**
    * Op Index Assign
    */
    public Declaration opIndexAssign(Declaration dec, string name)
    {
        if(contains(name))
            throw new Exception("Already in SymbolTable, use assign method for duplicated entries");

        symbols[name] = dec;
        return dec;
    }

    /**
    * Apply Operator
    * Allow foreach iteration over symboltable
    */
    int opApply(int delegate(ref Declaration) dg)
    {   
        int result = 0;
    
        foreach(string key, Declaration value; symbols)
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
        return cast(bool)(value in symbols);
    }

    /**
    * Count of elements in symbol table
    */
    @property
    public auto count()
    {
        return symbols.length;
    }

    /**
    * Assign Entry
    * with delegate handler
    */
    public void assign(T : Declaration)(T symbol, void delegate(T symA, T symB) concat)
    {
        //append to function table
        if(!this.contains(symbol.Name))
            symbols[symbol.Name] = symbol;
        else
        {
            //types must match
            if(this[symbol.Name].Kind != symbol.Kind)
                throw new Exception("Wrong kind of symbol already in symbol table");
   
            concat(symbols[symbol.Name].to!T, symbol);
        }
    }

    /**
    * Direct assign which can replace old symbol
    * TODO: Rename to replaceSymbol(), remove seperate replace function?
    */
    public void assign(T : Declaration)(T symbol, bool replace = true)
    {
        if(!replace && this.contains(symbol.Name))
            throw new Exception("Symbol already in SymbolTable");

        symbols[symbol.Name] = symbol;
    }

    /**
    * Direct access to symbol flags
    */
    public DeclarationFlags flags(string symName)
    {
        if(!contains(symName))
            return DeclarationFlags.Blank;

        return symbols[symName].Flags;
    }

    //TODO what attributes save in ast node what save in symbol table

    //TODO handling sub symbol tables SymbolTable[Node]?

    /*
    link: http://www.cs.pitt.edu/~mock/cs2210/lectures/lecture9.pdf

    Symbol Table:  Maps symbol names to attributes
    Common attributes:
    Name: String
    Class:Enumeration (storage class)
    Volatile:Boolean
    Size:Integer
    Bitsize:Integer
    Boundary: Integer
    Bitbdry:Integer
    Type:Enumeration or Type referent
    Basetype:Enumeration or Type referent
    Machtype:Enumeration
    Nelts:Integer
    Register:Boolean
    Reg:String (register name)
    Basereg:String
    Disp:Integer (offset)
    */

    enum SymbolType
    {
        Unknown,
        Function,
        Variable,
        Import,
        Struct,
        Class
    }

    //Possible Attributs of a Symbol Entry?
    private struct Entry
    {
        //type: variable, function, class, struct 
        //binding: extern 

    }

}

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
module disc.ast.SymbolTable;

import disc.ast.Type;


/**
* SymbolTable
*/
class SymbolTable
{
    /// Prev Symbol Table
    private SymbolTable mPrev;
    
    /// the symbols
    private DataType mSymbols[string];
    
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
    public DataType opIndex(string identifier)
    {
        return mSymbols[identifier];
    }

} 

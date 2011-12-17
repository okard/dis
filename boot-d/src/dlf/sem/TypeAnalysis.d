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
module dlf.sem.TypeAnalysis;

/*
class TypeAnalysis : Visitor
{
}
*/

/**
* Semantic Functions for Types
*/
mixin template TypeAnalysis()
{

    //resolve types

    /**
    * Get the Declaration of a IdentifierExpression
    * e.g. "this.foo.bar.x" is a VariableDeclaration(int)
    */
    private Declaration resolve(IdentifierExpression di)
    {
        assert(mSymTable is null, "Resolve IdentifierExpression: SymbolTable is null");

        //Instances and arguments

        //TODO Detect this at front

        auto elements = di.length;
        if(elements == 1)
        {
            //search up
            auto sym = mSymTable;

            do
            {
                if(sym.contains(di.first))
                    return sym[di.first];
            
                sym = sym.pop();
            }
            while(sym !is null);
        }
        else
        {
            //go up 
            //search down
        }
        

        return null;
    }

    /**
    * Is opaque type
    */
    private static bool IsOpaque(DataType t)
    {
        return t == OpaqueType.Instance;
    }
}
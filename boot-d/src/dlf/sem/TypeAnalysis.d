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

/**
* Semantic Functions for Types
*/
mixin template TypeAnalysis()
{

    //resolve types

    /**
    * Get the Declaration of a DotIdentifier
    * e.g. "this.foo.bar.x" is a VariableDeclaration(int)
    */
    private Declaration resolve(DotIdentifier di)
    {
        //Symbol Table should not be null
        if(mSymTable is null)
        {
            Error("\t Resolve DotIdentifier: SymbolTable is null");
            return null;
        }

        //Instances and arguments

        //TODO Detect this at front

        auto elements = di.length;
        if(elements == 1)
        {
            //search up
            auto sym = mSymTable;

            do
            {
                if(sym.contains(cast(string)di[0]))
                    return sym[cast(string)di[0]];
            
                sym = sym.pop();
            }
            while(sym !is null)
        }
        else
        {
            //go up 
            //search down
        }
        

        return null;
    }

}
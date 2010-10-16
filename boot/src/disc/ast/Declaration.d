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
module disc.ast.Declaration;

import disc.ast.Node;
import disc.ast.Type;

/**
* Basic Class for Declaration
*/
abstract class Declaration : Node
{
    ///name
    string name;
    
    /**
    * Ctor
    */
    public this(string name)
    {
        this.name = name;
    }
}

/**
* Package
*/
class PackageDeclaration : Declaration
{
    /**
    * Ctor
    */
    public this(string name)
    {
        super(name);
    }
    
    //childs

}

/**
* Function Declaration (def)
*/
class FunctionDeclaration : Declaration
{
    //flags: public, private, protected, package, static


    //FunctionType (parameter, return type)
    //parameter naming?
    //body -> Block
    
    /**
    * Ctor
    */
    public this(string name)
    {
        super(name);
    }
}

/**
* Variable Declaration (var)
*/
class VariableDeclaration : Declaration
{
    /**
    * Ctor
    */
    public this(string name)
    {
        super(name);
    }

    //type
}

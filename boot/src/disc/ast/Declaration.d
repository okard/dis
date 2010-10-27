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
import disc.ast.Visitor;
import disc.ast.Type;
import disc.ast.Statement;

/**
* Basic Class for Declaration
*/
abstract class Declaration : Node
{
    ///name
    public string mName;
    
    mixin VisitorMixin;
    
    /**
    * Ctor
    */
    public this()
    {
    }

    /**
    * Ctor
    */
    public this(string name)
    {
        this.mName = name;
    }    
}

/**
* Package
*/
class PackageDeclaration : Declaration
{
    //Functions
    FunctionDeclaration[] mFunctions;
        
    //ClassDeclaration[] mClasses;

    //Visitor Mixin
    mixin VisitorMixin;
    
    /**
    * Ctor
    */
    public this(string name)
    {
        super(name);
    }
}

/**
* Function Declaration (def)
*/
class FunctionDeclaration : Declaration
{
    //Visitor Mixin
    mixin VisitorMixin;

    //flags: public, private, protected, package, static

    //parameter names? index of parameter type
    public ubyte[string] mArgumentNames;
    public string mVarArgsName;

    //Function Signature
    public FunctionType mType;
    //Has a Body
    public BlockStatement mBody;

    /**
    * Default Ctor
    */
    public this()
    {
        mType = new FunctionType();
        this.mNodeType = NodeType.FunctionDecl;
    }

    /**
    * Ctor
    */
    public this(string name)
    {
        this();
        this.mName = name;
    }   
}

/**
* Variable Declaration (var)
*/
class VariableDeclaration : Declaration
{
    //Variable Type
    private Type mType;

    //Initializer
    //Expression mInitializer;

    /**
    * Ctor
    */
    public this(string name, Type type = new OpaqueType())
    {
        super(name);
        this.mNodeType = NodeType.VariableDecl;
        this.mType = type;
    }

    /**
    * Get type
    */
    public Type type()
    {
        return mType;
    }
}

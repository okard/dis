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
module dlf.ast.Declaration;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Type;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.SymbolTable;

/**
* Basic Class for Declaration
*/
abstract class Declaration : Node
{
    /// Flags for Declaration
    enum Flags : ushort { Private=1, Protected=2, Public=4, Package=8, Static=16, Final=32, Const=64, Extern=128 } 

    ///name
    public string Name;

    //DataType DataType;
    
    //Visitor Mixin
    //mixin VisitorMixin;

    //Location?
}

/**
* Package
*/
class PackageDeclaration : Declaration
{
    //Visitor Mixin
    mixin VisitorMixin;

    /// Symbol Table
    public SymbolTable SymTable;
    /// Imports
    ImportDeclaration[] Imports;
    /// Variables
    VariableDeclaration[] Variables;
    /// Functions
    FunctionDeclaration[] Functions;
    /// Classes
    ClassDeclaration[] Classes;
    /// Traits
    TraitDeclaration[] Traits;

    /**
    * Ctor
    */
    public this(string name)
    {
        mixin(set_nodetype);
        Name = name;
    }
}

/**
* Import Declaration
*/
public class ImportDeclaration : Declaration
{
    //Visitor Mixin
    mixin VisitorMixin;

    ///Holds a PackageNode
    PackageDeclaration Package;
}


/// Function Parameter Helper 
struct FunctionParameter
{
    //char[][]
    //DataType
    //Name
    //Index
    //Modifiers/Flags (ref, const, ...)
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
    //map the names to the datatyps index of FunctionType
    public ubyte[string] mArgumentNames;
    //If VarArgs Function the Parameter Name for VarArgs
    public string mVarArgsName;

    /// Is Template Function
    bool isTemplate;

    ///Function Signature
    public FunctionType FuncType;
    
    ///Has a Body (BlockStatement, Statement, Expression)
    public Statement Body;

    /**
    * Default Ctor
    */
    public this()
    {
        mixin(set_nodetype);
        FuncType = new FunctionType(); 
    }

    /**
    * Ctor
    */
    public this(string name)
    {
        this();
        this.Name = name;
    }   
}

/**
* Variable Declaration (var)
*/
class VariableDeclaration : Declaration
{
    //Visitor Mixin
    mixin VisitorMixin;

    /// Variable Type
    public DataType VarDataType;

    /// Initializer
    public Expression Initializer;

    /**
    * Ctor
    */
    public this(string name, DataType type = OpaqueType.Instance)
    {
        mixin(set_nodetype);
        this.Name = name;
        this.VarDataType = type;
    }
}

/**
* Class Declaration
*/
class ClassDeclaration : Declaration
{
    //Visitor Mixin
    //mixin VisitorMixin;

    //ClassType?
    //BaseClass
    //Traits

    //VariableDeclaration[] Variables;
    //FunctionDeclaration[] Methods;

    /// Save Class Type inner?
    class ClassType : DataType
    {
        //mixinSIngleton
    }
}

/**
* Trait Declaration
*/
class TraitDeclaration : Declaration
{
    //Visitor Mixin
    //mixin VisitorMixin;

    //TraitType?
    //Variables, Methods, Properties
}

//Type Declarations: Struct, Enum, Alias, Delegate 

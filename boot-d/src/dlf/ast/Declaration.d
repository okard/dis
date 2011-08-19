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
    enum Flags : ushort { Private=1, Protected=2, Public=4, Package=8, 
                          Static=16, Final=32, Const=64, Extern=128 } 
    
    /// Name
    public string Name;

    // FQN ?? Full Qualified Name
}

/**
* Package
*/
final class PackageDeclaration : Declaration
{
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
    /// Runtime enabled
    bool RuntimeEnabled;

    /**
    * Ctor
    */
    public this(string name)
    {
        Name = name;
    }

    @property public override NodeKind Kind(){ return NodeKind.PackageDeclaration; }
}

/**
* Import Declaration
*/
final class ImportDeclaration : Declaration
{
    ///Name
    string Name;

    ///Holds a PackageNode
    PackageDeclaration Package;

    @property public override NodeKind Kind(){ return NodeKind.ImportDeclaration; }
}


/**
* Function Parameter 
*/
struct FunctionParameter
{
    ///String Definition
    char[][] Definition;
    /// DatatType of Parameter
    DataType Type;
    /// Parameter Name
    string Name;
    /// Vararg
    bool Vararg;
    /// Index, Position of Parameter
    ushort Index;

    //Modifiers/Flags (ref, const, ..., vararg)
}
    

/**
* Function Declaration (def)
*/
final class FunctionDeclaration : Declaration
{
    /// The Function Parameters
    public FunctionParameter[] Parameter;

    /// Instancen? generated at semantic step
    public FunctionType[] Instances;

    ///Has a Body (BlockStatement, Statement, Expression)
    public Statement Body;

    /// Is Template Function (here?)
    bool isTemplate;

    //calling conventions are part of declartion not of type
    //flags: public, private, protected, package, static

    //parameter names? index of parameter type
    //map the names to the datatyps index of FunctionType
    
    //OLD:

    public ubyte[string] mArgumentNames; //DELETE
    //If VarArgs Function the Parameter Name for VarArgs
    public string mVarArgsName; //DELETE

    ///Function Signature (DELETE)
    public FunctionType FuncType;

    /**
    * Default Ctor
    */
    public this()
    {
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

    //
    @property public override NodeKind Kind(){ return NodeKind.FunctionDeclaration; }
}

/**
* Variable Declaration (var)
*/
final class VariableDeclaration : Declaration
{
    /// Variable Type
    public DataType VarDataType;

    /// Initializer
    public Expression Initializer;

    /**
    * Ctor
    */
    public this(string name, DataType type = OpaqueType.Instance)
    {
        Name = name;
        VarDataType = type;
    }

    @property public override NodeKind Kind(){ return NodeKind.VariableDeclaration; }
}

//value declaration

//class template parameter?

/**
* Class Declaration
*/
final class ClassDeclaration : Declaration
{
    //BaseClass / Parent Class
    //Traits
    //Mixins

    //VariableDeclaration[] Variables;
    //FunctionDeclaration[] Methods;

    public ClassType[] Instances;


    @property public override NodeKind Kind(){ return NodeKind.VariableDeclaration; }
}

/**
* Trait Declaration
*/
final class TraitDeclaration : Declaration
{
    //Visitor Mixin
    //mixin VisitorMixin;

    //TraitType?
    //Variables, Methods, Properties

    @property public override NodeKind Kind(){ return NodeKind.TraitDeclaration; }
}

/**
* Type Declaration Base Class
* For Struct, Enum, Alias, Delegates
*/
abstract class TypeDeclaration : Declaration
{
}

/**
* Structure Type
*/
final class StructDeclaration : TypeDeclaration
{
}

/**
* Enum Type
*/
final class EnumDeclaration : TypeDeclaration
{
}

/**
* Alias Declaration
*/
final class AliasDeclaration : TypeDeclaration
{
}

/**
* Delegate Declaration
*/
final class DelegateDeclaration : TypeDeclaration
{
}

/**
* Variant Declaration
*/
final class VariantDeclaration : TypeDeclaration
{

}


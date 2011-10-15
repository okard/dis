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

import std.datetime;

import dlf.basic.Location;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Type;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Special;
import dlf.ast.SymbolTable;

/**
* Basic Class for Declaration
*/
abstract class Declaration : Node
{
    /// Flags for Declaration
    enum Flags : ushort { Private=1, Protected=2, Public=4, Package=8, 
                          Static=16, Final=32, Const=64, Abstract=128 } 
    
    /// Name
    public string Name;

    // FQN ?? Full Qualified Name

    //uint Index;
}

/// Supported Calling Conventions for classes and functions
public enum CallingConvention {None, C, Dis}

/**
* Package
*/
final class PackageDeclaration : Declaration
{
    /// Symbol Table
    public SymbolTable SymTable;

    /// Imports
    ImportDeclaration[] Imports;

    /// Runtime enabled
    bool RuntimeEnabled = true;

    /// Modification Date
    SysTime modificationDate;
    
    ///Mixin for Kind Declaration
    mixin(IsKind("PackageDeclaration"));
}

/**
* Import Declaration
*/
final class ImportDeclaration : Declaration
{
    /// Import Identifier
    CompositeIdentifier ImportIdentifier;

    /// Wildcard Import (e.g. foo.*)
    bool IsWildcardImport;

    /// The associated package node
    PackageDeclaration Package;

    ///Mixin for Kind Declaration
    mixin(IsKind("ImportDeclaration"));
}


/**
* Function Parameter 
*/
struct FunctionParameter
{
    ///String Definition
    string[] Definition;
    /// DatatType of Parameter
    DataType Type;
    /// Parameter Name
    string Name;
    /// Vararg
    bool Vararg = false;
    /// Index, Position of Parameter
    ushort Index;

    //Modifiers/Flags (ref, const, ..., vararg)
    //Contraints
}

/**
* A Function Base
*/
class FunctionBase : Node
{
    /// The Function Parameters
    public FunctionParameter[] Parameter;

    /// Return Type
    public DataType ReturnType;

    /// Has a Body (BlockStatement, Statement, Expression)
    public Statement Body;

    /// Is Template Function (here?)
    bool IsTemplate;

    /// Is a extension method declaration
    public bool IsExtensionMethod;

    /// Calling Convention
    public CallingConvention CallingConv;

    mixin(IsKind("FunctionBase"));
}
    

/**
* Function Declaration (def)
*/
final class FunctionSymbol : Declaration
{
    /// Function bases for ad-hoc polymorphism
    public FunctionBase[] Bases;

    /// Instances generated in semantic step
    public FunctionType[] Instances;

    /**
    * Ctor
    */
    public this(string name)
    {
        this.Name = name;
    }   

    ///Mixin for Kind Declaration
    mixin(IsKind("FunctionSymbol"));
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

    ///Mixin for Kind Declaration
    mixin(IsKind("VariableDeclaration"));
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
    //FunctionSymbols[] Methods;

    public ClassType[] Instances;


    ///Mixin for Kind Declaration
    mixin(IsKind("ClassDeclaration"));
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

    ///Mixin for Kind Declaration
    mixin(IsKind("TraitDeclaration"));
}

/**
* Type Declaration Base Class
* For Struct, Enum, Alias, Delegates
*/
abstract class TypeDeclaration : Declaration
{
}

/**
* Enum Type
*/
final class EnumDeclaration : TypeDeclaration
{
    ///Mixin for Kind Declaration
    mixin(IsKind("EnumDeclaration"));
}

/**
* Alias Declaration
*/
final class AliasDeclaration : TypeDeclaration
{
    ///Mixin for Kind Declaration
    mixin(IsKind("AliasDeclaration"));
}

/**
* Variant Declaration
*/
final class VariantDeclaration : TypeDeclaration
{
    ///Mixin for Kind Declaration
    mixin(IsKind("VariantDeclaration"));
}


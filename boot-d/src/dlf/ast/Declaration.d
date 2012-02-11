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
import dlf.ast.Annotation;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Special;
import dlf.ast.SymbolTable;

/// Flags for Declaration
enum DeclarationFlags : ushort 
{ 
    Blank=0,
    //information hiding
    Private= 1 << 0, 
    Protected= 1 << 1, 
    Public= 1 << 2, 
    Package= 1 << 3, 
    
    //modifiers
    Static= 1 << 4, 
    Final= 1 << 5, 
    Const= 1 << 6, 
    Abstract= 1 << 7 
} 

/**
* Basic Class for Declaration
*/
abstract class Declaration : Node
{
    /// Name
    public string Name;

    /// Full Qualified Name
    public string FQN;

    /// Flags
    public DeclarationFlags Flags;

    /// Annotations
    public Annotation[] Annotations;

    //uint Index;

    //TODO DocComment
}

/// Supported Calling Conventions for classes and functions
public enum CallingConvention {None, C, Dis}

/**
* Package
*/
final class PackageDecl : Declaration
{
    /// Package Identifier
    CompositeIdentifier PackageIdentifier;

    /// Symbol Table
    public SymbolTable SymTable;

    /// Imports
    ImportDecl[] Imports;

    /// Runtime enabled
    bool RuntimeEnabled = true;

    /// Is a Header Package
    bool IsHeader = false;

    /// Modification Date
    SysTime modificationDate;
    
    /// Mixin for Kind Declaration
    mixin(IsKind("PackageDecl"));
}

/**
* Import Declaration
*/
final class ImportDecl : Declaration
{
    /// Import Identifier
    CompositeIdentifier ImportIdentifier;

    /// Wildcard Import (e.g. foo.*)
    bool IsWildcardImport;

    /// The associated package node
    PackageDecl Package;

    /// Mixin for Kind Declaration
    mixin(IsKind("ImportDecl"));
}


/**
* Function Parameter 
*/
struct FunctionParameter
{
    /// Parameter Name
    string Name;
    
    /// DataType of Parameter
    DataType Type;
    
    /// Is it a Vararg Parameter
    bool Vararg = false;
    
    /// Index No, Position of Parameter
    ushort Index;

    //Modifiers/Flags (ref, const, ..., vararg)

    //ContraintType -> DataType
}

/**
* A Function Base
*/
class FunctionDecl : Declaration
{
    /// The Function Parameters
    public FunctionParameter[] Parameter;

    /// Return Type
    public DataType ReturnType;

    /// Has a Body (BlockStatement, Statement, Expression)
    public BlockStmt Body;

    //public Statement[] Body
    //public SymbolTable

    /// Overrides of this function
    public FunctionDecl[] Overrides;

    //required store functiontypes directly with bodies? InstanceBodies.keys
    /// The function types used for template funcs
    public FunctionType[] Instances;
    
    /// The generated bodies for the function types
    public Statement[FunctionType] InstanceBodies;
    
    /// Is Template Function (here?)
    public bool IsTemplate;

    /// Is a extension method declaration
    public bool IsExtensionMethod;

    /// Is nested function
    public bool IsNested;

    /// Calling Convention
    public CallingConvention CallingConv;

    /// Mixin for Kind Declaration
    mixin(IsKind("FunctionDecl"));
}

/**
* Variable Declaration (var)
*/
final class VarDecl : Declaration
{
    /// Variable Type
    public DataType VarDataType;

    /// Initializer
    public Expression Initializer;

    //is Parameter?

    /**
    * Ctor
    */
    public this(string name, DataType type = OpaqueType.Instance)
    {
        Name = name;
        VarDataType = type;
    }

    /**
    * Ctor
    */
    public this(DataType type = OpaqueType.Instance)
    {
        VarDataType = type;
    }

    /// Mixin for Kind Declaration
    mixin(IsKind("VarDecl"));
}

/**
* Value Declaration
*/
final class ValDecl : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("ValDecl"));
}

/**
* Constant Declaration
*/
final class ConstDecl : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("ConstDecl"));
}

/**
* Structure Declaration
*/
final class StructDecl : Declaration
{
    /// Symbol Table
    public SymbolTable SymTable;

    /// Calling Convention
    public CallingConvention CallingConv;

    /// Inherits from Base
    public IdentifierExpression BaseIdentifier;
    
    /// Base Resolved
    public Declaration BaseStruct;
    
    /// Mixin for Kind Declaration
    mixin(IsKind("StructDecl"));
}


/**
* Class Declaration
*/
final class ClassDecl : Declaration
{
    /// Symbol Table
    public SymbolTable SymTable;


    public FunctionDecl Ctor;
    public FunctionDecl Dtor;

    //static ctor, dtor

    

    //BaseClass / Parent Class 
    //Multi inheritance?
    //Traits
    //Mixins

    //VarDecl[] Variables;
    //FunctionSymbols[] Methods;

    /// Is Template Class
    public bool IsTemplate;

    public ClassType[] Instances;


    /// Mixin for Kind Declaration
    mixin(IsKind("ClassDecl"));
}

/**
* Trait Declaration
*/
final class TraitDecl : Declaration
{
    //TraitType?
    //Variables, Methods, Properties

    /// Mixin for Kind Declaration
    mixin(IsKind("TraitDecl"));
}

/**
* Alias Declaration
*/
final class AliasDecl : Declaration
{
    /// The target type
    DataType AliasType;

    /// Mixin for Kind Declaration
    mixin(IsKind("AliasDecl"));
}

/**
* Enum Type
*/
final class EnumDecl : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("EnumDecl"));
}

/**
* Variant Declaration
*/
final class VariantDecl : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("VariantDecl"));
}


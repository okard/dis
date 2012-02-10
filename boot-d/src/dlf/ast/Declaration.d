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
    ImportDeclaration[] Imports;

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
final class ImportDeclaration : Declaration
{
    /// Import Identifier
    CompositeIdentifier ImportIdentifier;

    /// Wildcard Import (e.g. foo.*)
    bool IsWildcardImport;

    /// The associated package node
    PackageDecl Package;

    /// Mixin for Kind Declaration
    mixin(IsKind("ImportDeclaration"));
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
class FunctionDeclaration : Declaration
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
    public FunctionDeclaration[] Overrides;

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
    mixin(IsKind("FunctionDeclaration"));
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
    mixin(IsKind("VariableDeclaration"));
}

/**
* Value Declaration
*/
final class ValueDeclaration : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("ValueDeclaration"));
}

/**
* Constant Declaration
*/
final class ConstantDeclaration : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("ConstantDeclaration"));
}

/**
* Structure Declaration
*/
final class StructDeclaration : Declaration
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
    mixin(IsKind("StructDeclaration"));
}


/**
* Class Declaration
*/
final class ClassDeclaration : Declaration
{
    /// Symbol Table
    public SymbolTable SymTable;


    public FunctionDeclaration Ctor;
    public FunctionDeclaration Dtor;

    //static ctor, dtor

    

    //BaseClass / Parent Class 
    //Multi inheritance?
    //Traits
    //Mixins

    //VariableDeclaration[] Variables;
    //FunctionSymbols[] Methods;

    /// Is Template Class
    public bool IsTemplate;

    public ClassType[] Instances;


    /// Mixin for Kind Declaration
    mixin(IsKind("ClassDeclaration"));
}

/**
* Trait Declaration
*/
final class TraitDeclaration : Declaration
{
    //TraitType?
    //Variables, Methods, Properties

    /// Mixin for Kind Declaration
    mixin(IsKind("TraitDeclaration"));
}

/**
* Alias Declaration
*/
final class AliasDeclaration : Declaration
{
    /// The target type
    DataType AliasType;

    /// Mixin for Kind Declaration
    mixin(IsKind("AliasDeclaration"));
}

/**
* Enum Type
*/
final class EnumDeclaration : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("EnumDeclaration"));
}

/**
* Variant Declaration
*/
final class VariantDeclaration : Declaration
{
    /// Mixin for Kind Declaration
    mixin(IsKind("VariantDeclaration"));
}


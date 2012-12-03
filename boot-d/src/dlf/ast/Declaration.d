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
import dlf.ast.SymbolTable; //TODO Remove all ast -> SymTable References

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
    Abstract= 1 << 7, 

    Internal= 1 << 8, //internal symbol only accessable from package itself
    Export= 1 << 9    //Export Symbol (For libraries)
    
    //when no Internal and no Export only the current compilation has access to the function
} 

/// Supported Calling Conventions for classes and functions
public enum CallingConvention {None, C, Dis}

/**
* Basic Class for Declaration
*/
abstract class Declaration : Node
{
    /// Name
    public string Name;

    /// Full Qualified Name (to symbol table?, pay attention with template methods)
    public string FQN;

    /// Flags
    public DeclarationFlags Flags;

    /// Attributes
    public Attribute[] Attributes;

    //uint Index;

    //DataType

    //TODO DocComment

    @property
    abstract bool IsInstanceDecl();

    
    final bool hasFlag(DeclarationFlags flag)
    {
        return (Flags & flag) == flag;
    }
}

/**
* Declaring new Types
*/
abstract class TypeDecl : Declaration
{
    //TODO have all type decl a symbol table? O_o
    @property
    final override bool IsInstanceDecl(){return false;}
}

/**
* Declaring new Instances of Types
*/
abstract class InstanceDecl : Declaration
{
    @property
    final override bool IsInstanceDecl(){return true;}
}

//Two Subtypes of Declarations

//Instancing and New Type Declaration

/**
* Package
* package foo.bar.abc 
* Package(foo)->Package(bar)->Package(abc)
*/
final class PackageDecl : TypeDecl
{
	// Mixin for Kind Declaration
    mixin KindMixin!(NodeKind.PackageDecl);
    
    // Mixin for Visitor
    mixin VisitorMixin;
    
    ///TODO Remove Package Identifier
    CompositeIdentifier PackageIdentifier;

    ///TODO Remove Symbol Table
    public SymbolTable SymTable;

    /// Imports
    ImportDecl[] Imports;
    
    /// Sub Packages
    PackageDecl SubPkg[];
    
    /// Child Declarations
    Declaration Declarations[];

    /// Defined Versions?  
    bool Version[string];

    /// Runtime enabled
    bool RuntimeEnabled = true;

    /// Is a Header Package
    bool IsHeader = false;
    
    ///The package requested from parseFunction?
    //Name? CompilationUnit? 
    bool ParseTarget = false;
    
    /// Is a root package
    bool IsRootPkg()
    {
		return Parent is null;
	}

    /// Modification Date (TODO resolve via location.id and source manager?)
    SysTime modificationDate;
}

/**
* Import Declaration
*/
final class ImportDecl : TypeDecl
{
	// Mixin for Visitor
    mixin VisitorMixin;
    
    /// Import Identifier
    CompositeIdentifier ImportIdentifier;

    //TODO Symbol Table?

    //save in components in SymbolTable

    /// Wildcard Import (e.g. foo.*)
    bool IsWildcardImport;

    /// The associated package node
    PackageDecl Package;

    /// Mixin for Kind Declaration
    mixin(IsKind("ImportDecl"));
}

/**
* Function Parameter 
* TODO also a Declaration? for saving in Symbol Table
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

    //Modifiers/Flags ( ..., vararg)
    // in, out, inout
    // by-value -> in
    // by-ref/ptr-const -> in
    // by-ref/ptr-noconst -> inout
    //out -> the parameter has to be assigned
}

/**
* A Function Base
*/
class FunctionDecl : TypeDecl
{
	// Mixin for Visitor
    mixin VisitorMixin;
    
    /// The Function Parameters
    public FunctionParameter[] Parameter;

    /// Return Type
    public DataType ReturnType;

    /// The SymbolTable
    public SymbolTable SymTable;

    /// Has a Body (BlockStatement, Statement, Expression)
    public Statement[] Body;
    
    /// Overrides of this function
    public FunctionDecl[] Overrides;

    //TODO the final generated Declarations can also seperate FunctionDecl? Chaining? see also semantic

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
* Structure Declaration
*/
final class StructDecl : TypeDecl
{
	// Mixin for Visitor
    mixin VisitorMixin;
    
    /// Symbol Table (Functions and so on)
    public SymbolTable SymTable;

    /// Calling Convention
    public CallingConvention CallingConv;

    /// Inherits from Base
    public DataType BaseType;
    
    /// Mixin for Kind Declaration
    mixin(IsKind("StructDecl"));
}


/**
* Class Declaration
*/
final class ClassDecl : TypeDecl
{
	// Mixin for Visitor
    mixin VisitorMixin;
    
    /// Symbol Table
    public SymbolTable SymTable;

    //ClassTplArguments Name/DataType/Contraint

    //TODO Template Arguments
    public ClassDecl BaseClass; 

    //Multi inheritance?
    //Mixins
    //Traits

    //TODO Template Arguments
    public TraitDecl[] Traits; 
    
    //Static Ctor/Dtor
    public FunctionDecl StaticCtor;
    public FunctionDecl StaticDtor;

    //Normal Ctor/Dtor
    public FunctionDecl[] Ctor;
    public FunctionDecl Dtor;

    /// Is Template Class
    public bool IsTemplate;

    //Implementations
    //public ClassDecl[DeclarationType] Instances;

    /// Mixin for Kind Declaration
    mixin(IsKind("ClassDecl"));
}

//ClassFunctionDecl
//IsCtor
//IsDtor


/**
* Trait Declaration
*/
final class TraitDecl : TypeDecl
{
	// Mixin for Visitor
    mixin VisitorMixin;
    
    /// Symbol Table
    public SymbolTable SymTable;

    //Variables, Methods, Properties

    /// Mixin for Kind Declaration
    mixin(IsKind("TraitDecl"));
}

/**
* Alias Declaration
*/
final class AliasDecl : TypeDecl
{
	// Mixin for Visitor
    mixin VisitorMixin;
    
    /// The target type
    DataType AliasType;

    /// Mixin for Kind Declaration
    mixin(IsKind("AliasDecl"));
}

/**
* Enum Type
*/
final class EnumDecl : TypeDecl
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    /// Mixin for Kind Declaration
    mixin(IsKind("EnumDecl"));
}

/**
* Variant Declaration
*/
final class VariantDecl : TypeDecl
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    /// Mixin for Kind Declaration
    mixin(IsKind("VariantDecl"));
}

/**
* Variable Declaration (var)
*/
final class VarDecl : InstanceDecl
{
	// Mixin for Visitor
    mixin VisitorMixin;
    
    /// Variable Type
    public DataType VarDataType;
    //TODO naming

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
final class ValDecl : InstanceDecl
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    /// Mixin for Kind Declaration
    mixin(IsKind("ValDecl"));
}

/**
* Constant Declaration
*/
final class ConstDecl : InstanceDecl
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    /// Mixin for Kind Declaration
    mixin(IsKind("ConstDecl"));
}


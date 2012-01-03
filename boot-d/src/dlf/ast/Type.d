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
module dlf.ast.Type;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.basic.Util;

/**
* Base Type Class
*/
abstract class DataType : Node
{
     /// is Runtime Type
     public bool isRuntimeType = false;

     //ptr type
     //type size

     /// Pointer Singleton Mixin
     protected mixin template PtrTypeSingleton()
     {
        private static PointerType _PtrInstance;

        static this()
        {
            _PtrInstance  = new PointerType(Instance);
        }

        @property
        public static PointerType PtrInstance()
        {
            return _PtrInstance;
        }
     }

    mixin(IsKind("DataType"));
}

/// Void
final class VoidType : DataType
{
    override string toString() { return "void"; }
    mixin Singleton!VoidType;
    mixin PtrTypeSingleton;
}

/// 1 Bit Type
final class BoolType : DataType
{
    override string toString() { return "bool"; }
    mixin Singleton!BoolType;
    mixin PtrTypeSingleton;
}

/// 8 Bit signed
final class ByteType : DataType
{
    override string toString() { return "byte"; }
    mixin Singleton!ByteType;
    mixin PtrTypeSingleton;
}

/// 8 Bit unsigned
final class UByteType : DataType
{
    override string toString() { return "ubyte"; }
    mixin Singleton!UByteType;
    mixin PtrTypeSingleton;
}

/// 16 Bit
final class ShortType : DataType
{
    override string toString() { return "short"; }
    mixin Singleton!ShortType;
    mixin PtrTypeSingleton;
}

/// 16 Bit
final class UShortType : DataType
{
    override string toString() { return "ushort"; }
    mixin Singleton!UShortType;
    mixin PtrTypeSingleton;
}

/// 32 Bit
final class IntType : DataType
{
    override string toString() { return "int"; }
    mixin Singleton!IntType;
    mixin PtrTypeSingleton;
}

/// 32 Bit
final class UIntType : DataType
{
    override string toString() { return "uint"; }
    mixin Singleton!UIntType;
    mixin PtrTypeSingleton;
}

/// 64 Bit
final class LongType : DataType
{
    override string toString() { return "long"; }
    mixin Singleton!LongType;
    mixin PtrTypeSingleton;
}

/// 64 Bit
final class ULongType : DataType
{
    override string toString() { return "ulong"; }
    mixin Singleton!ULongType;
    mixin PtrTypeSingleton;
}

/// 32 Bit Floating Point IEEE754
final class FloatType : DataType
{
    override string toString() { return "float"; }
    mixin Singleton!FloatType;
    mixin PtrTypeSingleton;
}

/// 64 Bit Floating Point IEEE754
final class DoubleType : DataType
{
    override string toString() { return "double"; }
    mixin Singleton!DoubleType;
    mixin PtrTypeSingleton;
}

/**
* Not known datatype
* For implicit typing
*/
final class OpaqueType : DataType
{
    override string toString() { return "<Opaque>"; }
    mixin Singleton!OpaqueType;
    mixin(IsKind("OpaqueType"));
}

/**
* Unsolved Type
* Type setted, but not yet solved
*/
final class UnsolvedType : DataType
{
    /// The datatype in string representation
    string TypeString;
    //CompositeIdentifier

    //ctor
    this(string type){ TypeString = type; }
    /// to string
    override string toString() { return TypeString; };
    mixin(IsKind("UnsolvedType"));
}

//unparsed datatype?
// string array?


/**
* PointerType 
* Ptr to a type
*/
class PointerType : DataType 
{
    ///The Type this PoiThe Intelligent Transport Layer - nterType points to
    public DataType PointType;

    ///Create new PointerType
    public this(DataType t)
    {
        PointType = t;
        //TODO cache with static opcall?
    }

    ///toString
    override string toString() 
    { 
        return PointType.toString() ~ "*"; 
    }
}

/**
* Char Type
*/
class CharType : DataType
{
    //encoding???
    override string toString() { return "char"; }
    mixin Singleton!CharType;
    mixin PtrTypeSingleton;
}

/**
* String Type aka ArrayType(CharType)?
* Runtime Type
*/
class StringType : DataType
{ 
    //encoding???
    override string toString() { return "string"; }
    mixin Singleton!StringType;
}

/**
* Array Type
*/
class ArrayType : DataType
{
    /// DataType of Array
    public DataType ArrType;
    /// Size of Array
    public uint Size;
    /// Is Dynamic Array
    public bool Dynamic = false;
}

/**
* Defines a Function Signature
*/
class FunctionType : DataType
{
    /// The base function declaration of this type, Parent
    @property
    public auto FuncDecl() { return cast(FunctionDeclaration)Parent; }

    /// The function type arguments
    public DataType[] Arguments;

    /// The return type of function
    public DataType ReturnType;

    /// is a varargs function
    public bool mVarArgs;

    /// Body (for template functions) move to declarations
    public Statement Body;

    //mangled name?

    //match helper function?

    public this()
    {
        ReturnType = OpaqueType.Instance;
    }

    mixin(IsKind("FunctionType"));
}

/**
* Struct Type
*/
class StructType : DataType
{
    /// Struct Declaration
    public StructDeclaration StructDecl;
    
    //TODO indexes, offsets

    /// Struct Fields
    public DataType Fields[];
}

/**
* Class Type
*/
class ClassType : DataType
{
    /// The original class declaration
    public ClassDeclaration ClassDecl;

    //Template Classes can have subclasstypes?
    //Parent Class
    //template arguments specifications
    //classname!(datatypes, ...)
    //trait types
}

/**
* Trait Type 
*/
class TraitType : DataType
{
    ///The original trait declaration
    TraitDeclaration TraitDecl;
}


//enum type

//Variant Type
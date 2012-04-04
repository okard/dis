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
import dlf.ast.Special;
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

    //RefType instead of Ptr Type

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
final class Byte8Type : DataType
{
    override string toString() { return "byte8"; }
    mixin Singleton!Byte8Type;
    mixin PtrTypeSingleton;
}

/// 8 Bit unsigned
final class UByte8Type : DataType
{
    override string toString() { return "ubyte8"; }
    mixin Singleton!UByte8Type;
    mixin PtrTypeSingleton;
}

/// 16 Bit
final class Short16Type : DataType
{
    override string toString() { return "short16"; }
    mixin Singleton!Short16Type;
    mixin PtrTypeSingleton;
}

/// 16 Bit
final class UShort16Type : DataType
{
    override string toString() { return "ushort16"; }
    mixin Singleton!UShort16Type;
    mixin PtrTypeSingleton;
}

/// 32 Bit
final class Int32Type : DataType
{
    override string toString() { return "int32"; }
    mixin Singleton!Int32Type;
    mixin PtrTypeSingleton;
}

/// 32 Bit
final class UInt32Type : DataType
{
    override string toString() { return "uint32"; }
    mixin Singleton!UInt32Type;
    mixin PtrTypeSingleton;
}

/// 64 Bit
final class Long64Type : DataType
{
    override string toString() { return "long64"; }
    mixin Singleton!Long64Type;
    mixin PtrTypeSingleton;
}

/// 64 Bit
final class ULong64Type : DataType
{
    override string toString() { return "ulong64"; }
    mixin Singleton!ULong64Type;
    mixin PtrTypeSingleton;
}

/// 32 Bit Floating Point IEEE754
final class Float32Type : DataType
{
    override string toString() { return "float32"; }
    mixin Singleton!Float32Type;
    mixin PtrTypeSingleton;
}

/// 64 Bit Floating Point IEEE754
final class Double64Type : DataType
{
    override string toString() { return "double64"; }
    mixin Singleton!Double64Type;
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
* A composite type name
*/
final class DotType : DataType
{

    string Value;

    DataType Right;
    

    Declaration ResolvedDecl;
    DataType ResolvedType;

    //DataType left;

    mixin(IsKind("DotType"));
}


// string array? / char array / byte array 


/**
* PointerType 
* Ptr to a type
*/
class PointerType : DataType 
{
    ///The Type this PoiThe Intelligent Transport Layer - nterType points to
    public DataType PtrType;

    ///Create new PointerType
    public this(DataType t)
    {
        PtrType = t;
        //TODO cache with static opcall?
    }

    ///toString
    override string toString() 
    { 
        return "ptr " ~ PtrType.toString(); 
    }
}

/**
* Reference Type
*/
class ReferenceType : DataType
{
    public DataType RefType;

    ///toString
    override string toString() 
    { 
        return "ref " ~ RefType.toString(); 
    }
}

/**
* Char Type
* byte array?
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
* byte array
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
    public auto FuncDecl() { return Parent.to!FunctionDecl; }

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
    public StructDecl Decl;
    
    //TODO indexes, offsets

    /// Struct Fields
    public DataType Fields[];


    mixin(IsKind("StructType"));
}

/**
* Class Type
*/
class ClassType : DataType
{
    /// The original class declaration
    public ClassDecl Decl;

    //Template Classes can have subclasstypes?
    //Parent Class
    //template arguments specifications
    //classname!(datatypes, ...)
    //trait types

    mixin(IsKind("ClassType"));
}

/**
* Trait Type 
*/
class TraitType : DataType
{
    ///The original trait declaration
    TraitDecl Decl;


    mixin(IsKind("TraitType"));
}


//enum type

//Variant Type
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

     //abstract is primarytype

     //ptr type
     //type size
     //offset?

     /// Pointer Singleton Mixin
     protected mixin template PtrTypeSingleton()
     {
        private static PtrType _PtrInstance;

        static this()
        {
            _PtrInstance  = new PtrType(Instance);
        }

        @property
        public static PtrType PtrInstance()
        {
            return _PtrInstance;
        }
    }
}

abstract class PrimaryType(T, string name) : DataType
{
    override string toString() { return name; }
    mixin Singleton!T;
    mixin PtrTypeSingleton;
}

// Add a Basic Primary Type?

/// Void
final class VoidType : DataType
{
    override string toString() { return "void"; }
    mixin Singleton!VoidType;
    mixin PtrTypeSingleton;
    mixin(IsKind("VoidType"));
}

/// 1 Bit Type
final class BoolType : DataType
{
    override string toString() { return "bool"; }
    mixin Singleton!BoolType;
    mixin PtrTypeSingleton;
    mixin(IsKind("BoolType"));
}

/// 8 Bit signed
final class Byte8Type : DataType
{
    override string toString() { return "byte8"; }
    mixin Singleton!Byte8Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("Byte8Type"));
}

/// 8 Bit unsigned
final class UByte8Type : DataType
{
    override string toString() { return "ubyte8"; }
    mixin Singleton!UByte8Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("UByte8Type"));
}

/// 16 Bit
final class Short16Type : DataType
{
    override string toString() { return "short16"; }
    mixin Singleton!Short16Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("Short16Type"));
}

/// 16 Bit
final class UShort16Type : DataType
{
    override string toString() { return "ushort16"; }
    mixin Singleton!UShort16Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("UShort16Type"));
}

/// 32 Bit
final class Int32Type : DataType
{
    override string toString() { return "int32"; }
    mixin Singleton!Int32Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("Int32Type"));
}

/// 32 Bit
final class UInt32Type : DataType
{
    override string toString() { return "uint32"; }
    mixin Singleton!UInt32Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("UInt32Type"));
}

/// 64 Bit
final class Long64Type : DataType
{
    override string toString() { return "long64"; }
    mixin Singleton!Long64Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("Long64Type"));
}

/// 64 Bit
final class ULong64Type : DataType
{
    override string toString() { return "ulong64"; }
    mixin Singleton!ULong64Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("ULong64Type"));
}

/// 32 Bit Floating Point IEEE754
final class Float32Type : DataType
{
    override string toString() { return "float32"; }
    mixin Singleton!Float32Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("Float32Type"));
}

/// 64 Bit Floating Point IEEE754
final class Double64Type : DataType
{
    override string toString() { return "double64"; }
    mixin Singleton!Double64Type;
    mixin PtrTypeSingleton;
    mixin(IsKind("Double64Type"));
}

/**
* Not set datatype, place holder
* For implicit typing
*/
final class OpaqueType : DataType
{
    override string toString() { return "<Opaque>"; }
    mixin Singleton!OpaqueType;
    mixin(IsKind("OpaqueType"));
}

/**
* PointerType 
* Ptr to a type
*/
class PtrType : DataType 
{
    mixin(IsKind("PtrType"));

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
class RefType : DataType
{
    mixin(IsKind("RefType"));

    public DataType TargetType;

    ///toString
    override string toString() 
    { 
        return "ref " ~ TargetType.toString(); 
    }


}

/**
* Array Type
*/
class ArrayType : DataType
{
    mixin(IsKind("ArrayType"));

    /// DataType of Array
    public DataType TargetType;
    /// Size of Array
    public ulong Size;
    /// Is Dynamic Array
    public bool Dynamic = false;


    //static type for ref byte array

    public static RefType createArrayLiteral(ulong size)
    {
        auto arrType = new ArrayType();
        arrType.TargetType = Byte8Type.Instance;
        arrType.Size = size;
        auto refType = new RefType();
        refType.TargetType = arrType;
        return refType;
    }
}

//TODO add alias type for string literals == byte arrays

/**
* A composite type name
*/
final class DotType : DataType
{
    mixin(IsKind("DotType"));

    /// Name
    string Value; 

    /// Resolved Declaration
    Declaration ResolvedDecl;

    /// Concat (type.type.type...)
    DataType Right;
}

/**
* Something like that?
* Whats about Template Type Instancing?
* Merge with DotType?
*/
final class DeclarationType : DataType
{
    mixin(IsKind("DeclarationType"));

    /// Target Declaration
    public Declaration Decl;

    /// For template instancing?
    public DataType[] Arguments;
}

/**
* Defines a Function Signature
* Used for Anonymous/Declarated Functions 
*/
class FunctionType : DataType
{ 
    mixin(IsKind("FunctionType"));

    /// The base function declaration of this type, Parent
    // @property
    // public auto FuncDecl() { return Parent.to!FunctionDecl; }

    /// The function type arguments
    public DataType[] Arguments;

    /// The return type of function
    public DataType ReturnType;

    /// is a varargs function
    public bool mVarArgs;

    //match helper function?

    public this()
    {
        ReturnType = OpaqueType.Instance;
    }
}


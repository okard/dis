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
import dlf.basic.Util;

/**
* Base Type Class
*/
abstract class DataType : Node
{
     /// is Runtime Type
     public bool isRuntimeType = false;

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

    @property public override NodeKind Kind(){ return NodeKind.DataType; }
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
    override string toString() { return "ushort"; }
    mixin Singleton!ULongType;
    mixin PtrTypeSingleton;
}

/// 32 Bit Float 
final class FloatType : DataType
{
    override string toString() { return "float"; }
    mixin Singleton!FloatType;
    mixin PtrTypeSingleton;
}

/// 64 Bit
final class DoubleType : DataType
{
    override string toString() { return "double"; }
    mixin Singleton!DoubleType;
    mixin PtrTypeSingleton;
}

/**
* Not yet resolved type
*/
final class OpaqueType : DataType
{
    override string toString() { return "<Opaque>"; }
    mixin Singleton!OpaqueType;
}

/**
* PointerType 
* Ptr to a type
*/
class PointerType : DataType 
{
    ///The Type this PointerType points to
    public DataType PointType;

    ///Create new PointerType
    public this(DataType t)
    {
        PointType = t;
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
    public DataType ArrType;
    public uint Size;
}

/**
* Defines a Function Signature
*/
class FunctionType : DataType
{
    public enum CallingConvention {None, C, Dis}

    //Arguments
    public DataType[] Arguments;

    //Return Type
    public DataType ReturnType;

    //Varargs Function
    public bool mVarArgs;

    //Extensions Method
    public bool ExtensionMethod;

    // Generic Method Type
    public bool GenericMethod;

    //Calling Convention
    public CallingConvention CallingConv;

    //mangled name?

    //Generic FunctionTypes can have SubFunctionTypes?

    //Function Declaration //parent?
    //match?

    public this()
    {
        ReturnType = OpaqueType.Instance;
    }
}


/**
* Class Type
*/
class ClassType : DataType
{
    //Class Declaration
    //Template Classes can have subclasstypes?
    //Parent Class
    //template arguments specifications
}

/**
* Trait Type 
*/
class TraitType : DataType
{
    //Trait Declaration
}


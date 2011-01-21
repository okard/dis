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
import dlf.basic.Util;

/**
* Base Type Class
*/
abstract class DataType : Node
{
     public this() { mixin(set_nodetype); }
     public override void accept(Visitor v){}
}

/// Void
final class VoidType : DataType
{
    override string toString() { return "void"; }
    mixin Singleton!VoidType;
}

/// 1 Bit Type
final class BoolType : DataType
{
    override string toString() { return "bool"; }
    mixin Singleton!BoolType;
}

/// 8 Bit signed
final class ByteType : DataType
{
    override string toString() { return "byte"; }
    mixin Singleton!ByteType;
}

/// 8 Bit unsigned
final class UByteType : DataType
{
    override string toString() { return "ubyte"; }
    mixin Singleton!UByteType;
}

/// 16 Bit
final class ShortType : DataType
{
    override string toString() { return "short"; }
    mixin Singleton!ShortType;
}

/// 16 Bit
final class UShortType : DataType
{
    override string toString() { return "ushort"; }
    mixin Singleton!UShortType;
}

/// 32 Bit
final class IntType : DataType
{
    override string toString() { return "int"; }
    mixin Singleton!IntType;
}

/// 32 Bit
final class UIntType : DataType
{
    override string toString() { return "uint"; }
    mixin Singleton!UIntType;
}

/// 64 Bit
final class LongType : DataType
{
    override string toString() { return "long"; }
    mixin Singleton!LongType;
}

/// 64 Bit
final class ULongType : DataType
{
    override string toString() { return "ushort"; }
    mixin Singleton!ULongType;
}

/// 32 Bit Float 
final class FloatType : DataType
{
    override string toString() { return "float"; }
    mixin Singleton!FloatType;
}

/// 64 Bit
final class DoubleType : DataType
{
    override string toString() { return "double"; }
    mixin Singleton!DoubleType;
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

    //Generic FunctionTypes can have SubFunctionTypes?

    public this()
    {
        ReturnType = OpaqueType.Instance;
    }
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
}

/**
* String Type aka ArrayType(CharType)?
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
    //DataType type
    //Size 
}

/**
* Class Type
*/
class ClassType : DataType
{
    //Class Declaration
    //Template Classes can have subclasstypes?
}

/**
* Trait Type 
*/
class TraitType : DataType
{
    //Trait Declaration
}


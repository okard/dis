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
module disc.ast.Type;

import disc.ast.Node;
import disc.basic.Storage;

/**
* Base Type Class
*/
abstract class DataType
{
    public Storage!(NodeData) Store;
}

/// Void
class VoidType : DataType
{
    override string toString() { return "void"; }
}

/// 1 Bit Type
class BoolType : DataType
{
    override string toString() { return "bool"; }
}

/// 8 Bit signed
class ByteType : DataType
{
    override string toString() { return "byte"; }
}

/// 8 Bit unsigned
class UByteType : DataType
{
    override string toString() { return "ubyte"; }
}

/// 16 Bit
class ShortType : DataType
{
    override string toString() { return "short"; }
}

/// 16 Bit
class UShortType : DataType
{
    override string toString() { return "ushort"; }
}

/// 32 Bit
class IntType : DataType
{
    override string toString() { return "int"; }
}

/// 32 Bit
class UIntType : DataType
{
    override string toString() { return "uint"; }
}

/// 64 Bit
class LongType : DataType
{
    override string toString() { return "long"; }
}

/// 64 Bit
class ULongType : DataType
{
    override string toString() { return "ushort"; }
}

/// 32 Bit Float 
class FloatType : DataType
{
    override string toString() { return "float"; }
}

/// 64 Bit
class DoubleType : DataType
{
    override string toString() { return "double"; }
}

/**
* Not yet resolved type
*/
class OpaqueType : DataType
{
    override string toString() { return "<unkown>"; }
}

/**
* Defines a Function Signature
*/
class FunctionType : DataType
{
    public enum CallingConvention {None, C, Dis}

    //Arguments
    public DataType[] mArguments;
    //Return Type
    public DataType mReturnType;
    //Varargs Function
    public bool mVarArgs;
    //Calling Convention
    public CallingConvention mCallingConv;

    public this()
    {
        mReturnType = new VoidType();
    }
}

/**
* PointerType 
* Ptr to a type
*/
class PointerType : DataType 
{
    ///The Type this PointerType points to
    public DataType mType;

    ///Create new PointerType
    public this(DataType t)
    {
        mType = t;
    }

    ///toString
    override string toString() 
    { 
        return mType.toString() ~ "*"; 
    }
}

//String

/**
* CharType
*/
class CharType : DataType
{
    //encoding???

     override string toString() { return "char"; }
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
}

/**
* Trait Type 
*/
class TraitType : DataType
{
    //Trait Declaration
}


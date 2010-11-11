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
abstract class Type
{
    public Storage!(NodeData) Store;
}

/// Void
class VoidType : Type
{
    override string toString() { return "void"; }
}

/// 1 Bit Type
class BoolType : Type
{
    override string toString() { return "bool"; }
}

/// 8 Bit signed
class ByteType : Type
{
    override string toString() { return "byte"; }
}

/// 8 Bit unsigned
class UByteType : Type
{
    override string toString() { return "ubyte"; }
}

/// 16 Bit
class ShortType : Type
{
    override string toString() { return "short"; }
}

/// 16 Bit
class UShortType : Type
{
    override string toString() { return "ushort"; }
}

/// 32 Bit
class IntType : Type
{
    override string toString() { return "int"; }
}

/// 32 Bit
class UIntType : Type
{
    override string toString() { return "uint"; }
}

/// 64 Bit
class LongType : Type
{
    override string toString() { return "long"; }
}

/// 64 Bit
class ULongType : Type
{
    override string toString() { return "ushort"; }
}

/// 32 Bit Float 
class FloatType : Type
{
    override string toString() { return "float"; }
}

/// 64 Bit
class DoubleType : Type
{
    override string toString() { return "double"; }
}

/**
* Not yet resolved type
*/
class OpaqueType : Type
{
    override string toString() { return "<unkown>"; }
}

/**
* Defines a Function Signature
*/
class FunctionType : Type
{
    public enum CallingConvention {None, C, Dis}

    //Arguments
    public Type[] mArguments;
    //Return Type
    public Type mReturnType;
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
class PointerType : Type 
{
    public Type mType;

    public this(Type t)
    {
        mType = t;
    }

    override string toString() 
    { 
        return mType.toString() ~ "*"; 
    }
}

//ArrayType
//String

class CharType : Type
{
    //encoding???

     override string toString() { return "char"; }
}

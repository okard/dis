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

/**
* Base Type Class
*/
class Type
{
}

/**
* Primary Types
*/
enum PrimaryTypes : ubyte
{
    //Void
    Void,
    //Numbers
    Bool,       //1 Bit
    Byte,       //8 Bit signed
    UByte,      //8 Bit unsigned
    Short,      //16 Bit signed
    UShort,     //16 Bit unsigned
    Int,        //32 Bit signed
    UInt,       //32 Bit unsigned
    Long,       //64 Bit signed
    ULong,      //64 Bit unsigned
    //Floating Points
    Float,      //32 Bit IEEE 754
    Double,     //64 Bit IEEE 754
    //Pointer
    Ptr         //Pointer Type, Platform specific, void*
} 

/**
* PrimaryType
*/
class PrimaryType : Type
{
    //isPointer
    PrimaryTypes Type;

    public this(PrimaryTypes type)
    {
        this.Type = type;
    }

    //instances for PrimaryTypes
    static PrimaryType Void;
    static PrimaryType Int;

    static this()
    {
        Void = new PrimaryType(PrimaryTypes.Void);
        Int = new PrimaryType(PrimaryTypes.Int);
    }
}

/**
* Not yet resolved type
*/
class OpaqueType : Type
{
    
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
}

/**
* PointerType 
* Ptr to a type
*/
class PointerType : Type 
{
    public Type mType;
}

//ArrayType
//String
//Char?

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
    static PrimaryType Bool;
    static PrimaryType Byte;       
    static PrimaryType UByte;      
    static PrimaryType Short;      
    static PrimaryType UShort;     
    static PrimaryType Int;        
    static PrimaryType UInt;       
    static PrimaryType Long;       
    static PrimaryType ULong;      
    static PrimaryType Float;      
    static PrimaryType Double;

    static this()
    {
        Void = new PrimaryType(PrimaryTypes.Void);
        Bool = new PrimaryType(PrimaryTypes.Bool); 
        Byte = new PrimaryType(PrimaryTypes.Byte);       
        UByte = new PrimaryType(PrimaryTypes.UByte);      
        Short = new PrimaryType(PrimaryTypes.Short);      
        UShort = new PrimaryType(PrimaryTypes.UShort);     
        Int = new PrimaryType(PrimaryTypes.Int);        
        UInt = new PrimaryType(PrimaryTypes.UInt);       
        Long = new PrimaryType(PrimaryTypes.Long);       
        ULong = new PrimaryType(PrimaryTypes.ULong);      
        Float = new PrimaryType(PrimaryTypes.Float);      
        Double = new PrimaryType(PrimaryTypes.Double);
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

    public this()
    {
        mReturnType = PrimaryType.Void;
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
}

//ArrayType
//String
//Char?

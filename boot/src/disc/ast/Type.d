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

class PrimaryType : Type
{
    //isPointer
    PrimaryTypes Type;
}

//OpaqueType
//PointerType -> Ptr to Type
//ArrayType

class FunctionType
{
    //calling convention C, Dis, ... FunctionType or Declration?
    //parameter -> name, type
    //return type
    //vaargs
}


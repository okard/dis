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
module dlf.basic.ArrayBuffer;

/**
* Array Buffer
*/
struct ArrayBuffer(T)
{
    /// Array Element Store
    private T[] mArr;
    /// Index of first element
    private uint mStartIndex;
    /// Count of elements
    private uint mCount;

    /**
    * Ctor
    */
    public this(uint count = 10)
    {
        mStartIndex = 0;
        mCount = 0;
        mArr = new T[count];
    }

    /**
    * Index Operator
    */
    T opIndex(uint n)
    {
        auto index = mStartIndex + n;
        if(index >= mArr.length) 
            index = (mStartIndex + n) - mArr.length;

        //writefln("[%s] -> [%s]", n, index);
        return mArr[index];
    }

    /**
    * Remove Element from front
    */
    public T popFront()
    {
        auto t = mArr[mStartIndex];
        mStartIndex++;
        mCount--;
        return t;
    }

    /**
    * Add a element at the end of list
    */
    public T addAfter(T n)
    {
        if(mCount >= mArr.length)
            throw new Exception("ArrayBuffer is full, cant add more Elements");

        auto index = mStartIndex + mCount;
        if(index >= mArr.length) 
            index = (mStartIndex + mCount) - mArr.length;
        
        //writefln("%s -> el: %s", index, n);
        mArr[index] = n;
        mCount++;

        return n;
    }

    /**
    * Return count of elements
    */
    @property
    public uint length()
    {
        return mCount;
    }

    /**
    * Is empty
    */
    @property
    public bool empty()
    {
        return mCount == 0;
    }
}
 

// UnitTests ==================================================================

version(unittest) import std.stdio;

unittest
{
    auto ab = ArrayBuffer!int(8);

    ab.addAfter(1);
    ab.addAfter(2);
    ab.addAfter(3);

    assert(ab.popFront() == 1);
    assert(ab[0] == 2);
    assert(ab.length() == 2);

    ab.popFront();
    ab.popFront(); 
    assert(ab.length() == 0);
    
    for(int i = 4; i < 12; i++)
        ab.addAfter(i);
    
    assert(ab.length() == 8);

    for(uint i = 0; i < 8; i++)
        assert(ab[i] == i+4);

    bool exc = false;
    try { ab.addAfter(66); }
    catch { exc = true;}
    assert(exc  == true);

    writeln("[TEST] ArrayBuffer Tests passed");
}
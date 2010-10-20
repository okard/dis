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
module disc.basic.Stack;


/**
* Stack 
*/
struct Stack(T)
{
    /// Array with Stack Values
    T[] mStackArr;
    /// Elements in Stack
    uint mCount;

    /**
    * Ctor
    */
    this(uint size = 256)
    {
        mStackArr = new T[size];
        mCount = 0;
    }

    /**
    * Push Value on Stack
    */
    T push(T val)
    {
        if(mCount > mStackArr.length)
            throw new Exception("Stack overflow");

        mStackArr[mCount++] = val;
        return val;
    }

    /**
    * Pop Value from Stack
    */
    T pop()
    {
        if(mCount == 0)
            throw new Exception("Stack is empty");

        return mStackArr[--mCount];
    }

    /**
    * Element on Top
    */
    T top()
    {
        return mStackArr[mCount-1];
    }

    /**
    * Count of elements
    */
    uint length()
    {
        return mCount;
    }

    /**
    * Stack Size
    */
    uint size()
    {
        return mStackArr.length;
    }
} 

// UnitTests ==================================================================

version(unittest) import std.stdio;

unittest
{
    auto stack = Stack!int(20);
    assert(stack.size() == 20);
    assert(stack.length() == 0);

    for(uint i = 0; i < 10; i++)
        stack.push(i);
    
    assert(stack.length() == 10);

    for(uint i = 9; i > 0; i--)
    {
        assert(stack.pop() == i);
        assert(stack.length == i);
    }

    writeln("[TEST] Stack Tests passed");
}

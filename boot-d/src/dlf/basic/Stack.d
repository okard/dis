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
module dlf.basic.Stack;


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
    @property
    T top()
    {

        return mStackArr[mCount-1];
    }


    /**
    * Element on Index?
    */
    T opIndex(size_t index)
    {
        assert(index < mCount);
        return mStackArr[index];
    }

    /**
    * Count of elements
    */
    @property
    uint length()
    {
        return mCount;
    }

    /**
    * Stack Size
    */
    @property
    uint size()
    {
        return cast(uint)mStackArr.length;
    }

    /**
    * empty stack
    */
    @property
    bool empty()
    {
        return (mCount <= 0);
    }
    
} 

// UnitTests ==================================================================

unittest
{
    import std.stdio;

    auto stack = Stack!int(20);
    assert(stack.size() == 20);
    assert(stack.length() == 0);

    for(uint i = 0; i < 10; i++)
        stack.push(i);

    assert(stack[0] == 0);
    assert(stack[5] == 5);
    assert(stack[stack.length-1] == stack.top);
    
    assert(stack.length() == 10);

    for(uint i = 9; i > 0; i--)
    {
        assert(stack.pop() == i);
        assert(stack.length == i);
    }

    writeln("[TEST] Stack Tests passed");
}

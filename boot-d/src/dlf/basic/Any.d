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
module dlf.basic.Any;

/**
* Any Ptr Class
*/
struct Any
{
    /// Pointer to data
    private void* data;
    /// Current Type Info
    private TypeInfo type;

    /**
    * Ctor
    */
    public this(T)(T value)
    {
        data = new container!(T)(value);
        type = typeid(T);
    }

    /**
    * Assign Value
    */
    public void opAssign(T)(T value)
    {
        data = new container!(T)(value);
        type = typeid(T);
    }

    /**
    * Get Value
    */
    public T opCast(T)()
    {
        if(type == typeid(T))
        {
            auto c = cast(container!(T)*)this.data;
            return (*c).data;
        }
        else
            throw new Exception("Wrong Type: Can't cast " ~ type.toString ~ " to " ~ typeid(T).toString);
    }

    /**
    * Storage
    */
    private struct container(T)
    {
        public this(T value)
        {
            data = value;
        }
        T data;
    }
} 

// UnitTests ==================================================================

unittest
{
    import std.stdio;
    import std.exception;

    Any p = 5;
    int i = cast(int)p;
    assert(i == 5);
    
    p = "foo bar";
    assertThrown!Exception(cast(int)p);
    writeln("[TEST] Any Tests passed");
}
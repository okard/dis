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
module dlf.basic.Util;

import std.conv;
version(linux) import core.sys.posix.unistd;
version(Windows) import core.sys.windows.windows;

/**
* Is in Array Function
*/
public static bool isIn(T)(T t, T[] arr)
{
    if(arr.length == 0)
        return false;

    foreach(T ta; arr)
        if(ta == t)
            return true;
    return false;
}

/**
* Dummy Singleton Template for D stupity
*/
mixin template Singleton(T)
{
    ///Instance Variable
    public static T _Instance;

    /// Create Instance
    static this()
    {
        _Instance = new T();
    }

    /// Get Instance
    @property
    static T Instance()
    {
        return _Instance;
    }

    ///Private Constructor
    private this(){}
}


/**
*   ApplicationPath
*/
static class ApplicationPath
{
    const int BUFFER_SIZE = 2048;
    //TODO Buffer Result
    
    version(Windows)
    {
        static string get()
        {
            char buf[BUFFER_SIZE];
            auto bs = GetModuleFileNameA(GetModuleHandleW(null), buf.ptr, BUFFER_SIZE);
            auto str = std.conv.to!string(buf[0..bs]);
            //str = Util.replace!(char)(str,'\\','/');
            return str;
        }
    }           

    version(linux)
    {
        static string get()
        {
            char buf[BUFFER_SIZE];
            auto path = "/proc/self/exe\0";
            auto bs = readlink(path.ptr, buf.ptr, BUFFER_SIZE-1);
            buf[bs] = '\0';
            auto c = new char[](bs);
            c = buf[0..bs];
            return std.conv.to!string(c);
        }
    }
}

/**
* Check if a string is empty
*/
bool empty(string str)
{
    if(str is null) return true;
    if(str.length <= 0) return true;
    if(str == "") return true;
    return false;
}

/**
* Safe cast
*/
T to(T)(Object o)
{
    auto t = cast(T)o;
    if(t is null)
        throw new Exception("Can't cast " ~ typeid(o).toString() ~ " to " ~ typeid(T).toString());

    return t;
}

// UnitTests ==================================================================

unittest
{
    import std.stdio;
    import std.exception;

    //test isIn
    assert(isIn!int(3, [1, 2, 3, 4, 5]));
    assert(!isIn!int(6, [1, 2, 3, 4, 5]));
    assert(!isIn!int(6, []));

    //test application path
    auto app = ApplicationPath.get();
    assert(app.length > 0);

    //test empty
    assert(empty(null));
    assert(empty(""));
    
    //test safe cast to
    class foo {}
    class bar : foo{}
    class barr {}
    
    foo f = to!foo(new bar());
    assertThrown!Exception(to!foo(new barr()));
    bar b = to!bar(cast(foo)new bar());
    
    writeln("[TEST] Util Tests passed");
}
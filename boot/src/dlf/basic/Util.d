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


/**
* Is in Array Function
*/
public static bool isIn(T)(T t, T[] arr)
{
    foreach(T ta; arr)
        if(ta == t)
            return true;
    return false;
}


version(unittest) import std.stdio;

unittest
{
    //test isIn
    assert(isIn!int(3, [1, 2, 3, 4, 5]));
    assert(!isIn!int(6, [1, 2, 3, 4, 5]));

    writeln("[TEST] Util Tests passed");
}
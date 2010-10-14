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
module disc.basic.Location;

import std.conv;

/*
* Represents Code Location
*/
struct Location
{
    uint Line; 
    uint Col; 	
    
    /*
    * Create Loc
    */
    this(uint line, uint col)
    {
        Line = line;
        Col = col;
    }
    
    /*
    * to String
    */
    public char[] toString()
    {
        return "Line " ~ to!(char[])(Line) ~ ", Col " ~ to!(char[])(Col);
    }
}
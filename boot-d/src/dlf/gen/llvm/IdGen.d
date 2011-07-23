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
module dlf.gen.llvm.IdGen;

import std.conv;

/**
* IdGenerator
*/
struct IdGen
{
    // for global constant strings
    private uint _GenConstString = 0;
    string GenConstString()
    {
        return "_str_" ~ to!string(_GenConstString++);
    }

    // gen var name
    private uint _GenVar = 0;
    string GenVar()
    {
        return "_var_" ~ to!string(_GenVar++);
    }

    // gen basic block name
    private uint _GenBBName = 0;
    string GenBBName()
    {
        return "bb" ~ to!string(_GenBBName++);
    }
}
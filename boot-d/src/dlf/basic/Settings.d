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
module dlf.basic.Settings; 

import std.stdio;
import std.string;

/**
* Class for Configuration Handling
*/
class Settings
{
    ///key storage alias
    private alias string[string] keymap;

    ///save groups and keys
    private keymap[string] keys;

    private static const char GROUP_OPEN = '[';
    private static const char GROUP_CLOSE = ']';
    private static const char COMMENT = '#';

    /**
    * Load a file
    */
    void load(string filename)
    {
        auto f = File(filename, "r");
        
        char[] line;

        while (f.readln(line))
        {
            auto l = strip(line);
            if(l[0] == '#')
                continue;

            //[name]
            //key=name
        }
    }


    //get(string group, string

    //var replacement, delegate mapping?
}
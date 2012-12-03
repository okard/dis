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
module dlf.basic.Location;

import std.conv;


struct SourceID
{
	uint id_;
}


/**
* Represents Code Location
*/
struct Location
{
    /// Offset
    size_t Offset;

    /// Line starts with 0
    uint Line;
 
    /// Column starts with 0
    uint Col; 	
    
    /// Source Id used with SourceManager
    uint SourceId; 
    //what the fuck? why not immutable either const possible 
    // give me stupid error message instead of doing a copy constructor right
    // no documentation yeah
    // nice dmd well implemented -.-

    ///REMOVE Name or File
    string Name;
    
    /**
    * Create Loc
    */
    this(uint id, uint line, uint col)
    {
		SourceId = id;
        Line = line;
        Col = col;
    }
    
    //okay fine show me the syntax of a copy constructor with immutable/const elements
    this(this)
    {
	}
    
    
    /**
    * to String
    */
    public string toString()
    {
        //return here with Line+1 
        //name:line-col
        return cast(string)(Name ~ ":" ~ to!(char[])(Line+1) ~ "-" ~ to!(char[])(Col));
    }
}

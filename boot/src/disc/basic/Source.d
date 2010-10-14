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
module  disc.basic.Source;

import std.stream;
import disc.basic.Location;

/**
* Represents a piece of source
* e.g. File or String
*/
interface Source
{
    /**
    * Get current location
    */
    public Location Loc();

    /**
    * get next char
    */
    public char getChar();

    /**
    * peek next char
    */
    public char peekChar(ubyte n);

    /**
    * reset source
    */
    public void reset();

    public bool isEof();
}


/**
* Represents a source file
*/
class SourceFile : File, Source
{
    /// Current Location
    private Location mLoc;

    /**
    * Ctor
    */
    public this()
    {
        mLoc = Location(0, 0);
    }

    /**
    * Get current location
    */
    public Location Loc()
    {
        return mLoc;
    }

    /**
    * get next char
    */
    public char getChar()
    {
        char c;
        read(c);
        return c;
    }

    /**
    * peek next char
    */
    public char peekChar(ubyte n)
    {
        position = position + (n-1);
        char c;
        read(c);
        position = position - (n);

        return c;
    }

    /**
    * reset source
    */
    public void reset()
    {
        position = 0;
    }

    /**
    * Is end of file
    */
    public bool isEof()
    {
        return readEOF;
    }
}

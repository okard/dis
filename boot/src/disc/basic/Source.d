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

    /**
    * Is eof
    */
    public bool isEof();

    //TODO Slice & Index Operator 
    //char opIndex(int pos);
    //char[] opSlice(int start, int end);
}


/**
* Represents a source file
*/
class SourceFile : File, Source
{
    //TODO Implement a double buffer?

    /// Current Location
    private Location mLoc;

    /// Buffer
    private char[2][20] mBuffer; 

    /// current Buffer
    private ubyte mBufIndex = 0;

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
        
        if(c == '\n')
        {
            mLoc.Line++;
            mLoc.Col = 0;
        }
        else
        {
            mLoc.Col++;
        }
        
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
        mLoc.Col = 0;
        mLoc.Line = 0;
    }

    /**
    * Is end of file
    */
    public bool isEof()
    {
        return eof();
    }
}

/**
* A Source String
*/
class SourceString : Source
{
    /// Current Location
    private Location mLoc;

    /// Source String
    private string mStr;

    /// Position
    private uint mPos;

    /**
    * Ctor
    */
    public this(string str)
    {
        mPos = 0;
        mLoc = Location(0, 0);
        mStr = str;
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
        return mStr[mPos++];
    }

    /**
    * peek next char
    */
    public char peekChar(ubyte n)
    {
        return mStr[mPos+(n-1)];
    }

    /**
    * reset source
    */
    public void reset()
    {
        mPos = 0;
    }

    /**
    * Is eof
    */
    @property
    public bool isEof()
    {
        return mPos == mStr.length;
    }
}

// Test Source String
version(unittest) import io = std.stdio;
unittest
{
    auto ss = new SourceString("abcd efgh ijkl mnop qrst uvwx yz");

    assert(ss.getChar() == 'a');
    assert(ss.getChar() == 'b');
    assert(ss.peekChar(1) == 'c');
    assert(ss.peekChar(6) == 'g');
    assert(ss.getChar() == 'c');
    
    while(!ss.isEof())
        ss.getChar();

    ss.reset();
    assert(ss.getChar() == 'a');


    io.writeln("[TEST] Source Tests passed");
}


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
module dlf.basic.ArgHelper;


/**
* Command Line Argument Helper
*/
class ArgHelper
{
    ///Actual position
    private int pos;
    /// Delegate Alias
    private alias void delegate() dgHandler;

    /// Available Options
    public dgHandler[string] Options;

    /// Save of Arguments
    protected string[] Args;

    /**
    * Parse command line arguments
    */
    public void parse(string[] args)
    {
        Args = args;

        for(pos=0; pos < args.length; pos++)
        {
            auto hnd = (args[pos] in Options);
            
            if(hnd !is null)
                (*hnd)();
            else
               break;

            //add elements not matched to a seperate unparsed list?
        }
    }

    /**
    * Get current Argument
    */
    @property
    protected string Arg()
    {
        return Args[pos];
    }

    /**
    * Current Position
    */
    @property
    protected int Pos()
    {
        return pos;
    }
    
    /**
    * Get next argument as string
    */
    protected string getString()
    {
        return Args[pos++];
    }

    /**
    * Elements left unparsed in Arg Array
    */
    protected uint leftElements()
    {
        return Args.length - pos;
    }
}


// UnitTests ==================================================================

version(unittest) import std.stdio;

unittest
{
    auto arg = ["foo.src", "--enable-a", "-o", "test.o", "foo.src"];


    writeln("[TEST] ArgHelper Tests passed");
}
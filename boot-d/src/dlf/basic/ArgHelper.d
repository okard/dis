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

    ///Unparsed elements
    protected string[] Unparsed;

    ///Disallowed actions
    private string[] Disallowed;

    /**
    * Parse command line arguments
    */
    public void parse(string[] args)
    {
        Args = args;

        //go through the elements
        for(pos=0; pos < args.length; pos++)
        {   
            auto hnd = (args[pos] in Options);
            
            //TODO Option to break parsing
            //look for handler or put it into unparsed
            if(hnd !is null)
                (*hnd)();
            else
               Unparsed ~= args[pos];
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
        return Args[++pos];
    }

    //TODO getNumber
    //TODO getValue(["foo", "bar"]) 

    /**
    * Disable functions
    */
    protected void disallow(string[] args)
    {
        Disallowed ~= args;
    }


    /**
    * Elements left unparsed in Arg Array
    */
    protected uint leftElements()
    {
        return cast(uint)Args.length - pos;
    }
}

// UnitTests ==================================================================

unittest
{
    import std.stdio;

    auto arg = ["foo.src", "--enable-a", "-o", "test.o", "bar.src"];

    class test : ArgHelper
    {
        public bool optA;
        public string outFile;
        
        public this(string args[])
        {
            Options["--enable-a"] = (){ optA=true; };
            Options["-o"] = (){ outFile = getString(); };
            
            parse(args);
        }

        public string[] sourceFiles() { return Unparsed; }
    }

    auto ta = new test(arg);
    assert(ta.optA == true);
    assert(ta.outFile == "test.o");
    assert(ta.sourceFiles() == ["foo.src", "bar.src"]);

    writeln("[TEST] ArgHelper Tests passed");
}
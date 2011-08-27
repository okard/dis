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
module dlf.basic.Signal;

/**
* Signal
*/
struct Signal(T...)
{
    //TODO make thread safe

    //Handle Delegates
    public alias void delegate(T) Dg;
    //Handle Functions
    public alias void function(T) Fn;
    
    //List of delegates
    private Dg[] dgHandler;
    //List of functions
    private Fn[] fnHandler;

    /**
    * Assign Operator += to add delegates
    */
    void opOpAssign(string s)(Dg dg) 
        if (s == "+") 
    {
        //add 
        dgHandler ~= dg;
    }

    /**
    * Assign Operator -= to remove delegates
    */
    void opOpAssign(string s)(Dg dg) 
        if (s == "-") 
    {
        int i = 0;
        
        //remove all dg
        while(true)
        {
            if( i >= dgHandler.length)
                break;

            if(dgHandler[i] == dg)
            {
                //swap with tail and clear tail
                dgHandler[i] = dgHandler[dgHandler.length-1];
                dgHandler.length -= 1;
                continue;
            }

            i++;
        }
    } 

    /**
    * Assign Operator += to add function
    */
    void opOpAssign(string s)(Fn fn) 
        if (s == "+") 
    {
        //add 
        fnHandler ~= fn;
    }

    /**
    * Assign Operator -= to remove function
    */
    void opOpAssign(string s)(Fn fn) 
        if (s == "-") 
    {
        int i = 0;
        
        //remove all fn
        while(true)
        {
            if( i >= fnHandler.length)
                break;

            if(fnHandler[i] == fn)
            {
                //swap with tail and clear tail
                fnHandler[i] = fnHandler[fnHandler.length-1];
                fnHandler.length -= 1;
                continue;
            }

            i++;
        }
    } 

    /**
    * Dispatch Event
    */
    void opCall(T args)
    {
        foreach(Dg d; dgHandler)
            d(args);

        foreach(Fn f; fnHandler)
            f(args);
    }

    /**
    * Clear events
    */
    void clear()
    {
        dgHandler.length = 0;
        fnHandler.length = 0;
    }
}

// UnitTests ==================================================================

unittest
{
    import std.stdio;

    Signal!(int) mySig;
    int foo = 0;
    int bar = 0;

    void setFoo(int x) { foo = x; }
    void setBar(int x) { bar++; }
    mySig += &setFoo;
    mySig += &setFoo;
    mySig += &setBar;
    mySig += &setFoo;
    mySig += &setFoo;
    mySig(5);
    assert(foo == 5);
    assert(bar == 1);
    mySig -= &setFoo;
    mySig(6);
    assert(foo == 5);
    assert(bar == 2);
    mySig -= &setBar;
    mySig(1);
    assert(foo == 5);
    assert(bar == 2);

    writeln("[TEST] Signal Tests passed");
}
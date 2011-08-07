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
module dlf.basic.Log;

import std.string;
import std.datetime;

import dlf.basic.Signal;

/**
* Log Source
*/
enum LogType : ubyte
{
    Verbose = 1,
    Information = 2,
    Warning = 3,
    Error = 4,
    Fatal = 5
}

/**
* Log Source
*/
class LogSource
{
    //Log Event Definition
    public alias Signal!(LogSource, SysTime, LogType, string) LogEvent;
    
    // Log Source Name
    private string mName;

    //Log Event
    private LogEvent evLog;

    /**
    * Create new Log Source
    */
    private this(string name)
    {
        this.mName = name;
    }

    /**
    * Logs a specific Message
    */
    public void log(LogType type, T...)(T args)
    {
        auto str = format(args);
        evLog(this, Clock.currTime(UTC()), type, str);
    }

    /**
    * Logs Information
    */
    public void information(T...)(T args)
    {
       log!(LogType.Information)(args);
    }

    /**
    * Error Logging
    */
    public void error(T...)(T args)
    {
       log!(LogType.Error)(args);
    }

    /**
    * Getting Log event
    */
    @property
    public auto ref OnLog()
    {
        return evLog;
    }

    /**
    * Getting LogSource Name
    */
    @property
    public string Name()
    {
        return mName;
    }

}

final static class Log
{
    //all log sources
    private static LogSource[string] logSources;
    
    //static core log source
    private static LogSource mLog;

    /**
    * Initialize Log
    */
    static this()
    {
        mLog = new LogSource("");
        logSources[""] = mLog;
    }

    /**
    * Get Default Log Source
    */
    static LogSource opCall()
    {
        return mLog;
    }

    /**
    * Get a specific Log Source
    */
    static LogSource opCall(string s)
    {
        auto ls = (s in logSources); 
        if(ls == null)
        {
            auto lss = new LogSource(s);
            ls = &lss;
            (ls.evLog) += &mLog.evLog.opCall;
        }
        return *ls;
    }

    /**
    * Get a specific Log Source
    */
    static LogSource opDispatch(string s)()
    {
        return opCall(s);
    }

}

/**
* Console Log Listener
*/
public void ConsoleListener(LogSource ls, SysTime t, LogType ty, string msg)
{
    string type;
    switch(ty) {
    case LogType.Verbose: type = "Verbose"; break;
    case LogType.Information: type = "Information"; break;
    case LogType.Warning: type = "Warning"; break;
    case LogType.Error: type = "Error"; break;
    case LogType.Fatal: type = "Fatal"; break;
    default: type = "";
    }

    writefln("%1$s %2$s: %3$s", ls.Name, type, msg);
}

/**
* File Log Listener
*/
public LogSource.LogEvent.Dg FileListener(string file)
{
    return (LogSource ls, SysTime t, LogType ty,string msg)
    {
        auto f = File(file, "a");
        f.writefln("%1$s: %2$s", ls.Name, msg);
    };
}

// Unittests
version(unittest) import std.stdio;
unittest
{
    //clear core log after test
    scope(exit) Log().OnLog().clear();

    auto s = Log.Test; 
    s.OnLog += (LogSource ls, SysTime t, LogType ty,string msg){
        assert(ls.Name == "Test");
        assert(msg == "foo");
    };

    s.information("%s", "foo");
    s.log!(LogType.Verbose)("%s", "foo");
    Log().information("%s", "foo"); 

    writeln("[TEST] Log Tests passed");
}
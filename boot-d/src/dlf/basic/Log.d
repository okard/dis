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
    Debug = 2,
    Information = 3,
    Warning = 4,
    Error = 5,
    Fatal = 6
}

/// Log Event Definition
public alias Signal!(LogSource, SysTime, LogType, string) LogEvent;

/**
* Log Source
*/
struct LogSource
{
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
    * Verbose Log
    */
    public void Verbose(T...)(T args)
    {
       log!(LogType.Verbose)(args);
    }
    
    /**
    * Debug Log
    */
    public void Debug(T...)(T args)
    {
       log!(LogType.Debug)(args);
    }

    /**
    * Information Log
    */
    public void Information(T...)(T args)
    {
       log!(LogType.Information)(args);
    }

    /**
    * Warning Log
    */
    public void Warning(T...)(T args)
    {
       log!(LogType.Warning)(args);
    }

    /**
    * Error Log
    */
    public void Error(T...)(T args)
    {
       log!(LogType.Error)(args);
    }

    /**
    * Fatal Log
    */
    public void Fatal(T...)(T args)
    {
       log!(LogType.Fatal)(args);
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
        mLog = LogSource("");
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
        if (__ctfe)
            return LogSource(s);
        else
        {
            //look in log Sources
            auto ls = (s in logSources); 
            if(ls == null)
            {
                logSources[s] = LogSource(s);
                logSources[s].OnLog += &mLog.OnLog.opCall;
                ls = &logSources[s];
            }
           
            return *ls;
        }
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
    import std.stdio;

    string type;
    final switch(ty) {
    case LogType.Verbose: type = "Verbose"; break;
    case LogType.Debug: type = "Debug"; break;
    case LogType.Information: type = "Information"; break;
    case LogType.Warning: type = "Warning"; break;
    case LogType.Error: type = "Error"; break;
    case LogType.Fatal: type = "Fatal"; break;
    }

    writefln("%1$s %2$s: %3$s", ls.Name, type, msg);
}

/**
* File Log Listener
*/
public LogEvent.Dg FileListener(string file, LogType minimal)
{
    import std.stdio;

    auto f = File(file, "a");

    return (LogSource ls, SysTime t, LogType ty,string msg)
    {
        if(ty >= minimal)
            f.writefln("%1$s: %2$s", ls.Name, msg);
    };
}

// UnitTests ==================================================================

unittest
{
    import std.stdio;

    //clear core log after test
    scope(exit) Log().OnLog.clear();

    auto s = Log.Test; 
    s.OnLog += (LogSource ls, SysTime t, LogType ty,string msg){
        assert(ls.Name == "Test");
        assert(msg == "foo");
    };

    s.Information("%s", "foo");
    s.log!(LogType.Verbose)("%s", "foo");
    Log().Information("%s", "foo"); 

    writeln("[TEST] Log Tests passed");
}
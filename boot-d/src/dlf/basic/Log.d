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

/**
* Log Message
*/
struct LogMessage
{
    LogSource source;
    SysTime time;
    LogType type;
    string msg;
}

public alias void delegate(const ref LogMessage) LogEvent;

/**
* Log Source
*/
struct LogSource
{
    // Log Source Name
    private string mName;

    //file

    private LogEvent[] logEvents;

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
        auto time = Clock.currTime(UTC());

        LogMessage msg;
        msg.source = this;
        msg.type = type;
        msg.msg = str;
        msg.time = time;
        fireEvent(msg);
    }

    /**
    * Verbose Log
    */
    public final void Verbose(T...)(T args)
    {
       log!(LogType.Verbose)(args);
    }
    
    /**
    * Debug Log
    */
    public final void Debug(T...)(T args)
    {
       log!(LogType.Debug)(args);
    }

    /**
    * Information Log
    */
    public final void Information(T...)(T args)
    {
       log!(LogType.Information)(args);
    }

    /**
    * Warning Log
    */
    public final void Warning(T...)(T args)
    {
       log!(LogType.Warning)(args);
    }

    /**
    * Error Log
    */
    public final void Error(T...)(T args)
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
    * Add Handler
    */
    public void addHandler(LogEvent ev)
    {
        logEvents ~= ev;
    }

    /**
    * Clear event handler
    */
    public void clearHandler()
    {
        logEvents.length = 0;
    }

    /**
    * Assign fire Event
    */
    private void fireEvent(const ref LogMessage msg)
    {
        foreach(e;logEvents)
            e(msg);
    }

    /**
    * Getting LogSource Name
    */
    @property
    public string Name() const
    {
        return mName;
    }

}

/**
* Log
*/
final static class Log
{
    //all log sources
    private static LogSource[string] logSources;
    
    //static core log source
    private static LogSource rootLog;

    public alias rootLog this;

    /**
    * Initialize Log
    */
    static this()
    {
        rootLog = LogSource("");
        logSources[""] = rootLog;
    }

    /**
    * Get Default Log Source
    */
    static LogSource opCall()
    {
        return rootLog;
    }

    /**
    * Get a specific Log Source
    */
    static LogSource opCall(string s, bool register = true)
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
                if(register)
                {
                    logSources[s].addHandler(&rootLog.fireEvent);
                }

                ls = &logSources[s];
            }
           
            return *ls;
        }
    }

    /**
    * Get a specific Log Source
    */
    @property
    static LogSource opDispatch(string s)()
    {
        return opCall(s);
    }
}

/**
* Console Log Listener
*/
public void ConsoleListener(const ref LogMessage msg)
{
    import std.stdio;

    string type;
    final switch(msg.type) {
    case LogType.Verbose: type = "Verbose"; break;
    case LogType.Debug: type = "Debug"; break;
    case LogType.Information: type = "Information"; break;
    case LogType.Warning: type = "Warning"; break;
    case LogType.Error: type = "Error"; break;
    case LogType.Fatal: type = "Fatal"; break;
    }

    writefln("%1$s %2$s: %3$s", msg.source.Name, type, msg.msg);
}

/**
* File Log Listener
*/
public LogEvent FileListener(string file, LogType minimal)
{
    import std.stdio;

    auto f = File(file, "a");

    return (const ref LogMessage msg)
    {
        if(msg.type >= minimal)
            f.writefln("%1$s: %2$s", msg.source.Name, msg.msg);
    };
}

// UnitTests ==================================================================

unittest
{
    import std.stdio;

    //clear core log after test
    scope(exit) Log().clearHandler();

    auto s = Log.Test; 
    s.addHandler((const ref LogMessage msg){
        assert(msg.source.Name == "Test");
        assert(msg.msg == "foo");
    });


    s.Information("%s", "foo");
    s.log!(LogType.Verbose)("%s", "foo");
    Log().Information("%s", "foo"); 

    writeln("[TEST] Log Tests passed");
}
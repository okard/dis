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
module disc.basic.Log;

import std.string;
import std.date;

import disc.basic.Signal;

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

class LogSource
{
    private alias Signal!(LogSource, d_time, LogType, string) LogEvent;
    private string name;

    private LogEvent  evLog;

    private this(string name)
    {
        this.name = name;
    }

    public void log(LogType type, T...)(T args)
    {
        auto str = format(args);
        evLog(this, getUTCtime(), type, str);
    }

    public void log(T...)(T args)
    {
       log!(LogType.Information)(args);
    }

    @property
    public auto ref OnLog()
    {
        return evLog;
    }

}

class Log
{
    private static LogSource[string] logSources;
    private static LogSource mLog;

    static this()
    {
        mLog = new LogSource("");
        logSources[""] = mLog;
    }

    static LogSource opCall()
    {
        return mLog;
    }

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

    static LogSource opDispatch(string s)()
    {
        return opCall(s);
    }

}


version(unittest) import std.stdio;
unittest
{
   auto s = Log.Test;
   s.OnLog() += (LogSource ls,d_time t, LogType ty,string msg){
        writeln(msg);
   };

   s.log("%s", "foo");
   s.log!(LogType.Verbose)("%s", "foo");
   Log().log("%s", "foo"); 
}
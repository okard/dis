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
module dlf.gen.c.CBuilder;

import std.array;
import std.path;
import std.process;
import std.stdio;

import dlf.gen.CodeGen;

/**
* C Code Builder
*/
struct CBuilder
{
    /// Compiler Flags
    private static string compilerExec = "gcc";
    private static string[] compilerFlags = ["-fPIC", "-c", "-std=c99", "-Wall", "-g" ];

    /// Linker
    private static string linkerExec = "gcc";
    private static string[] linkerFlags = ["-lc"];
    private static string linkRuntime = "-ldisrt";
    private static string linkShared = "-shared";

    //static lib: ar rcs libname.a obj0.o obj1.o

    private static string[] objfiles;

    /**
    * Build Source Files
    */
    void compile(Context ctx, string[] sources)
    {
        //make last change date available

        //compile source file
        //TODO this can be threaded
        foreach(string src; sources)
        {
            string[] args;
            args ~= compilerExec;
            args ~= compilerFlags;
            string objfile = buildPath(ctx.ObjDir, setExtension(baseName(src), ".o"));
            args ~= ["-o", objfile] ;
            args ~= src;

            //d1 tango has process handling, d2 phobos has nothing .....

            exec(args);

            objfiles ~= objfile;
        }  
    }

    /**
    * linking
    */
    static void link(Context ctx)
    {
        final switch(ctx.Type)
        {
            case TargetType.StaticLib: 
                assert(false, "Not yet implemented");

            case TargetType.SharedLib: 
                string[] args;
                args ~= linkerExec;
                args ~= linkerFlags;
                if(ctx.EnableRuntime) args ~= linkRuntime;
                args ~= ["-o", ctx.OutFile];
                args ~= ["-L", ctx.OutDir];
                args ~= linkShared;
                args ~= objfiles;
                exec(args);
                break;

            case TargetType.Executable: 
                string[] args;
                args ~= linkerExec;
                args ~= linkerFlags;
                if(ctx.EnableRuntime) args ~= linkRuntime;
                args ~= ["-o", ctx.OutFile];
                args ~= ["-L", ctx.OutDir];
                args ~= objfiles;
                exec(args);
                break;
        }
    }


    /**
    * Execute command
    */
    static void exec(string[] args)
    {
        string command = join(args, " ");
        writeln(command);
        
        int result = system(command);
        if(result != 0)
            throw new Exception("Execute Command Failed");
    }


}
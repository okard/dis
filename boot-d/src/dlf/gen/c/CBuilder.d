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

    /**
    * Build Source Files
    */
    void build(Context ctx, string[] sources)
    {
        //make last change date available

        //first step compile all source files to obj files
        
        //second step link all o files together
        //look for ctx.EnableRuntime

        final switch(ctx.Type)
        {
            case TargetType.StaticLib: break;
            case TargetType.SharedLib: break;
            case TargetType.Executable: break;
        }
    }


}
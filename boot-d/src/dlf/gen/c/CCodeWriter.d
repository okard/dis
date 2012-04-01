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
module dlf.gen.c.CCodeWriter;

import std.stdio;
import std.array;
import std.file;
import std.path;

import dlf.basic.Location;

/**
* ANSI C Code Writer
*/
struct CCodeWriter
{
    //Scopes of current writing
    enum CScope
    {
        Global,
        StructDecl,
        FuncDecl
    }


    //TODO Parameter for creation?
    //TODO Clean up splitting writer functions (Source/Header)

    /// Source Directory
    private string sourceDirectory;

    /// Package List
    private CPackage[] packages;

    /**
    * A Package
    */
    public class CPackage
    {
        /// Header File
        public File Header;

        ///Internal Header?
        
        /// Source File
        public File Source;

        /**
        * Private Ctor
        */
        private this()
        {
        }

        /**
        * Start a package
        */
        public void start(string guard)
        {
            Header.writeln("/* generated by dis bootstrap compiler */");
            Source.writeln("/* generated by dis bootstrap compiler */");
            //write include guards
            Header.writefln("#pragma once");
            Header.writefln("#ifndef %s", guard);
            Header.writefln("#define %s", guard);
        }

        /**
        * Close Package
        */
        public void close()
        {
            //end include guards
            Header.writeln("#endif");
        }

        /**
        *  Write Include to Header File
        */
        public void include(string filename)
        {
            //check state for writing include
            Header.writefln("#include \"%s\"", filename);
        }

        /**
        * Write a comment
        */
        public void comment(string cmt)
        {
            //disable in release code gen?
            Header.writefln("/* %s */", cmt);
            Source.writefln("/* %s */", cmt);
        }

        /**
        * Write Debug C Preprocessor Line
        */
        public void debugln(Location loc)
        {
            //TODO Check complete path
            //Header or Source? or Both
            Header.writefln("#line %d  \"%s\"", loc.Line, loc.Name);
            Source.writefln("#line %d  \"%s\"", loc.Line, loc.Name);
        }

        /**
        * Write Function Declaration
        */
        public void funcDecl(string rettype, string name, string[] param)
        {
            Header.writef("%s %s(%s", rettype, name, param.length <= 0 ? "" : param[0]);
             for(int i=1; i < param.length; i++)
                Header.writef(", %s", param[i]);
            Header.writeln(");");
        }

        /**
        * Define Function
        */
        public void funcDef(string rettype, string name, string[] param)
        {
            Source.writef("%s %s(%s", rettype, name, param.length <= 0 ? "" : param[0]);
            for(int i=1; i < param.length; i++)
                Source.writef(", %s", param[i]);
            Source.writeln(")");
            
        }

        /**
        * Start block in source
        */
        public void blockStart()
        {
            Source.writeln("{");
        }

        /**
        * End block in source
        */
        public void blockEnd()
        {
            Source.writeln("}");
        }

        //startBlock 
        

        //glovalVariable
        //BlockVariable

        //state 
        //create variable

        //Create function declaration
        //Create struct declaration 

        //where?
        //openBlock
        //closeBlock

        //openStruct
        //addField()
        //closeStruct

        //buffer for other declaration if at the moment is one opened
        //so it can be appended when possible
        //add temp headers?
        //private writebfln() Write both

        /**
        * Get Header File Name
        */
        @property
        public string HeaderFile()
        {
            return Header.name();
        }

        /**
        * Get Source File name
        */
        @property
        public string SourceFile()
        {
            return Source.name();
        }
    }


    //internal classes for functions and structs
  
    //Options? BOTH, HEADER, SOURCE 
    
    CPackage Package(string name)
    {
        assert(sourceDirectory.isDir(), "No valid directory for writing source files");

        auto pack = new CPackage();
        packages ~= pack;

        //TODO std.path does not work with dots in name
        pack.Header = File(buildPath(this.SourceDirectory, setExtension(name.replace(".", "_"),".h")), "w");
        pack.Source = File(buildPath(this.SourceDirectory, setExtension(name.replace(".", "_"),".c")), "w");
        return pack;
    }


    /**
    * Set Source Directory
    */
    @property
    void SourceDirectory(string dir)
    {
        assert(dir.isDir(), "Directory for writing source files isn't a directory");
        sourceDirectory = dir;
    }

    
    /**
    * Get Source Directory
    */
    @property
    string SourceDirectory()
    {
        return sourceDirectory;
    }


    /**
    * Get all c source files
    */
    string[] getCSources()
    {
        string[] srcs = new string[packages.length];
        
        for(int i=0; i < packages.length; i++)
            srcs[i] = packages[i].Source.name;

        return srcs;
    }

}
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
module disc; 

import std.stdio;
import std.datetime;

import dlf.basic.Log;
import dlf.basic.Source;
import dlf.basic.ArgHelper;
import dlf.basic.Util;

import dlf.ast.Printer;
import dlf.ast.Node;
import dlf.ast.Declaration;
import dlf.dis.Token;
import dlf.dis.Lexer;

import dlf.dis.Parser;

import dlf.sem.Semantic;

import dlf.Context;
import dlf.gen.CodeGen;
import dlf.gen.c.CCodeGen;


/**
* Helper Class for CommandLine Arguments
*/
class CommandLineArg : ArgHelper
{
    //option
    public bool printToken;             //print lexer tokens
    public bool printAst;               //print ast
    public bool printSem;               //print Semantic Log
    public bool verboseLogging;         //verbose output
    
    public bool compileOnly = false;    //do not link, compile only
    public bool noRuntime = false;      //no runtime

    public string outFile;   //output name
    

    public TargetType targType = TargetType.Executable;
    //compile context

    //LogLevel

    //prepare
    public this(string[] args)
    {
        //prepare options
        Options["--print-lex"] = (){ printToken = true; };
        Options["--print-ast"] = (){ printAst = true; };
        Options["--print-sem"] = (){ printSem = true; };
        Options["--verbose"] = (){ verboseLogging = true; };
        Options["-c"] = (){ compileOnly = true; };
        Options["--no-runtime"] = (){ noRuntime = true; };
        Options["-sharedlib"] = (){targType = TargetType.SharedLib; disallow(["-staticlib"]);};
        Options["-staticlib"] = (){targType = TargetType.StaticLib; disallow(["-sharedlib"]);};
        Options["-o"] = (){ outFile = getString(); };

        //obj directory ".objdis"
        //log level
        //import dirs -> "%apppath%/../lib"

        //parse Options
        parse(args);
    }

    /**
    * Get source files 
    */
    public string[] getSourceFiles()
    {
        return Unparsed;
    }
}

/**
* Compiler Class
*/
class DisCompiler
{
    /// Command Line Parser
    private CommandLineArg args;
    
    /// Log Source
    private LogSource log;

    /// Compile Context
    private Context ctx;

    /// Store parsed packages package name or file
    private PackageDeclaration[string] packages;

    //Object File for Package

    private struct Pkg
    {
        SourceFile file;
        PackageDeclaration ast; 
    }

    /**
    * Ctor
    */
    this(string[] args)
    {
        this.args = new CommandLineArg(args);
        this.log =  Log.disc;
        this.log.OnLog += LevelConsoleListener(LogType.Information);


        //TODO config and command line parsing

        //default args
        ctx = new Context();
        ctx.EnableRuntime = !this.args.noRuntime;
        ctx.Backend.ObjDir = ".objdis";
        ctx.Backend.OutDir = "bin";
        ctx.Backend.OutFile = empty(this.args.outFile) ? ctx.Backend.OutDir ~"/unkown" : this.args.outFile;
        ctx.Backend.HeaderDir = "bin/header";
        
        ctx.Type = this.args.targType;

        version(X86) ctx.Arch = TargetArch.x86_32; 
        version(X86_64) ctx.Arch = TargetArch.x86_64;
        version(Windows) ctx.Platform = TargetPlatform.Windows;
        version(linux) ctx.Platform = TargetPlatform.Linux;      
    }

    /**
    * Compile source files
    */
    int compile()
    {
        log.Information("Dis Compiler V0.01");
        
        auto srcFiles = args.getSourceFiles();

        //no files?
        if(srcFiles.length < 1)
        {
            log.Error("No Source Files");
            //print usage
            return 1;
        }

        auto parser = new Parser();
        auto semantic = new Semantic();
        auto cgen = new CCodeGen(ctx);
            
        //logging
        auto logfunc = LevelConsoleListener(LogType.Information);
        parser.OnLog += logfunc;
        semantic.OnLog += logfunc;
        cgen.OnLog += logfunc;

        log.Information("Parsing...");
        //create packages and parse them
        auto pkgs = new Pkg[srcFiles.length];
        for(int i=0;i < pkgs.length; i++)
        {
            pkgs[i].file = new SourceFile();
            pkgs[i].file.open(srcFiles[i]);
            
            parser.load(pkgs[i].file);
            pkgs[i].ast = parser.parsePackage(); 
            assert(pkgs[i].ast !is null, "Parsing a Source file should result in a package");
        }

        //handle imports
        log.Information("Resolve imports...");
        foreach(Pkg p; pkgs)
        {
            handleImports(p.ast);
        }

        //semantic
        log.Information("Semantic...");
        foreach(Pkg p; pkgs)
        {
            p.ast = semantic.run(p.ast);
            assert(p.ast !is null, "Semantic analyse on a package should have a valid result");
        }

        //codegen
        log.Information("CodeGen...");
        foreach(Pkg p; pkgs)
        {
            cgen.compile(p.ast);
            packages[p.ast.Name] = p.ast;
        }

        log.Information("Linking Program ...");

        //add a share so it can create multiple instances
        //compile can be earlier but linking not
        //compile and link
        CCodeGen.link(ctx);

        return 0;
    }

    /**
    * Debug Function that dumps out lexer output
    */
    private void dumpLexer(Source src)
    {
        //create lexer
        auto lex = new Lexer();
        lex.Src = src;
        
        //print tokens
        writeln("------- START LEXER DUMP ------------------------------");
        while(lex.getToken().Type != TokenType.EOF)
        {
            auto t = lex.CurrentToken;
            switch(t.Type)
            {
                case TokenType.Identifier: writefln("Identifier: %1$s", t.Value); break;
                case TokenType.String: writefln("String: %1$s", t.Value); break;
                default: writeln(t.toString());
            }   
        }
        writeln("------- END LEXER DUMP ------------------------------");

        //reset source
        src.reset();
    }

    /**
    * dump parser
    */
    private void dumpParser(PackageDeclaration pd)
    {
        //Print out
        auto printer = new Printer();
        writeln("------- START PARSER DUMP ----------------------------");
        printer.print(pd);
        writeln("------- END PARSER DUMP ------------------------------");
    }

    /**
    * Handle Imports
    */
    private void handleImports(PackageDeclaration pack)
    {
        //TODO paths as parameter
        //TODO handle import foo.* (this modifies the ast)
        //Look for Import Files
        foreach(imp; pack.Imports)
        {
            //TODO logging
            // look into packages
            // look into other sources if one matches this package

            // Search File
            // Parse File
            // Run Semantic 
            // add to imp.Package 
        }
    }
    
    /**
    * Level Console Log Listener
    */
    public LogEvent.Dg LevelConsoleListener(LogType minimal)
    {
        return (LogSource ls, SysTime t, LogType ty, string msg)
        {
            if(ty >= minimal)
                writefln("%s", msg);
        };
    }

}

/**
* Main
*/
int main(string[] args)
{
    //cut executable name out of args
    auto disc = new DisCompiler(args[1..args.length]);

    //TODO Read Configuration (std.file.isfile(path))
    //Linux:    bindir, ~/.disc, /etc/disc
    //Windows:  bindir, %APPDATA%/disc.conf %ALLUSERSPROFILE%/Application Data


    return disc.compile();
}

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
import dlf.ast.Printer;
import dlf.ast.Node;
import dlf.ast.Declaration;
import dlf.dis.Token;
import dlf.dis.Lexer;
import dlf.dis.Parser;
import dlf.sem.Semantic;
import dlf.gen.CodeGen;
import dlf.gen.c.CCodeGen;


/**
* Helper Class for CommandLine Arguments
*/
class CommandLineArg : ArgHelper
{
    //option
    public bool printToken;  //print lexer tokens
    public bool printAst;    //print ast
    public bool printSem;    //print Semantic Log

    public TargetType targType = TargetType.Executable;
    //compile context

    //prepare
    public this(string[] args)
    {
        //prepare options
        Options["--print-lex"] = (){ printToken = true; };
        Options["--print-ast"] = (){ printAst = true; };
        Options["--print-sem"] = (){ printSem = true; };
        Options["-sharedlib"] = (){targType = TargetType.SharedLib; disallow(["-staticlib"]);};
        Options["-staticlib"] = (){targType = TargetType.StaticLib; disallow(["-sharedlib"]);};

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

    /**
    * Ctor
    */
    this(string[] args)
    {
        this.log =  Log.disc;
        this.log.OnLog += LevelConsoleListener(LogType.Information);
        this.args = new CommandLineArg(args);

        //TODO config and command line parsing

        //default args
        ctx.ObjDir = ".objdis";
        ctx.OutDir = "bin";
        ctx.HeaderDir = "bin/header";
        
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

        //Compile each source file
        foreach(string srcfile; srcFiles)
        {
            log.Information("Compile %s", srcfile);

            //Open Source
            auto src = new SourceFile();
            src.open(srcfile);

            //print token
            if(args.printToken)
                dumpLexer(src);

            //TODO try-catch

            //compile file
            compile(src);
        }

        return 0;
    }


    /**
    * Compile on source file
    */
    private void compile(Source src)
    {
        //Parser
        auto parser = new Parser();
        parser.Src = src;

        //parse
        auto pack = cast(PackageDeclaration)parser.parse();

        //A new Source File have to result in a PackageNode
        assert(pack !is null);

        if(args.printAst)
            dumpParser(pack);

        //Parse Imports
        handleImports(pack);

        //prepare code before semantic
        //add default version flags and so on

        //run semantics
        auto semantic = new Semantic();
        pack = cast(PackageDeclaration)semantic.run(pack);

        //succesful semantic run result in a package declaration
        assert(pack !is null);

        //compile package
        auto cgen = new CCodeGen(ctx);
        cgen.compile(pack);
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
            if(t.Type == TokenType.Identifier)
                writefln("Identifier: %1$s", t.Value);
            else if (t.Type == TokenType.String)
                writefln("String: %1$s", t.Value);
            else
                writeln(dlf.dis.Token.toString(t.Type));
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
            // Search File
            // Parse File
            // Run Semantic 
            // add to imp.Package 
        }
    }
    
    /**
    * Level Console Log Listener
    */
    public LogSource.LogEvent.Dg LevelConsoleListener(LogType minimal)
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

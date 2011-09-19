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
    public bool verboseLogging;
    
    public bool noRuntime = false;   //no runtime
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
        ctx.EnableRuntime = !this.args.noRuntime;
        ctx.ObjDir = ".objdis";
        ctx.OutDir = "bin";
        ctx.OutFile = empty(this.args.outFile) ? ctx.OutDir ~"/unkown" : this.args.outFile;
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

        //first parse each file
        //than run semantic on each file
        //than run code gen

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
            //TODO compile step per package threaded? prepare worker threads, queue handling sort imports
            
            //share codegen link after all file getting compiled

            //compile file
            if(!compile(src))
            {
                log.Error("Failed to compile file: " ~ src.name);
                //return 2;
            }

            log.Information("");
        }

        log.Information("Linking Program ...");

        //add a share so it can create multiple instances
        //compile can be earlier but linking not
        //compile and link
        CCodeGen.link(ctx);

        return 0;
    }


    /**
    * Compile on source file
    */
    private bool compile(Source src)
    {
        try
        {
            auto parser = new Parser();
            auto semantic = new Semantic();
            auto cgen = new CCodeGen(ctx);
            
            //log ahndling?
            auto logfunc = LevelConsoleListener(LogType.Information);
            parser.OnLog += logfunc;
            semantic.OnLog += logfunc;
            cgen.OnLog += logfunc;

            //Parser
            log.Information("Parsing ...");
            parser.load(src);
            auto pack = parser.parsePackage();  //parser.parsePackage();
            
            //A new Source File have to result in a PackageNode
            assert(pack !is null, "Parser doesn't return a package declaration");

            if(args.printAst)
                dumpParser(pack);

            //Parse Imports
            handleImports(pack);

            //prepare code before semantic
            //add default version flags and so on

            //run semantics
            log.Information("Semantic ...");
            //semantic file logger for debugging?
            pack = semantic.run(pack);

            //succesful semantic run result in a package declaration
            assert(pack !is null, "Semantic doesn't return a package declaration");

            log.Information("CodeGen ...");
            
            //compile package
            cgen.compile(pack);

            packages[pack.Name] = pack;

            return true;
        }
        catch(Parser.ParserException exc)
        {
            log.Error(exc);
            return false;
        }
        catch(Semantic.SemanticException exc)
        {
            log.Error(exc);
            return false;
        }
        //catch(CodeGenException)
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

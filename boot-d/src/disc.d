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

    //prepare
    public this(string[] args)
    {
        //prepare options
        Options["--print-lex"] = (){ printToken = true; };
        Options["--print-ast"] = (){ printAst = true; };
        Options["--print-sem"] = (){ printSem = true; };

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
* Main
*/
int main(string[] args)
{
    auto log = Log("disc");

    log.OnLog += LevelConsoleListener(LogType.Information);
    log.information("Dis Compiler V0.01");


    //TODO Read Configuration (std.file.isfile(path))
    //Linux:    bindir, ~/.disc, /etc/disc
    //Windows:  bindir, %APPDATA%/disc.conf %ALLUSERSPROFILE%/Application Data

    //parse arguments
    auto arguments = new CommandLineArg(args);
    auto srcFiles = arguments.getSourceFiles();


    if(srcFiles.length < 1)
    {
        log.error("No Source Files");
        return 1;
    }

    //Open Source
    auto src = new SourceFile();
    src.open(srcFiles[1]);

    //print token
    if(arguments.printToken)
    {
        auto lex = new Lexer();
        lex.Src = src;
        dumpLexer(lex);
        src.reset();
        writeln("------- END LEXER DUMP ------------------------------");
    }
   
    //Parser
    auto parser = new Parser();
    parser.Src = src;
    auto node = cast(PackageDeclaration)parser.parse();

    //A new Source File have to result in a PackageNode
    assert(node !is null);

    //Parse Imports
    handleImports(node);

    //Print out
    auto printer = new Printer();
    writeln("------- START PARSER DUMP ----------------------------");
    printer.print(node);
    writeln("------- END PARSER DUMP ------------------------------");

    //run semantics
    auto semantic = new Semantic();
    auto ast = semantic.run(node);
    writeln("------- END SEMANTIC ------------------------------");

    //C CodeGen
    auto cgen = new CCodeGen();
    


    return 0;
}


/**
* Handle Imports
*/
private void handleImports(PackageDeclaration pack)
{
    //TODO paths as parameter
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
* Debug Function that dumps out lexer output
*/
private void dumpLexer(Lexer lex)
{
    while(lex.getToken().Type != TokenType.EOF)
    {
        auto t = lex.CurrentToken;
        if(t.Type == TokenType.Identifier)
            writefln("Identifier: %1$s", t.Value);
        else if (t.Type == TokenType.String)
            writefln("String: %1$s", t.Value);
        else
            writeln(toString(t.Type));
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
            writefln(ls.Name == "" ? "%s%s" : "%s: %s" , ls.Name, msg);
    };
}
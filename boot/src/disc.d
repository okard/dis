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
import date = std.date;

import dlf.basic.Log;
import dlf.basic.Source;
import dlf.basic.ArgHelper;
import dlf.ast.Printer;
import dlf.dis.Token;
import dlf.dis.Lexer;
import dlf.dis.Parser;
import dlf.gen.Semantic;
import dlf.gen.llvm.Compiler;


/**
* Helper Class for CommandLine Arguments
*/
class CommandLineArg : ArgHelper
{
    //option
    public bool printToken;  //print lexer tokens
    public bool printAst;    //print ast

    //prepare
    public this(string[] args)
    {
        //prepare options
        Options["--lex"] = (){ printToken = true; };
        Options["--print-ast"] = (){ printAst = true; };

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
    Log().OnLog() += LevelConsoleListener(LogType.Information);

    Log().information("Dis Compiler V0.01");

    //parse arguments
    auto arguments = new CommandLineArg(args);
    auto srcFiles = arguments.getSourceFiles();

    if(srcFiles.length < 1)
    {
        writeln("No Source Files");
        return 1;
    }

    //Open Source
    auto src = new SourceFile();
    src.open(srcFiles[1]);

    //print token
    if(arguments.printToken)
    {
        auto lex = new Lexer();
        lex.source = src;
        dumpLexer(lex);
        src.reset();
        writeln("------- END LEXER DUMP ------------------------------");
    }
   
    //Parser
    auto parser = new Parser();
    parser.source = src;
    parser.parse();

    //Print out
    auto printer = new Printer();
    printer.print(parser.ParseTree());
    writeln("------- END PARSER DUMP ------------------------------");

    //run semantics
    auto semantic = new Semantic();
    auto ast = semantic.run(parser.ParseTree());
    writeln("------- END SEMANTIC ------------------------------");

    //Compiler
    auto compiler = new Compiler();
    compiler.compile(ast);

    return 0;
}

/**
* Debug Function that dumps out lexer output
*/
private void dumpLexer(Lexer lex)
{
    while(lex.getToken().type != TokenType.EOF)
    {
        auto t = lex.currentToken;
        if(t.type == TokenType.Identifier)
            writefln("Identifier: %1$s", t.value);
        else if (t.type == TokenType.String)
            writefln("String: %1$s", t.value);
        else
            writeln(toString(t.type));
    }
}


/**
* Level Console Log Listener
*/
public LogSource.LogEvent.Dg LevelConsoleListener(LogType minimal)
{
    return (LogSource ls, date.d_time t, LogType ty, string msg)
    {
        if(ty >= minimal)
            writefln(ls.Name == "" ? "%s%s" : "%s: %s" , ls.Name, msg);
    };
}
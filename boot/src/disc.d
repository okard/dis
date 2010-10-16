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
module discompiler; 

import std.stdio;

import disc.basic.Source;
import disc.dis.Token;
import disc.dis.Lexer;
import disc.dis.Parser;

/**
* Main
*/
int main(string[] args)
{
    writeln("Dis Compiler V0.01");

    if(args.length < 2)
    {
        writeln("No Source File");
        return 1;
    }

    //Open Source
    auto src = new SourceFile();
    src.open(args[1]);

    auto lex = new Lexer();
    lex.source = src;
    //dumpLexer(lex);

    //Parser
    auto parser = new Parser();
    parser.source = src;
    parser.parse();

    return 0;
}

/**
* Debug Function that dumps out lexer output
*/
private void dumpLexer(Lexer lex)
{
    while(lex.getToken().tok != Token.EOF)
    {
        auto t = lex.currentToken;
        if(t.tok == Token.Identifier)
            writefln("Identifier: %1$s", t.val.Identifier);
        else if (t.tok == Token.String)
            writefln("String: %1$s", t.val.String);
        else
            writeln(toString(t.tok));
    }
}
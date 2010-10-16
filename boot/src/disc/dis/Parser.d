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
module disc.dis.Parser;

import disc.basic.Location;
import disc.basic.Source;
import disc.dis.Token;
import disc.dis.Lexer;

import disc.ast.Node;
import disc.ast.Declaration;

//debug
import std.stdio;

/**
* Dis Parser
*/
class Parser
{
    ///Lexer
    private Lexer lex;
    ///Token
    private Lexer.TokenEntry mToken;
    ///AST Root Node
    private Node mAstRoot;
    ///AST Current Node
    private Node mAstCurrent;

    /**
    * Ctor
    */
    public this()
    {
        lex = new Lexer();
    }
    
    /**
    * Parse current Source File
    */
    public void parse()
    {
        mToken = lex.getToken();
        
        while(mToken.tok != Token.EOF)
        {
            switch(mToken.tok)
            {
            case Token.KwPackage: parsePackage(); break;
            case Token.KwDef: parseDef(); break;
            default:
            }

            mToken = lex.getToken();
        }
    }

    /**
    * Parse package
    */
    private void parsePackage()
    {
        writeln("parsePackage");

        //package identifier;
        assert(mToken.tok == Token.KwPackage);
        
        mToken = lex.getToken();
        
        if(mToken.tok != Token.Identifier)
            error(mToken.loc, "Expected Identifier after package");
        
        //Create new Package Declaration
        writefln("Package: %1$s", mToken.val.Identifier);
        auto pkg = new PackageDeclaration(cast(string)mToken.val.Identifier);

        //Look for semicolon or end of line
        mToken = lex.getToken();
        if(mToken.tok != Token.EOL && mToken.tok != Token.Semicolon)
            error(mToken.loc, "Expected EOL or Semicolon");
    }

    /**
    * Parse Method Definitions
    */
    private void parseDef()
    {
        writeln("parseDef");

        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        assert(mToken.tok == Token.KwDef);

        mToken = lex.getToken();
        
        //Parse Calling Convention
        if(mToken.tok == Token.ROBracket)
        {
            //identifier aka calling convention
            mToken = lex.getToken();
            if(mToken.tok != Token.Identifier)
                error(mToken.loc, "parseDef: Expected Identifier for Calling Convention");
            
            //debug output
            writefln("Calling Convention: %1$s", mToken.val.Identifier);
            
            //close )
            mToken = lex.getToken();
            if(mToken.tok != Token.RCBracket)
                error(mToken.loc, "parseDef: Expected )");

            mToken = lex.getToken();
        }
        
        //parse function name (identifier)
        if(mToken.tok != Token.Identifier)
            error(mToken.loc, "parseDef: expected identifier");
        
        //Debug Output
        writefln("Function: %1$s", mToken.val.Identifier);

        //expected (params) return type {
        mToken = lex.getToken();
        if(mToken.tok != Token.ROBracket)
        {
            error(mToken.loc, "parseDef: expected (");
            return;
        }
        
        //identfier{:} type, ...
        while(mToken.tok != Token.RCBracket)
        {
            mToken = lex.getToken();
            if(mToken.tok == Token.Identifier)
                parseParam();
            //varargs?
        }
        
        
    }

    /**
    * Parse Defintion
    */
    private void parseParam()
    {
        writeln("parseParam");
        // identifier [:] type{*}
        assert(mToken.tok == Token.Identifier);
    
        writefln("ParamName: %1$s", mToken.val.Identifier);

        mToken= lex.getToken();
        if(mToken.tok == Token.Colon)
            mToken = lex.getToken();

        if(mToken.tok != Token.Identifier)
            error(mToken.loc, "parseParam: Expected Type Identifier");

        writefln("Type: %1$s", mToken.val.Identifier);
                 
    }

    /**
    * Parse Statement
    */
    private void parseStatement()
    {
        //CallStatement
    }

    /**
    * Error Event
    */
    private void error(Location loc, string msg)
    {
        //TODO: Make error events, remove stupid writeln
        writeln("(" ~ mToken.loc.toString() ~ ") " ~ msg);
    }

    /**
    * Set Source file for Lexer
    */
    public void source(Source src)
    {
        lex.source = src;
    }
} 

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
import disc.ast.Type;
import disc.ast.Declaration;
import disc.ast.Statement;
import disc.ast.Expression;
import disc.ast.Printer;

//debug
import std.stdio;

/**
* Dis Parser
*/
class Parser
{
    ///Lexer
    private Lexer mLex;
    ///Token
    private Lexer.TokenEntry mToken;
    ///AST Root Node
    private Node mAstRoot;
    ///AST Current Node
    private Node mAstCurrent;
    ///AST Printer
    private Printer mAstPrinter;

    /**
    * Ctor
    */
    public this()
    {
        mLex = new Lexer();
        mAstPrinter = new Printer();
    }
    
    /**
    * Parse current Source File
    */
    public void parse()
    {
        mToken = mLex.getToken();
        
        while(mToken.tok != Token.EOF)
        {
            switch(mToken.tok)
            {
            case Token.KwPackage: parsePackage(); break;
            case Token.KwDef: parseDef(); break;
            default:
            }

            mToken = mLex.getToken();
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
        
        mToken = mLex.getToken();
        
        if(mToken.tok != Token.Identifier)
            error(mToken.loc, "Expected Identifier after package");
        
        //Create new Package Declaration
        auto pkg = new PackageDeclaration(cast(string)mToken.val.Identifier);

        //Look for semicolon or end of line
        mToken = mLex.getToken();
        if(mToken.tok != Token.EOL && mToken.tok != Token.Semicolon)
            error(mToken.loc, "Expected EOL or Semicolon");

        mAstPrinter.print(pkg);
    }

    /**
    * Parse Method Definitions
    */
    private void parseDef()
    {
        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        assert(mToken.tok == Token.KwDef);

        auto func = new FunctionDeclaration();
        mToken = mLex.getToken();
        
        //Parse Calling Convention
        if(mToken.tok == Token.ROBracket)
        {
            //identifier aka calling convention
            if(!expect(mToken,Token.Identifier))
                error(mToken.loc, "parseDef: Expected Identifier for Calling Convention");
            
            switch(mToken.val.Identifier)
            {
            case "C": func.mType.mCallingConv = FunctionType.CallingConvention.C; break;
            case "Dis": func.mType.mCallingConv = FunctionType.CallingConvention.Dis;break;
            default: error(mToken.loc, "Invalid CallingConvention");
            }
            
            //close )
            if(!expect(mToken, Token.RCBracket))
                error(mToken.loc, "parseDef: Expected )");

            mToken = mLex.getToken();
        }
        
        //parse function name (identifier)
        if(mToken.tok != Token.Identifier)
        {
            error(mToken.loc, "parseDef: expected identifier");
            return;
        }
        
        func.mName = cast(string)mToken.val.Identifier;

        //expected (params) return type {
        if(!expect(mToken, Token.ROBracket))
        {
            error(mToken.loc, "parseDef: expected (");
            return;
        }

        //parse parameters
        parseDefParams(func);

        //after parsing parameters expects )
        if(mToken.tok != Token.RCBracket)
            error(mToken.loc, "parseDef: expected ) after parameters");

        //TODO return type

        //debug: print out function for debug 
        mAstPrinter.print(func);
    }

    /**
    * Parse Defintion
    */
    private void parseDefParams(FunctionDeclaration fd)
    {
        //accept Identifier, ":", "," 

        //Parse one parameter

        char[][] list;

        do
        {
            //no params
            if(!expect(mToken, Token.Identifier))           
                return;

            //variants are: 
            //1. name : type
            //2. name type
            //3. name
            //4. type
            //5. varargs
            //TODO: keywords before: ref, const, in, out,....
            list ~= mToken.val.Identifier;

            mToken = mLex.getToken();
            if(mToken.tok == Token.Colon)
                mToken = mLex.getToken();
            
            //Variant one or two
            if(mToken.tok == Token.Identifier)
            {
                list ~= mToken.val.Identifier;
            }

            if(mToken.tok == Token.RCBracket)
            {
                //all finished
                return;
            }

            //varargs
            if(mToken.tok == Token.Dot)
            {
            }

            if(mToken.tok == Token.Comma)
            {
                //one param finished
                continue;
            }
        }
        while(mToken.tok != Token.Identifier);
                 
    }

    /**
    * Parse Statement
    */
    private void parseStatement()
    {
        //Expressions and Statements
        //CallStatement
    }

    /**
    * Expect a special token
    */
    private bool expect(ref Lexer.TokenEntry token, Token expected)
    {
        token = mLex.getToken();
        return (token.tok == expected);
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
        mLex.source = src;
    }
} 

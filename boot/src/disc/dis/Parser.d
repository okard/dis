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

import std.string;
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

            //case Token.COBracket: parseBlock(); break;
            //case Token.Semicolon: endActualNode(); break;
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

        //parse parameters when some available
        if(mLex.peekToken(1).tok != Token.RCBracket)
            parseDefParams(func);
        else 
            next();

        //after parsing parameters expects )
        if(mToken.tok != Token.RCBracket)
            error(mToken.loc, "parseDef: expected ) after parameters");

        
        auto peekTok = mLex.peekToken(1);
        //look for return value
        if(peekTok.tok == Token.Identifier)
        {
            //TODO return type
        }

        //followed by implemention? (ignore end of line)
        if(peekTok.tok == Token.COBracket)
        {
        }

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
        //variants are: 
        //1. name : type
        //2. name type
        //3. name
        //4. type
        //5. varargs
        //TODO: keywords before: ref, const, in, out,....

        //save elements for one parameter
        char[][] list;

        ///helper function
        void add()
        {
            //currently max 2
            assert(list.length < 3);

            if(list[list.length-1] == "...")
            {
                fd.mType.mVarArgs = true;
                if(list.length == 2)
                {
                    //vararg name
                }
            }
            else if(list.length == 2)
            {
                fd.mType.mArguments ~= resolveType(list[1]);
                fd.mArgumentNames[list[1]] = cast(ubyte)(fd.mType.mArguments.length-1);
            }
        }

        //parse loop
        while(mToken.tok != Token.RCBracket)
        {
            next();

            switch(mToken.tok)
            {
            case Token.Identifier:
                list  ~= mToken.val.Identifier;
                break;
            case Token.Dot:
                //todo dotted identifier
                if(mLex.peekToken(1).tok == Token.Dot && mLex.peekToken(2).tok == Token.Dot)
                {
                    next(); next();
                    list ~= cast(char[])"...";
                }
                break;
            case Token.Colon:
                continue;
            case Token.RCBracket:
                add();
                return;
            case Token.Mul:
                list[list.length-1] ~= '*';
                break;
            case Token.Comma:
                //one param finished
                add();
                list.length = 0;
                next();
                break;
            
            default:
                error(mToken.loc, format("Not expected Token in parseDefParams: %s", disc.dis.Token.toString(mToken.tok)) );
            }
        }     
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
    * Get type for an identifier
    */
    private Type resolveType(char[] identifier)
    {
        Type getType()
        {
            switch(identifier)
            {
                case "char": return PrimaryType.Byte;
                //TODO lookup
                default: return new OpaqueType();
            }
        }

        if(identifier[identifier.length-1] == '*')
        {
            //pointer type
            identifier.length -= 1;
            return new PointerType(getType());
        }
        else
            return getType();
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
    * next token
    */ 
    private void next()
    {
        mToken = mLex.getToken();
    }

    /**
    * Error Event
    */
    private void error(Location loc, string msg)
    {
        //TODO: Make error events, remove stupid writeln
        writefln("(%s): %s", mToken.loc.toString(), msg);
    }

    /**
    * Set Source file for Lexer
    */
    public void source(Source src)
    {
        mLex.source = src;
    }
} 

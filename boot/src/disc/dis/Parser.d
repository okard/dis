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
import disc.basic.Stack;

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
    ///AST Parser Stack
    private Stack!Node mAstStack;
    ///AST Printer
    private Printer mAstPrinter;

    /**
    * Ctor
    */
    public this()
    {
        mLex = new Lexer();
        mAstPrinter = new Printer();
        mAstStack = Stack!Node(256);
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
            //Keywords
            case Token.KwPackage: parsePackage(); break;
            case Token.KwDef: parseDef(); break;
            // Blocks {}
            case Token.COBracket: parseBlock(); break;
            case Token.CCBracket: closeBlock(); break;

            case Token.Semicolon: endActualNode(); break;
            //case Token.Semicolon: endActualNode(); break;
            case Token.Identifier: parseStatement(); break;
            default:
            }

            mToken = mLex.getToken();
        }
        //end of file?
        if(mAstStack.length > 0)
        {
            writeln(mAstStack.top().toString());
            auto pd = cast(PackageDeclaration)mAstStack.top();
            assert(pd !is null);
            mAstPrinter.print(pd);
        }
    }

    private void endActualNode()
    {
        if(cast(FunctionDeclaration)mAstStack.top())
        {
           auto fd = cast(FunctionDeclaration)mAstStack.pop();
            // Function Declaration is finished so add to ...
            if(cast(PackageDeclaration)mAstStack.top())
            {
                auto pd = cast(PackageDeclaration)mAstStack.top();
                pd.mFunctions ~= fd;
                writeln("func added");
            }    
        }   
    }

    private void closeBlock()
    {
        //Close 
        writeln("close block");
        writeln(mAstStack.length());
        assert(cast(BlockStatement)mAstStack.top());
        auto t = cast(BlockStatement)mAstStack.pop();

        if(cast(FunctionDeclaration)mAstStack.top())
        {
            writeln("inner close block");
            auto fd = cast(FunctionDeclaration)mAstStack.pop();
            fd.mBody = t;

            // Function Declaration is finished so add to ...
            if(cast(PackageDeclaration)mAstStack.top())
            {
                auto pd = cast(PackageDeclaration)mAstStack.top();
                pd.mFunctions ~= fd;
                writeln("func added");
            }
        }
        
    }

    /**
    * Parse package
    */
    private void parsePackage()
    {
        //package identifier;
        assert(mToken.tok == Token.KwPackage);
        
        //Package need a name
        if(!expect(mToken, Token.Identifier))
            error(mToken.loc, "Expected Identifier after package");
        
        //Create new Package Declaration
        auto pkg = new PackageDeclaration(cast(string)mToken.val.Identifier);

        //Look for semicolon or end of line
        mToken = mLex.getToken();
        if(mToken.tok != Token.EOL && mToken.tok != Token.Semicolon)
            error(mToken.loc, "Expected EOL or Semicolon");

        mAstStack.push(pkg);
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
            next();
            func.mType.mReturnType = resolveType(mToken.val.Identifier);
        }

        //declaration???
        //followed by implemention? (ignore end of line)
        /*if(peekTok.tok == Token.COBracket)
        {
        }*/
        mAstStack.push(func);
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

            //varargs
            if(list[list.length-1] == "...")
            {
                fd.mType.mVarArgs = true;

                if(list.length == 2)
                {
                    //vararg name
                    fd.mVarArgsName = cast(string)list[0];
                }
            }
            //name and type
            else if(list.length == 2)
            {
                fd.mType.mArguments ~= resolveType(list[1]);
                fd.mArgumentNames[list[0]] = cast(ubyte)(fd.mType.mArguments.length-1);
            }
            //TODO 1 element, variablename or type (declaration with block or not) -> semantic?
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
                break;
            
            default:
                error(mToken.loc, format("Not expected Token in parseDefParams: %s", disc.dis.Token.toString(mToken.tok)) );
            }
        }     
    }

    /**
    * Parse Statement
    */
    private void parseBlock()
    {
        auto block = new BlockStatement();
       
        mAstStack.push(block);
    }

    /**
    * Parse Statement
    */
    private void parseStatement()
    {
        assert(mToken.tok == Token.Identifier);
        
        Statement stat;

        //statement with started identifier?
        DotIdentifier d = new DotIdentifier(mToken.val.Identifier);

        //call Statment
        if(mLex.peekToken(1).tok == Token.ROBracket)
        {
            next();
            //create function call expression
            auto call =  new FunctionCall();
            call.mFunction = d;
            stat = new ExpressionStatement(call);
    
            //Parse until RCBracket

            if(cast(BlockStatement)mAstStack.top())
            {
                auto bs = cast(BlockStatement)mAstStack.top();
                bs.mStatements ~= stat;
            }
        }
    }

    /**
    * Parse Identifier
    */
    private DotIdentifier parseIdentifier()
    {
        assert(mToken.tok == Token.Identifier);

        auto di = new DotIdentifier(mToken.val.Identifier);
        bool expDot = true;

        while(peek(1) == Token.Identifier || peek(1) == Token.Dot)
        {
            next();
            if(expDot && mToken.tok == Token.Identifier)
            {
                error(mToken.loc, "expected dot to seperate identifiers");
                break;
            }   
        }

        return di;
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
                case "void": return new VoidType();
                case "bool": return new BoolType();
                case "byte": return new ByteType();
                case "ubyte": return new UByteType();
                case "short": return new ShortType();
                case "ushort": return new UShortType();
                case "int": return new IntType();
                case "uint": return new UIntType();
                case "long": return new LongType();
                case "ulong": return new ULongType();
                case "float": return new FloatType();
                case "double": return new DoubleType();
                //special:
                case "char": return new CharType();
                //TODO lookup
                default: return new OpaqueType();
            }
        }

        //check for pointer
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
    * Peek token type
    */
    private Token peek(ushort lookahead = 1)
    {
        return mLex.peekToken(lookahead).tok;
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

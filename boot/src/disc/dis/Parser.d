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
    private Token mToken;
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
        
        while(mToken.tok != TokenType.EOF)
        {
            switch(mToken.tok)
            {
            //Keywords
            case TokenType.KwPackage: parsePackage(); break;
            case TokenType.KwDef: parseDef(); break;
            // Blocks {}
            case TokenType.COBracket: parseBlock(); break;
            case TokenType.CCBracket: closeBlock(); break;
            //end actual node
            case TokenType.Semicolon: endActualNode(); break;
            //inner blocks
            case TokenType.Identifier: parseStatement(); break;
            default:
            }

            mToken = mLex.getToken();
        }
        //end of file?
        if(mAstStack.length > 0)
        {
            //writeln(mAstStack.top().toString());
            auto pd = cast(PackageDeclaration)mAstStack.top();
            assert(pd !is null);
            mAstPrinter.print(pd);
        }
    }

    private void endActualNode()
    {
        if(mAstStack.top().mNodeType == NodeType.FunctionDecl)
        {
           auto fd = cast(FunctionDeclaration)mAstStack.pop();   
        }   
    }

    private void closeBlock()
    {
        //Close 
        assert(mAstStack.top().mNodeType == NodeType.BlockStat);
        auto t = cast(BlockStatement)mAstStack.pop();

        //add body to function
        if(mAstStack.top().mNodeType == NodeType.FunctionDecl)
        {
            auto fd = cast(FunctionDeclaration)mAstStack.pop();
            fd.mBody = t;
        }
        
    }

    /**
    * Parse package
    */
    private void parsePackage()
    {
        //package identifier;
        assert(mToken.tok == TokenType.KwPackage);
        
        //Package need a name
        if(!expect(mToken, TokenType.Identifier))
            error(mToken.loc, "Expected Identifier after package");
        
        //Create new Package Declaration
        auto pkg = new PackageDeclaration(cast(string)mToken.value);

        //Look for semicolon or end of line
        mToken = mLex.getToken();
        if(mToken.tok != TokenType.EOL && mToken.tok != TokenType.Semicolon)
            error(mToken.loc, "Expected EOL or Semicolon");

        mAstStack.push(pkg);
    }

    /**
    * Parse Method Definitions
    */
    private void parseDef()
    {
        //top level node must be PackageDeclaration,(ClassDeclaration) 
        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        assert(mToken.tok == TokenType.KwDef);

        auto func = new FunctionDeclaration();

        mToken = mLex.getToken();

        //Parse Calling Convention
        if(mToken.tok == TokenType.ROBracket)
        {
            //identifier aka calling convention
            if(!expect(mToken,TokenType.Identifier))
                error(mToken.loc, "parseDef: Expected Identifier for Calling Convention");
            
            switch(mToken.value)
            {
            case "C": func.mType.mCallingConv = FunctionType.CallingConvention.C; break;
            case "Dis": func.mType.mCallingConv = FunctionType.CallingConvention.Dis;break;
            default: error(mToken.loc, "Invalid CallingConvention");
            }
            
            //close )
            if(!expect(mToken, TokenType.RCBracket))
                error(mToken.loc, "parseDef: Expected )");

            mToken = mLex.getToken();
        }
        
        //parse function name (identifier)
        if(mToken.tok != TokenType.Identifier)
        {
            error(mToken.loc, "parseDef: expected identifier");
            return;
        }
        
        func.mName = cast(string)mToken.value;

        //expected (params) return type {
        if(!expect(mToken, TokenType.ROBracket))
        {
            error(mToken.loc, "parseDef: expected (");
            return;
        }

        //parse parameters when some available
        if(peek(1) != TokenType.RCBracket)
            parseDefParams(func);
        else 
            next();

        //after parsing parameters expects )
        if(mToken.tok != TokenType.RCBracket)
            error(mToken.loc, "parseDef: expected ) after parameters");

        
        auto peekTok = mLex.peekToken(1);
        //look for return value
        if(peekTok.tok == TokenType.Identifier)
        {
            next();
            func.mType.mReturnType = resolveType(mToken.value);
        }

        //declaration???
        //followed by implemention? (ignore end of line)
        /*if(peekTok.tok == Token.COBracket)
        {
        }*/
        if(cast(PackageDeclaration)mAstStack.top())
            (cast(PackageDeclaration)mAstStack.top()).mFunctions ~= func;
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
                fd.mType.mArguments ~= resolveType(cast(string)list[1]);
                fd.mArgumentNames[list[0]] = cast(ubyte)(fd.mType.mArguments.length-1);
            }
            //TODO 1 element, variablename or type (declaration with block or not) -> semantic?
        }

        //parse loop
        while(mToken.tok != TokenType.RCBracket)
        {
            next();

            switch(mToken.tok)
            {
            case TokenType.Identifier:
                list  ~= cast(char[])mToken.value;
                break;
            case TokenType.Dot:
                //todo dotted identifier
                if(peek(1) == TokenType.Dot && peek(2) == TokenType.Dot)
                {
                    next(); next();
                    list ~= cast(char[])"...";
                }
                break;
            case TokenType.Colon:
                continue;
            case TokenType.RCBracket:
                add();
                return;
            case TokenType.Mul:
                list[list.length-1] ~= '*';
                break;
            case TokenType.Comma:
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
        assert(mToken.tok == TokenType.Identifier);
        
        Statement stat;

        //statement with started identifier?
        DotIdentifier d =  new DotIdentifier(cast(char[])mToken.value);
        //auto d = parseIdentifier();

        //call Statment
        if(peek(1) == TokenType.ROBracket)
        {
            next();
            //create function call expression
            auto call =  new FunctionCall();
            call.mFunction = d;
            stat = new ExpressionStatement(call);

            while(peek(1) != TokenType.RCBracket)
            {
                next();
            }
    
            //Parse until RCBracket

            if(cast(BlockStatement)mAstStack.top())
            {
                auto bs = cast(BlockStatement)mAstStack.top();
                bs.mStatements ~= stat;
            }
        }
    }

    /**
    * Parse Expressions
    */
    private void parseExpression()
    {
    }

    /**
    * Parse Identifier
    */
    private DotIdentifier parseIdentifier()
    {
        assert(mToken.tok == TokenType.Identifier);

        auto di = new DotIdentifier(cast(char[])mToken.value);
        bool expDot = true;

        while((peek(1) == TokenType.Identifier) || (peek(1) == TokenType.Dot))
        {              
            next();
            //identifier
            if(expDot && mToken.tok == TokenType.Identifier)
            {
                error(mToken.loc, "expected dot to seperate identifiers");
                break;
            }   
            //dot
            if(!expDot && mToken.tok == TokenType.Dot)
            {
                error(mToken.loc, "expected identifier after dot");
                break;
            }
            
            expDot = !expDot;
            
            if(mToken.tok == TokenType.Identifier)
                di.mIdentifier ~= cast(char[])mToken.value;
            
        }

        return di;
    }

    /**
    * Get type for an identifier
    */
    private Type resolveType(string identifier)
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
    private bool expect(ref Token token, TokenType expected)
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
    private TokenType peek(ushort lookahead = 1)
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

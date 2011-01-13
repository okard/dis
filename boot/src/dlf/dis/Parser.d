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
module dlf.dis.Parser;

import dlf.basic.Location;
import dlf.basic.Source;
import dlf.basic.Stack;
import dlf.basic.Util;

import dlf.dis.Token;
import dlf.dis.Lexer;

import dlf.ast.Node;
import dlf.ast.Type;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Printer;
import dlf.ast.SymbolTable;

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
    ///Current SymbolTable
    private SymbolTable mSymTbl;

    ///Internal Types
    public static DataType[string] InternalTypes;
    ///Opaque Type
    public static DataType opaqueType;


    /**
    * Ctor
    */
    public this()
    {
        mLex = new Lexer();
        mAstStack = Stack!Node(256);
    }

    /**
    * Static Dtor
    */
    public static this()
    {
        //Primary
        InternalTypes["void"] = new VoidType();
        InternalTypes["bool"] = new BoolType();
        InternalTypes["byte"] = new ByteType();
        InternalTypes["ubyte"] = new UByteType();
        InternalTypes["short"] = new ShortType();
        InternalTypes["ushort"] = new UShortType();
        InternalTypes["int"] = new IntType();
        InternalTypes["uint"] = new UIntType();
        InternalTypes["long"] = new LongType();
        InternalTypes["ulong"] = new ULongType();
        InternalTypes["float"] = new FloatType();
        InternalTypes["double"] = new DoubleType();
        //special:
        InternalTypes["char"] = new CharType();
        //opaque
        opaqueType = new OpaqueType();
    }
    
    /**
    * Parse current Source File
    */
    public void parse()
    {
        mToken = mLex.getToken();
        
        //general parse loop (package scope)
        while(mToken.type != TokenType.EOF)
        {
            switch(mToken.type)
            {
            //Keywords
            case TokenType.KwPackage: parsePackage(); break;
            case TokenType.KwClass: break;
            case TokenType.KwDef: parseDef(); break;
            case TokenType.KwImport: break;
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
            mAstRoot = pd;
        }
    }

    /**
    * Parse package
    */
    private void parsePackage()
    {
        //package identifier;
        assert(mToken.type == TokenType.KwPackage);
        
        //check for package identifier
        if(peek(1) != TokenType.Identifier)
            error(mToken.loc, "Expected Identifier after package");

        //parse identifier for Package
        next();
        auto di = parseIdentifier();

        //Create new Package Declaration
        auto pkg = new PackageDeclaration(di.toString());
        //add package to parse stack
        mAstStack.push(pkg);

        //Look for semicolon or end of line
        mToken = mLex.getToken();
        if(mToken.type != TokenType.EOL && mToken.type != TokenType.Semicolon)
            error(mToken.loc, "Expected EOL or Semicolon after package declaration");

        //dont pop from stack
    }

    /**
    * Parse Method Definitions
    */
    private void parseDef()
    {
        //top level node must be PackageDeclaration,(ClassDeclaration) 
        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        assert(mToken.type == TokenType.KwDef);

        auto func = new FunctionDeclaration();
        //add function declaration to stack
        mAstStack.push(func);

        mToken = mLex.getToken();

        //Parse Calling Convention
        if(mToken.type == TokenType.ROBracket)
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
        if(mToken.type != TokenType.Identifier)
        {
            error(mToken.loc, "parseDef: expected identifier");
            return;
        }
        
        func.Name = cast(string)mToken.value;


        //Parse Parameter if available
        if(peek(1) == TokenType.ROBracket)
        {
            next();

            //parse parameters when some available
            if(peek(1) != TokenType.RCBracket)
                parseDefParams(func);
            else 
                next();

            //after parsing parameters expects )
            if(mToken.type != TokenType.RCBracket)
                error(mToken.loc, "parseDef: expected ) after parameters");
        }

        //look for return value
        if(peek(1) == TokenType.Identifier)
        {
            next();
            func.mType.mReturnType = resolveType(mToken.value);
        }

        //if function declarations closes with ";" it is finished
        if(peek(1) == TokenType.Semicolon)
        {
            next();
        }
        
        //Look for Basic Block here, ignore new lines and comments
        if(peekIgnore(1, [TokenType.EOL, TokenType.Comment]) == TokenType.COBracket)
        {
            //goto "{"
            while(mToken.type != TokenType.COBracket) 
                next();
            //parse the block
            parseBlock();
        }

        //Function Declaration finished pop from stack
        mAstStack.pop();
        if(mAstStack.top.Type == NodeType.PackageDeclaration)
        {
            (cast(PackageDeclaration)mAstStack.top).mFunctions ~= func;
        }
    }
       
    /**
    * Parse Function Defintion Parameters
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
        //TODO: keywords before: ref, const, in, out, this, ...

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
                fd.mArgumentNames[cast(string)list[0]] = cast(ubyte)(fd.mType.mArguments.length-1);
            }
            //TODO 1 element, variablename or type (declaration with block or not) -> semantic?
        }

        //parse loop
        while(mToken.type != TokenType.RCBracket)
        {
            next();

            switch(mToken.type)
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
                error(mToken.loc, format("Not expected Token in parseDefParams: %s", dlf.dis.Token.toString(mToken.type)) );
            }
        }     
    }

    /**
    * Parse Block {}
    * Parse Complete Block
    */
    private void parseBlock()
    {
        //start token is "{"
        assert(mToken.type == TokenType.COBracket);

        //TODO symbol table? each block has one?
        auto block = new BlockStatement();
        mAstStack.push(block);

        //parse until "}"
        while(peek(1) != TokenType.CCBracket)
        {
            next();
            
            //ignore newlines
            if(mToken.type == TokenType.EOL)
                continue;

            //a Block can only contain declarations and statements

            //Declarations:
            //var, val, def, class, trait, type
            if(isIn!TokenType(mToken.type, [TokenType.KwVar, TokenType.KwVal, TokenType.KwDef, TokenType.KwClass]))
            {
                //parseDeclarations
                continue;
            }

            //Parse statements
            auto stat = parseStatement();
            if(stat !is null)
            {
                block.mStatements ~= stat;
            }
        }
        //go over } ?
        next();

        //pop block from stack
        if(mAstStack.top.Type == NodeType.BlockStatement)
            mAstStack.pop();
        
        //look for node before block
        auto node = mAstStack.top;
        if(node.Type == NodeType.FunctionDeclaration)
        {
            (cast(FunctionDeclaration)mAstStack.top).Body = block;
        }
    }

    /**
    * Parse Statement
    */
    private Statement parseStatement()
    {

        //a Statement can be a statement
        //or a StatementExpression

        switch(mToken.type)
        {
        //for 
        case TokenType.KwFor: break;
        //do-while
        case TokenType.KwDo: break;
        //while
        case TokenType.KwWhile: break;
        default:
        }


        //parse Statement-Expression
        auto exp = parseExpression();
        if(exp !is null)
        {
            return new ExpressionStatement(exp);
        }

        return null;
    }

    /**
    * Parse Expressions
    */
    private Expression parseExpression()
    {
        writefln("Current Token: %s", dlf.dis.Token.toString(mToken.type));

        //Keyword Based
        //If-ElseIf-Else
        //Switch-Case
        switch(mToken.type)
        {
            case TokenType.KwIf: break;
            case TokenType.KwSwitch: break;
            case TokenType.KwThis: break;
            case TokenType.ROBracket: /*return parseExpression; assert(mToken.type == RCBracket);*/ break;
            case TokenType.Identifier:/*look under switch*/ break;
            // Literal Expressions
            case TokenType.String:
            case TokenType.Integer: 
            case TokenType.Float:
            case TokenType.Double:
                 return new LiteralExpression(mToken.value);
            default:
                assert(true);
        }

        //current is identifier?
        auto di = parseIdentifier();

        //seems to be a function call
        if(peek(1) == TokenType.ROBracket)
        {
            next();

            //Create Function Call
            auto call = new FunctionCall();
            call.mFunction = di;

            while(peek(1) != TokenType.RCBracket)
            {
                //parse calling arguments
                next();

                //parse Expressions for arguments
                auto arg = parseExpression();
                call.Arguments ~= arg;
            }
            next();

            //ending semicolon (or new line?)
            if(peek(1) == TokenType.Semicolon)
                next();

            return call;
        }

        //array access [
        //operator? =, ==, !=, +, - , 

        //other expressions should start with an (Dot)Identifier
        //or this
        
        //Function Call the identifier is followed by a "("

        //Binary&Unary Expressions
        //Math Expressions
        //-> Followed by an operator

        //Literal -> Char, String, Integer, Float, Double, Array, Lambda

        //starts with "(" ?
        return null;
    }

    /**
    * Parse Identifier
    */
    private DotIdentifier parseIdentifier()
    {
        assert(mToken.type == TokenType.Identifier);

        auto di = new DotIdentifier(cast(char[])mToken.value);
        bool expDot = true;

        while((peek(1) == TokenType.Identifier) || (peek(1) == TokenType.Dot))
        {              
            next();
            //identifier
            if(expDot && mToken.type == TokenType.Identifier)
            {
                error(mToken.loc, "expected dot to seperate identifiers");
                break;
            }   
            //dot
            if(!expDot && mToken.type == TokenType.Dot)
            {
                error(mToken.loc, "expected identifier after dot");
                break;
            }
            
            expDot = !expDot;
            
            if(mToken.type == TokenType.Identifier)
                di.mIdentifier ~= cast(char[])mToken.value;
            
        }

        return di;
    }

    /**
    * Get type for an identifier
    * return Opaque Type when not resolved
    */
    private DataType resolveType(string identifier)
    {
        //check for pointer
        if(identifier[identifier.length-1] == '*')
        {
            //pointer type
            identifier.length -= 1;
            return new PointerType(InternalTypes.get(identifier, opaqueType));
        }
        else
            return InternalTypes.get(identifier, opaqueType);
    }

    /**
    * Expect a special token
    */
    private bool expect(ref Token token, TokenType expected)
    {
        token = mLex.getToken();
        return (token.type == expected);
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
        return mLex.peekToken(lookahead).type;
    }

    /**
    * Peek next valid TokenType
    * Ignore the ignore list
    */
    private TokenType peekIgnore(ushort lookahead = 1, TokenType[] ignore = [])
    {
        TokenType t;

        do
        {
            t = mLex.peekToken(lookahead).type;
            lookahead++;
        }
        while(isIn!TokenType(t, ignore));

        return t;
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
    * Warning Event
    */
    private void warning(Location loc, string msg)
    {
        //TODO: Make error events, remove stupid writeln
        writefln("(%s): %s", mToken.loc.toString(), msg);
    }

    /**
    * Set Source file for Lexer
    */
    @property
    public void source(Source src)
    {
        mLex.source = src;
    }
    
    /**
    * Get source 
    */
    @property 
    public Source source()
    {
        return mLex.source;
    }

    /**
    * Get Parse Tree
    */
    @property
    public Node ParseTree()
    {
        return mAstRoot;
    }
} 

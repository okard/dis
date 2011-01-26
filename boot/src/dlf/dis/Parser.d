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
import dlf.ast.Annotation;
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
    private SymbolTable mSymTable;
    ///Internal Types
    public static DataType[string] InternalTypes;

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
        InternalTypes["void"] = VoidType.Instance;
        InternalTypes["bool"] = BoolType.Instance;
        InternalTypes["byte"] = ByteType.Instance;
        InternalTypes["ubyte"] = UByteType.Instance;
        InternalTypes["short"] = ShortType.Instance;
        InternalTypes["ushort"] = UShortType.Instance;
        InternalTypes["int"] = IntType.Instance;
        InternalTypes["uint"] = UIntType.Instance;
        InternalTypes["long"] = LongType.Instance;
        InternalTypes["ulong"] = ULongType.Instance;
        InternalTypes["float"] = FloatType.Instance;
        InternalTypes["double"] = DoubleType.Instance;
        
        //special:
        //InternalTypes["ptr"] = ;;
        InternalTypes["char"] = CharType.Instance;
        InternalTypes["string"] = StringType.Instance;
    }

    /**
    * Parse a Source to Node
    */
    public Node parse(Source src)
    {
        Src = src;
        return parse();
    }

    /**
    * Parse one node from current source
    */
    public Node parse()
    {
        if(Src is null || Src.isEof)
            return null;

        //get first token
        next();

        while(mToken.Type == TokenType.Comment || mToken.Type == TokenType.EOL)
            next();
        try
        {
            //Supported Token as EntryPoint
            switch(mToken.Type)
            {
                case TokenType.KwPackage: return parsePackage(); 
                case TokenType.KwClass: break;
                case TokenType.KwDef: break;
                case TokenType.KwTrait: break;
                case TokenType.KwType: break;
                case TokenType.Identifier: return parseExpression();
                default: return null;
            }
        }
        catch(Object o)
        {
            Error(mToken.Loc, "Exception in Parser"); 
            throw o;
        }


        return null;
    }

    /**
    * Parse package
    */
    private PackageDeclaration parsePackage()
    {
        //package identifier;
        assert(mToken.Type == TokenType.KwPackage);
        
        //check for package identifier
        if(peek(1) != TokenType.Identifier)
            Error(mToken.Loc, "Expected Identifier after package");

        //parse identifier for Package
        next();
        auto di = parseIdentifier();

        //Create new Package Declaration
        auto pkg = new PackageDeclaration(di.toString());
        pkg.SymTable = new SymbolTable(null);
        mSymTable = pkg.SymTable;

        //add package to parse stack
        mAstStack.push(pkg);

        //Look for semicolon or end of line
        mToken = mLex.getToken();
        if(mToken.Type != TokenType.EOL && mToken.Type != TokenType.Semicolon)
            Error(mToken.Loc, "Expected EOL or Semicolon after package declaration");

        //general parse loop (package scope)
        while(mToken.Type != TokenType.EOF)
        {
            next();

            switch(mToken.Type)
            {
            case TokenType.KwClass: break;
            case TokenType.KwDef:
                    auto f = parseDef(); 
                    f.Parent = pkg;
                    pkg.Functions ~= f;
                    mSymTable[f.Name] = f;
                break;
            case TokenType.KwImport: break;
            //DefDecl
            //VarDecl
            //ValDecl
            //TraitDecl
            default:
            }
        }

        //dont pop from stack
        return pkg;
    }

    /**
    * Parse Method Definitions
    */
    private FunctionDeclaration parseDef()
    {
        //top level node must be PackageDeclaration,(ClassDeclaration) 
        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        assert(mToken.Type == TokenType.KwDef);

        auto func = new FunctionDeclaration();
        //add function declaration to stack
        mAstStack.push(func);

        mToken = mLex.getToken();

        //Parse Calling Convention
        if(mToken.Type == TokenType.ROBracket)
        {
            //identifier aka calling convention
            if(!expect(mToken,TokenType.Identifier))
                Error(mToken.Loc, "parseDef: Expected Identifier for Calling Convention");
            
            switch(mToken.Value)
            {
            case "C": func.FuncType.CallingConv = FunctionType.CallingConvention.C; break;
            case "Dis": func.FuncType.CallingConv = FunctionType.CallingConvention.Dis;break;
            default: Error(mToken.Loc, "Invalid CallingConvention");
            }
            
            //close )
            if(!expect(mToken, TokenType.RCBracket))
                Error(mToken.Loc, "parseDef: Expected )");

            mToken = mLex.getToken();
        }
        
        //parse function name (identifier)
        if(mToken.Type != TokenType.Identifier)
        {
            Error(mToken.Loc, "parseDef: expected identifier");
            return null;
        }
        
        func.Name = cast(string)mToken.Value;


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
            if(mToken.Type != TokenType.RCBracket)
                Error(mToken.Loc, "parseDef: expected ) after parameters");
        }

        //look for return value
        if(peek(1) == TokenType.Identifier || peek(1) == TokenType.Colon)
        {
            next();
            if(mToken.Type == TokenType.Colon)
            {
                if(!expect(mToken, TokenType.Identifier))
                    Error(mToken.Loc, "Expect Identifier after ':' for function return type");
            }
            func.FuncType.ReturnType = resolveType(mToken.Value);
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
            while(mToken.Type != TokenType.COBracket) 
                next();
            //parse the block
            auto b = parseBlock();
            b.Parent = func;
            func.Body = b;
        }

        //Function Declaration finished pop from stack
        mAstStack.pop();

        //return function
        return func;
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
                fd.FuncType.mVarArgs = true;

                if(list.length == 2)
                {
                    //vararg name
                    fd.mVarArgsName = cast(string)list[0];
                }
            }
            //name and type
            else if(list.length == 2)
            {
                fd.FuncType.Arguments ~= resolveType(cast(string)list[1]);
                fd.mArgumentNames[cast(string)list[0]] = cast(ubyte)(fd.FuncType.Arguments.length-1);
            }

            //one argument
            if(list.length == 1)
            {
                //TODO 1 element, variablename or type (declaration with block or not) -> semantic?
                Error(mToken.Loc, "Function Parameters must have 2 Identifier 'name type', one identifier is not yet supported");
                assert(true);
            }

        }

        //parse loop
        while(mToken.Type != TokenType.RCBracket)
        {
            next();

            switch(mToken.Type)
            {
            case TokenType.Identifier:
                list  ~= cast(char[])mToken.Value;
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
                Error(mToken.Loc, format("Not expected Token in parseDefParams: %s", dlf.dis.Token.toString(mToken.Type)) );
            }
        }     
    }

    /**
    * Parse Variables
    */
    private VariableDeclaration parseVar()
    {
        assert(mToken.Type == TokenType.KwVar);

        //expect Identifier after var
        if(!expect(mToken, TokenType.Identifier))
        {
            Error(mToken.Loc, "Expect Identifer after var keyword");
            return null;
        }
        
        //create new variable delclaration at the moment with opaque type
        auto var = new VariableDeclaration(mToken.Value);

        //check for type Information
        if(peek(1) == TokenType.Identifier || peek(1) == TokenType.Colon)
        {
            //Type Information
            if(peek(1) == TokenType.Colon)
                next();
            
            if(!expect(mToken, TokenType.Identifier))
            {
                Error(mToken.Loc, "Expected Identifer as type information for variable");
                return null;
            }

            //parseIdentifier()
            var.VarDataType = resolveType(mToken.Value);
        }
        
        //check for initalizer
        if(peek(1) == TokenType.Assign)
        {
            next(); //oken is now "="-Assign
            next(); //now its start of expression

            var.Initializer = parseExpression();
        }

        //skip semicolon at end
        if(peek(1) == TokenType.Semicolon)
            next();

        return var;
    }

    /**
    * Parse Statement
    */
    private Statement parseStatement()
    {

        //a Statement can be a statement
        //or a StatementExpression

        switch(mToken.Type)
        {
        //Block Statement
        case TokenType.COBracket:
            break;
        //for, foreach 
        case TokenType.KwFor: 
            break;
        //do-while
        case TokenType.KwDo: 
            break;
        //while
        case TokenType.KwWhile: 
            break;
        case TokenType.KwReturn:
            return new ReturnStatement(parseExpression());
        default:
        }

        //parse Statement-Expression
        auto exp = parseExpression();
        if(exp !is null)
        {
            auto es =  new ExpressionStatement(exp);
            exp.Parent = es;
        }

        return null;
    }

    /**
    * Parse Block {}
    * Parse Complete Block
    */
    private BlockStatement parseBlock()
    {
        //start token is "{"
        assert(mToken.Type == TokenType.COBracket);

        //TODO symbol table? each block has one?
        auto block = new BlockStatement();
        block.SymTable = mSymTable.push();
        mSymTable = block.SymTable;
        mAstStack.push(block);

        //parse until "}"
        while(mToken.Type != TokenType.CCBracket && peek(1) != TokenType.CCBracket)
        {
            next();
            
            //ignore newlines, comments
            if(mToken.Type == TokenType.EOL || mToken.Type == TokenType.Comment || mToken.Type == TokenType.Semicolon)
                continue;

            //a Block can only contain declarations and statements

            if(mToken.Type == TokenType.KwVar)
            {
                auto var = parseVar();
                mSymTable[var.Name] = var;
                var.Parent = block;
                continue;
            }

            //Declarations:
            //var, val, def, class, trait, type
            if(isIn!TokenType(mToken.Type, [TokenType.KwVal, TokenType.KwDef, TokenType.KwClass]))
            {
                //parseDeclarations
                continue;
            }

   
            //Whens here try to be statment
            auto stat = parseStatement();
            if(stat !is null)
            {
                block.Statements ~= stat;
                stat.Parent = block;
            }
        }
        //go over } ?
        next();

        mSymTable = block.SymTable.pop();
        
        return block;
    }


    /**
    * Parse Expressions
    */
    private Expression parseExpression()
    {
        //parse one expression
        Expression expr = null;

        writefln("Loc: %s, Tok: %s", mToken.Loc, mToken);

        //Keyword Based
        //If-ElseIf-Else
        //Switch-Case
        switch(mToken.Type)
        {
            case TokenType.KwIf: 
                expr = parseIfExpression();
                break;
            case TokenType.KwSwitch: 
                expr = parseSwitchExpression();
                break;
            case TokenType.KwThis: 
                 /*identifier?*/
                //expr = parseIdentifier();
                break;
            case TokenType.ROBracket: 
                //return parseExpression; 
                //assert(mToken.Type == RCBracket);
                break;
            case TokenType.Identifier:
                /*look under switch*/ 
                expr = parseIdentifier();
                break;

            // Literal Expressions
            //TODO Pay Attention for next Token when it is an op
            case TokenType.String:
                //TODO Fix it, a String Literal is a pointer to a char[] array
                expr = new LiteralExpression(mToken.Value, StringType.Instance);
                break;
            case TokenType.Char:
                expr =  new LiteralExpression(mToken.Value, CharType.Instance); 
                break;
            case TokenType.Integer:
                expr = new LiteralExpression(mToken.Value, IntType.Instance); 
                break;
            case TokenType.Float:
                expr = new LiteralExpression(mToken.Value, FloatType.Instance); 
                 break;
            case TokenType.Double:
                expr = new LiteralExpression(mToken.Value, DoubleType.Instance);
                break;
            case TokenType.KwTrue:
            case TokenType.KwFalse:
                expr = new LiteralExpression(mToken.Value, BoolType.Instance);
                break;
            default:
                Error(mToken.Loc, "No right Token for parse a Expression");
                assert(true);
        }

        //here it can be KwThis
        //ROBracket
        //Identifier

        //seems to be a function call "(" after expression/identifier
        if(expr.ExprType == Expression.Type.Identifier && peek(1) == TokenType.ROBracket)
        {
            next();

            //Create Function Call
            auto call = new FunctionCall();
            call.Function = expr;

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

            //return call;
            expr = call;
        }

        
        //check next token for concat expressions
        switch(peek(1))
        {
            case TokenType.Semicolon:
                return expr;
            //Assign Expression:
            case TokenType.Assign:
                auto a = new AssignExpression();
                a.Target = expr;
                expr.Parent = a;
                next; next;
                auto b = parseExpression();
                a.Value = b;
                b.Parent = a;
                return a;

            //Binary Expressions
            case TokenType.Add:
            case TokenType.Sub:
            case TokenType.Mul:
            case TokenType.Div:
                auto a = new BinaryExpression();
                a.Left = expr;
                expr.Parent = a;
                next; next;
                auto b = parseExpression();
                a.Right = b;
                b.Parent = a;
                return a;
    
            default:
                return expr;
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
        //return expr;
    }

    /**
    * Parse If Expression
    */
    private Expression parseIfExpression()
    {
        assert(mToken.Type == TokenType.KwIf);
        Error(mToken.Loc, "TODO: Can't parse If Expressions yet");
        return null;
    }

    /**
    * Parse Switch Expression
    */
    private Expression parseSwitchExpression()
    {
        assert(mToken.Type == TokenType.KwSwitch);
        Error(mToken.Loc, "TODO: Can't parse Switch Expressions yet");
        return null;
    }

    /**
    * Parse Identifier
    */
    private DotIdentifier parseIdentifier()
    {
        assert(mToken.Type == TokenType.Identifier);

        auto di = new DotIdentifier(cast(char[])mToken.Value);
        bool expDot = true;

        while((peek(1) == TokenType.Identifier) || (peek(1) == TokenType.Dot))
        {              
            next();
            //identifier
            if(expDot && mToken.Type == TokenType.Identifier)
            {
                Error(mToken.Loc, "expected dot to seperate identifiers");
                break;
            }   
            //dot
            if(!expDot && mToken.Type == TokenType.Dot)
            {
                Error(mToken.Loc, "expected identifier after dot");
                break;
            }
            
            expDot = !expDot;
            
            if(mToken.Type == TokenType.Identifier)
                di ~= cast(char[])mToken.Value;
            
        }

        return di;
    }

    /**
    * Parse Annotation
    */
    private Annotation parseAnnotation()
    {
        // Annotions: @identifier
        assert(mToken.Type == TokenType.Annotation);
        
        if(peek(1) != TokenType.Identifier)
        {
            Error(mToken.Loc, "Error: Expected Identifier after @ for Annotations");
        }

        next();
        
        //Special Annotations
        if(mToken.Value == "CallConv")
        {
            return new CallConvAnnotation();
        }
        
        return null;
    }

    /**
    * Get type for an identifier
    * return Opaque Type when not resolved
    */
    private DataType resolveType(string identifier)
    {
        //TODO lookup at symbol table?
        //check for pointer
        if(identifier[identifier.length-1] == '*')
        {
            //pointer type
            identifier.length -= 1;
            return new PointerType(InternalTypes.get(identifier, OpaqueType.Instance));
        }
        else
            return InternalTypes.get(identifier, OpaqueType.Instance);
    }

    /**
    * Expect a special token
    */
    private bool expect(ref Token token, TokenType expected)
    {
        token = mLex.getToken();
        return (token.Type == expected);
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
        return mLex.peekToken(lookahead).Type;
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
            t = mLex.peekToken(lookahead).Type;
            lookahead++;
        }
        while(isIn!TokenType(t, ignore));

        return t;
    }

    /**
    * Error Event
    */
    private void Error(Location loc, string msg)
    {
        //TODO: Make error events, remove stupid writeln
        writefln("(%s): %s", loc, msg);
    }

    /**
    * Warning Event
    */
    private void Warning(Location loc, string msg)
    {
        //TODO: Make error events, remove stupid writeln
        writefln("(%s): %s", loc, msg);
    }

    /**
    * Set Source file for Lexer
    */
    @property
    public void Src(Source src)
    {
        mLex.Src = src;
    }
    
    /**
    * Get source 
    */
    @property 
    public Source Src()
    {
        return mLex.Src;
    }

    /**
    * Get Parse Tree
    */
    @property
    public Node ParseTree()
    {
        //Root node with Multiple Package nodes?
        return mAstRoot;
    }
} 

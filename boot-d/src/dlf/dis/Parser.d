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

import std.string;
//debug
import std.stdio;

import dlf.basic.Location;
import dlf.basic.Source;
import dlf.basic.Stack;
import dlf.basic.Util;
import dlf.basic.Log;

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

/**
* Dis Parser
* recursive descent, experimental
* maybe replaced by parsing framework, peg/packrat parser
*/
class Parser
{
    /// Logger
    private LogSource log = Log("Parser");

    /// Lexer
    private scope Lexer mLex;

    /// Current Token
    private Token mToken;

    /// Current SymbolTable
    private SymbolTable mSymTable;

    /// Internal Types (Builtin)
    public static DataType[string] InternalTypes;

    /**
    * Ctor
    */
    public this()
    {
        mLex = new Lexer();
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
    * Load a source object
    */
    public void load(Source src)
    {
        if(src is null || src.isEof)
            throw new Exception("No Source available");

        //open source file and set ignore tokens
        mLex.open(src);
        mLex.Ignore = [TokenType.Comment, TokenType.EOL];
        
        //go to first token
        next();
    }

    //public Declaration parseDeclaration();

    /**
    * Parse package
    */
    public PackageDeclaration parsePackage()
    {
        //package identifier;
        assertType(TokenType.KwPackage);
        
        //Create new Package Declaration
        auto pkg = new PackageDeclaration();
        pkg.Loc = mToken.Loc;
        pkg.modificationDate = Src.modificationDate;
        pkg.SymTable = new SymbolTable(pkg, null);
        mSymTable = pkg.SymTable;

        //parameterized keywords
        if(peek(1) == TokenType.ROBracket)
        {
            next;
            if(!next(TokenType.Identifier))
                Error(mToken.Loc, "Expected Identifier for Package Keyword Parameter");
            
            switch(mToken.Value)
            {
                case "nr": pkg.RuntimeEnabled = false; break;
                default: Error(mToken.Loc, "Not kown Package Keyword Parameter");
            }
            
            if(!next(TokenType.RCBracket))
                Error(mToken.Loc, "Expected ) after Package Keyword Parameter");
        }
        
        //check for package identifier
        if(peek(1) != TokenType.Identifier)
            Error(mToken.Loc, "Expected Identifier after package");

        //parse identifier for Package
        next();
        auto di = parseIdentifier();
        pkg.Name = di.toString();

        //Look for semicolon or end of line
        next();
        if(mToken.Type != TokenType.EOL && mToken.Type != TokenType.Semicolon)
            Error(mToken.Loc, "Expected EOL or Semicolon after package declaration");

        //general parse loop (package scope)
        while(mToken.Type != TokenType.EOF)
        {
            next();

            //parseDeclarations

            switch(mToken.Type)
            {
            case TokenType.KwClass: break;
            case TokenType.KwDef:
                    //TODO give symbol table as scope?
                    parseDef(pkg.SymTable); 
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
    * Parse Import Declaration
    */
    private ImportDeclaration parseImport()
    {
        //import std.io.stream;
        assertType(TokenType.KwImport);
        auto imp = new ImportDeclaration;
        imp.Loc = mToken.Loc;

        //import followed by identifier
        if(!next(TokenType.Identifier))
            Error(mToken.Loc, "parseImport: expect identifier after import keyword");

        imp.ImportIdentifier.idents ~= value();

        while(peek(1) == TokenType.Dot)
        {
            next;
            switch(peek(1))
            {
                case TokenType.Identifier: 
                    next; imp.ImportIdentifier.idents ~= value(); break;
                case TokenType.Mul:
                    next; imp.IsWildcardImport = true; break;
                default:
                    Error(mToken.Loc, "parseImport: expect identifier or * after dot");
            }
        }

        imp.Name = imp.ImportIdentifier.toString();
        
        return imp;
    }

    /**
    * Parse a Class
    */
    private ClassDeclaration parseClass()
    {
        //must be class class
        assertType(TokenType.KwClass);

        // class(kw param) identifier(template args) : inherits {


        return null;
    }

    /**
    * Parse Method Definitions
    */
    private void parseDef(SymbolTable symtbl)
    {
        //top level node must be PackageDeclaration,(ClassDeclaration) 
        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        assertType(TokenType.KwDef);

        auto func = new FunctionBase();
        func.Loc = mToken.Loc;
    
        //TODO assign annotations, attributes parsed before

        next();

        //Parse Calling Convention
        if(mToken.Type == TokenType.ROBracket)
        {
            //identifier aka calling convention
            if(!next(TokenType.Identifier))
                Error(mToken.Loc, "parseDef: Expected Identifier for Calling Convention");
            
            switch(mToken.Value.toLower())
            {
            case "c": func.CallingConv = CallingConvention.C; break;
            case "dis": func.CallingConv = CallingConvention.Dis;break;
            default: Error(mToken.Loc, "Invalid CallingConvention");
            }
            
            //close )
            if(!next(TokenType.RCBracket))
                Error(mToken.Loc, "parseDef: Expected )");

            next();
        }
        
        //parse function name (identifier)
        if(mToken.Type != TokenType.Identifier)
        {
            Error(mToken.Loc, "parseDef: expected identifier");
        }

        //get name
        string name = cast(string)mToken.Value;

        if(!symtbl.contains(name))
        {
            symtbl[name] = new FunctionSymbol(name);
            symtbl[name].Loc = mToken.Loc; //first occurence
            symtbl[name].Parent = symtbl.Owner; //Parent Node
        }

        if(symtbl[name].Kind != NodeKind.FunctionSymbol)
            Error(mToken.Loc, "parseDef: already a non-function entry in symbol table with this name");

        //assign function base
        auto sym = (cast(FunctionSymbol)symtbl[name]);
        sym.Bases ~= func;
        func.Parent = sym;

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

        //TODO can also be something like def(asdsd) required more parsing power
        //look for return value 
        if(peek(1) == TokenType.Identifier || peek(1) == TokenType.Colon)
        {
            next();
            if(mToken.Type == TokenType.Colon)
            {
                if(!next(TokenType.Identifier))
                    Error(mToken.Loc, "Expect Identifier after ':' for function return type");
            }
            func.ReturnType = new UnsolvedType(mToken.Value);
            //not only 
        }
        else
            func.ReturnType = OpaqueType.Instance;

        //if function declarations closes with ";" it is finished
        if(peek(1) == TokenType.Semicolon)
        {
            next();
        }

        //after declaration followed  { or = or ; or is end of declaration
        switch(peek(1))
        {
            //block {}
            case TokenType.COBracket:
                next();
                //parse the block
                auto b = parseBlock();
                b.Parent = func;
                func.Body = b;
                return;

            // = <statement or expression>
            case TokenType.Assign:
                throw new ParserException(mToken.Loc, "Assign Expr|Stmt Functions not yet implemented");

            default:
                return;
        }
    }
       
    /**
    * Parse Function Defintion Parameters
    */
    private void parseDefParams(FunctionBase fd)
    {
        //accept Identifier, ":", "," 

        //simple case "ident :" 
        //simple case "def"
        //simple case "ident["
        //simple case "ident."
        //simple case "ident!"

        //complex case: "ident"

        //Parse one parameter
        //variants are: 
        //1. name : type
        //2. name type
        //3. name
        //4. type
        //5. varargs
        //TODO: keywords before: ref, const, in, out, this, ...

        FunctionParameter param = FunctionParameter();
        param.Index = 0;

        //parse loop
        while(mToken.Type != TokenType.RCBracket)
        {
            next();

            switch(mToken.Type)
            {
            case TokenType.Identifier:
                //TODO parse Identifier
                param.Definition ~= mToken.Value;
                break;

            case TokenType.Vararg:
                param.Vararg = true;
                break;

            case TokenType.Colon:
                //change state?
                continue;

            case TokenType.Mul: /// Clear Pointer Type
                param.Definition ~= "*";
                break;
            
            case TokenType.RCBracket:
                fd.Parameter ~= param;
                return;

            case TokenType.Comma:
                //one param finished
                fd.Parameter ~= param;
                param = FunctionParameter();
                param.Index = cast(ushort)fd.Parameter.length;
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
        assertType(TokenType.KwVar);

        auto loc = mToken.Loc;

        //expect Identifier after var
        if(!next(TokenType.Identifier))
        {
            Error(mToken.Loc, "Expect Identifier after var keyword");
        }
        
        //create new variable delclaration at the moment with opaque type
        auto var = new VariableDeclaration(mToken.Value);
        var.Loc = loc;

        //check for type Information
        if(peek(1) == TokenType.Identifier || peek(1) == TokenType.Colon)
        {
            //Type Information
            if(peek(1) == TokenType.Colon)
                next();
            
            if(!next(TokenType.Identifier))
                Error(mToken.Loc, "Expected Identifer as type information for variable");

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
            return parseBlock();
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
            //parse Expression
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
        assertType(TokenType.COBracket);

        //TODO symbol table? each block has one?
        auto block = new BlockStatement();
        block.Loc = mToken.Loc;
        block.SymTable = mSymTable.push(block);
        mSymTable = block.SymTable;

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
            if(isIn!TokenType(mToken.Type, [TokenType.KwLet, TokenType.KwDef, TokenType.KwClass]))
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
    * Parse a For Loop
    * For or Foreach
    */
    private Statement parseFor()
    {
        assertType(TokenType.KwFor);
        throw new ParserException(mToken.Loc, "Can't parse for statements at the moment");
    }

    /**
    * Parse While Loop
    */
    private WhileStatement parseWhile()
    {
        assertType(TokenType.KwWhile);
        throw new ParserException(mToken.Loc, "Can't parse while statements at the moment");
    }

    /**
    * Parse Do-While Loop
    */
    private WhileStatement parseDoWhile()
    {
        assertType(TokenType.KwDo);
        throw new ParserException(mToken.Loc, "Can't parse do-while statements at the moment");
    }

    /**
    * Parse Expressions
    */
    private Expression parseExpression()
    {
        //parse one expression
        Expression expr = null;

        writefln("Parse Expr Loc: %s, Tok: %s", mToken.Loc, mToken);

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
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Char:
                expr =  new LiteralExpression(mToken.Value, CharType.Instance); 
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Integer:
                expr = new LiteralExpression(mToken.Value, IntType.Instance); 
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Float:
                expr = new LiteralExpression(mToken.Value, FloatType.Instance); 
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Double:
                expr = new LiteralExpression(mToken.Value, DoubleType.Instance);
                expr.Loc = mToken.Loc;
                break;
            case TokenType.KwTrue:
            case TokenType.KwFalse:
                expr = new LiteralExpression(mToken.Value, BoolType.Instance);
                expr.Loc = mToken.Loc;
                break;
            default:
                Error(mToken.Loc, "No right Token for parse a Expression");
        }

        //here it can be KwThis
        //ROBracket
        //Identifier

        //seems to be a function call "(" after expression/identifier
        if(expr.Kind == NodeKind.DotIdentifier && peek(1) == TokenType.ROBracket)
        {
            next();

            //Create Function Call
            auto call = new CallExpression();
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
        assertType(TokenType.KwIf);
        Error(mToken.Loc, "TODO: Can't parse If Expressions yet");

        return null;
    }

    /**
    * Parse Switch Expression
    */
    private Expression parseSwitchExpression()
    {
        assertType(TokenType.KwSwitch);
        Error(mToken.Loc, "TODO: Can't parse Switch Expressions yet");
        return null;
    }

    /**
    * Parse Identifier
    */
    private DotIdentifier parseIdentifier()
    {
        assertType(TokenType.Identifier);

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

    //DotIdentifier (package, imports, datatypes, ...)
    //DotExpression
    //Import can have a * at end
    //Seperate DotDataType ?

    /**
    * Parse Annotation
    */
    private Annotation parseAnnotation()
    {
        // Annotions: @identifier
        assertType(TokenType.Annotation);
        
        if(peek(1) != TokenType.Identifier)
        {
            Error(mToken.Loc, "Error: Expected Identifier after @ for Annotations");
        }

        next();
        
        //unittest 
        
        return null;
    }

    /**
    * Parse a datatype
    */
    private DataType parseDataType()
    {
        // Identifier
        if(mToken.Type == TokenType.Identifier)
        {
            switch(peek(1))
            {
                //.
                case TokenType.Dot: break;
                //[ opt(num) ]
                case TokenType.AOBracket: break;
                //! datatype
                //!(datatypes)
                case TokenType.Not: break;

                default: 
                         //InternalTypes[mToken.Value]
                         //internal lookup
                         //parse
                         //return unsolved type
                         return new UnsolvedType(mToken.Value);
            }
        }
        
        // Delegate Type
        if(mToken.Type == TokenType.KwDef)
        {
        }

        //assert(mToken.Type == TokenType.Identifier);
      
        //x -> Identifier
        //int -> Identifier (BuiltIn Type)
        //x[] -> Identifier Array
        //x!x -> Identifier!Identifier Template instantiation -> temp
        //x!(a,b) -> Identifier!(DataType list) Template instantiation
        //def(a,b):c -> Delegate/FunctionType (datatypes) datatypes
        //x.y.z -> DotIdentifier 
        //x.y.z[ -> Array(DotIdentifier)
        //x.y.z!
        //x.y.z* -> Pointer Type
        
        //[ x | xxx] -> constraints?
        
        //TODO Implement parseDataType 

        return OpaqueType.Instance;
    }

 
    /**
    * Get type for an identifier
    * return Opaque Type when not resolved
    * TODO this is a semantic step remove???
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
    * Get current token value
    */
    private string value()
    {
        return mToken.Value;
    }

    /**
    * next n token
    */
    private void next(uint n = 1)
    {
        while(n > 0)
        {
            mToken = mLex.getToken();
            n--;
        }
    }

    /**
    * next with type check
    */
    private bool next(TokenType t)
    {
        next();
        return mToken.Type == t ? true : false;
    }

    /**
    * Peek token type
    */
    private TokenType peek(ushort lookahead = 1)
    {
        return mLex.peekToken(lookahead).Type;
    }

    /**
    * Error Event
    */
    private void Error(Location loc, string message, string file = __FILE__, size_t line = __LINE__)
    {
        log.Error(message);
        throw new ParserException(loc, message, file, line);
    }

    /**
    * Warning Event
    */
    private void Warning(Location loc, string msg)
    {
        log.Warning("(%s): %s", loc, msg);
    }


    /**
    * Assert Type
    */
    private void assertType(TokenType t)
    {
        if(mToken.Type != t)
            throw new ParserException(mToken.Loc, format("Expected %s not %s", dlf.dis.Token.toString(t), mToken.toString()));
    }

    /**
    * Assert Type (array variant)
    */
    private void assertType(TokenType[] tt)
    {
        if(!isIn(mToken.Type, tt))
            throw new ParserException(mToken.Loc, format("Expected [] not %s", mToken.toString()));
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
    * Log Event
    */
    @property
    ref LogEvent OnLog()
    {
        return log.OnLog;
    }

    ///@property public ParseResult Result();

    /**
    * Parser Exception
    */
    public static class ParserException : Exception
    {
        ///Contruct new parser Exception
        private this(Location loc, string message, string file = __FILE__, size_t line = __LINE__)
        {
            super(format("(%s): %s", loc.toString(), message), file, line);
        }
    }
} 

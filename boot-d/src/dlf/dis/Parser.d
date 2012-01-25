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

    /// Current flags
    private DeclarationFlags flags;

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
        InternalTypes["ptr"] = VoidType.Instance.PtrInstance;
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
        //create a event hook for some kind of tokens for example to parse comment tokens
        //the tokens does not go through regular getToken function of lexer?
        
        //go to first token
        next();
    }


    //=========================================================================
    //== Declarations =========================================================
    //=========================================================================

    //public Declaration parseDeclaration();

    /**
    * Parse package
    */
    public PackageDeclaration parsePackage()
    {
        //package identifier;
        checkType(TokenType.KwPackage);
        
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
            accept(TokenType.Identifier, "Expected Identifier for Package Keyword Parameter");
            
            switch(mToken.Value)
            {
                case "nr": pkg.RuntimeEnabled = false; break;
                default: Error(mToken.Loc, "Not kown Package Keyword Parameter");
            }
            
            accept(TokenType.RCBracket, "Expected ) after Package Keyword Parameter");
        }

        //parse package identifier
        accept(TokenType.Identifier, "Expected Identifier after package");
        auto di = parseIdentifierExpression();
        pkg.Name = di.toString();

        //Look for semicolon
        accept(TokenType.Semicolon, "Expected Semicolon after package declaration");

        //parseDeclarations([ListOfAllowedDeclarations]);

        //parse rest of package
        while(mToken.Type != TokenType.EOF)
        {
            next();
            //parseDeclarations

            //parseDeclarationFlags();

            switch(mToken.Type)
            { 
            //import
            case TokenType.KwImport:
                ImportDeclaration imp = parseImport();
                imp.Parent = pkg;
                pkg.Imports ~= imp;
                break;
            //function
            case TokenType.KwDef:
                //TODO give symbol table as scope?
                FunctionDeclaration dcl = parseDef(); 
                dcl.Parent = pkg;

                pkg.SymTable.assign(dcl, (FunctionDeclaration existing, FunctionDeclaration newOne)
                {
                    debug log.Information("Add override to function %s", existing.Name);
                    existing.Overrides ~= newOne;
                });
                //assign here
                break;
            //struct
            case TokenType.KwStruct:
                Declaration dcl = parseStruct();
                dcl.Parent = pkg;

                pkg.SymTable.assign(dcl, (Declaration existing, Declaration newOne)
                {
                    Error(newOne.Loc, "Can't override structures");
                });
                break;
            //class
            case TokenType.KwObj:
                Declaration dcl = parseClass();
                dcl.Parent = pkg;
                
                pkg.SymTable.assign(dcl, (Declaration existing, Declaration newOne)
                {
                    Error(newOne.Loc, "Can't override class names, please use templated classes instead");
                });
                break;

            case TokenType.KwType:
                Declaration dcl = parseType();
                dcl.Parent = pkg;

                pkg.SymTable.assign(dcl, (Declaration existing, Declaration newOne)
                {
                    Error(newOne.Loc, "Can't override type declarations");
                });
                
                break;
  
            //Variables
            case TokenType.KwVar:
                Error(mToken.Loc, "Variable in Package not yet implemented");
                break;

            //Value Type (immutable)
            case TokenType.KwLet:
                Error(mToken.Loc, "Let in Package not yet implemented");
                break;

            //Trait Type
            case TokenType.KwTrait:
                Error(mToken.Loc, "Trait in Package not yet implemented");
                break;

            case TokenType.EOF:
                break;
            default:
                log.Information("Not valid token in package declaration: %s", mToken.toString());
                Error(mToken.Loc, "Not valid package element");
            }
        }

        return pkg;
    }

    /**
    * Parse Import Declaration
    */
    private ImportDeclaration parseImport()
    {
        //import std.io.stream;
        checkType(TokenType.KwImport);
        auto imp = new ImportDeclaration;
        imp.Loc = mToken.Loc;

        //import followed by identifier import foo = asdasd
        
        accept(TokenType.Identifier, "parseImport: expect identifier after import keyword");

        imp.ImportIdentifier.append(mToken.Value);

        while(peek(1) == TokenType.Dot)
        {
            next;
            switch(peek(1))
            {
                case TokenType.Identifier: 
                    next; imp.ImportIdentifier.append(mToken.Value); break;
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
        checkType(TokenType.KwObj);

        // class(kw param) identifier(template args) : inherits {

        Error(mToken.Loc, "Class Parsing not yet supported");
        return null;
    }

    /**
    * Parse Method Definitions
    */
    private FunctionDeclaration parseDef()
    {
        //top level node must be PackageDeclaration,(ClassDeclaration) 
        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        checkType(TokenType.KwDef);

        auto func = new FunctionDeclaration();
        func.ReturnType = OpaqueType.Instance;
        func.Loc = mToken.Loc;
    
        //TODO assign annotations, attributes parsed before

        //optional: Parse Calling Convention
        if(peek(1) == TokenType.ROBracket)
        {
            next;
            //identifier aka calling convention
            accept(TokenType.Identifier, "parseDef: Expected Identifier for Calling Convention");
            
            switch(mToken.Value.toLower())
            {
            case "c": func.CallingConv = CallingConvention.C; break;
            case "dis": func.CallingConv = CallingConvention.Dis;break;
            default: Error(mToken.Loc, "Invalid CallingConvention");
            }
            
            accept(TokenType.RCBracket, "parseDef: Expected ) for Calling Conventions");
        }

        accept(TokenType.Identifier, "parseDef: missing function identifier");

        //get name
        func.Name = mToken.Value;

        //optional: Parse Parameter
        if(peek(1) == TokenType.ROBracket)
        {
            next(); //mToken = ROBracket

            if(peek(1) != TokenType.RCBracket)
            {
                while(true)
                {
                    next;
                    func.Parameter ~= parseDefParameter();
                    if(peek(1) == TokenType.Comma)
                    {
                        next;
                        continue;
                    }
                    else
                        next;

                    break;
                }
                if(mToken.Type != TokenType.RCBracket)
                    Error(mToken.Loc, "parseDef: expected ) after parameters"); 
            }
            else
                next;
        }
        

        //optional: look for return value 
        if(peek(1) == TokenType.Colon)
        {
            next; next;
            func.ReturnType = parseDataType();
        }

        //optional: if function declarations closes with ";" it is finished
        if(peek(1) == TokenType.Semicolon)
        {
            next();
            return func;
        }

        //after declaration followed  { or = or ; or is end of declaration
        switch(peek(1))
        {
            //block {}
            case TokenType.COBracket:
                next();
                debug log.Information("function block");
                //parse the block
                auto b = parseBlock();
                b.Parent = func;
                func.Body = b;
                return func;

            // = <statement or expression>
            case TokenType.Assign:
                next();
                auto bdy = new BlockStatement();
                bdy.Parent = func;
                Statement stmt = parseStatement();
                if(stmt.Kind == NodeKind.ExpressionStatement)
                    stmt = new ReturnStatement(to!ExpressionStatement(stmt).Expr);
                stmt.Parent = bdy;
                bdy.Statements ~= stmt;
                func.Body = bdy;
                return func;

            default:
                Error(mToken.Loc, "Missing function body");
        }

        //never got here?
        return null;
    }

    /**
    * parse a single parameter
    */
    private FunctionParameter parseDefParameter()
    {
        //cases:
        //- name
        //- name : type
        //- name... : type
        //- : type
        //- ...

        FunctionParameter param = FunctionParameter();
        param.Type = OpaqueType.Instance;
        param.Index = 0;

        switch(mToken.Type)
        {
        case TokenType.Identifier:
            param.Name = mToken.Value;

            if(peek(1) == TokenType.Vararg)
            {
               next;
               param.Vararg = true;
            }

            if(peek(1) == TokenType.Colon)
            {
                next;
                goto case TokenType.Colon;
            }

            break;
        case TokenType.Colon:
            next;
            param.Type = parseDataType();
            break;

        case TokenType.Vararg:
            //next;
            param.Vararg = true;
            break;

        default:
            Error(mToken.Loc, format("Not expected Token in parseDefParameter: %s", mToken.toString()));
        }

        return param;
    }

    /**
    * Parse Variables
    */
    private VariableDeclaration parseVar()
    {
        //"var", SimpleDeclaration;
        //SimpleDeclaration = Identifier, [":" TypeIdentifier], ["=" Expression];
        checkType(TokenType.KwVar);
        auto var = new VariableDeclaration();
        var.Loc = mToken.Loc;

        //expect Identifier after var
        accept(TokenType.Identifier, "Expect Identifier after var keyword");
        var.Name = mToken.Value;

        switch(peek(1))
        {
            case TokenType.Colon:
                next; next;
                var.VarDataType = parseDataType();
                
                //assign can be followed
                if(peek(1) == TokenType.Assign)
                    goto case TokenType.Assign;
                break;
            case TokenType.Assign:
                next(); //token is now "="-Assign
                next(); //now its start of expression
                auto expr = parseExpression();
                expr.Parent = var;
                var.Initializer = expr;
                break;
            case TokenType.Semicolon:
                break;
            default:
                next();
                Error(mToken.Loc, "Unkown token in variable declaration");
        }
       
        accept(TokenType.Semicolon, "Missing semicolon after variable declaration");

        return var;
    }


    /**
    * Parse a structure
    */
    private StructDeclaration parseStruct()
    {
        //must be struct 
        checkType(TokenType.KwStruct);

        auto st = new StructDeclaration();
        st.SymTable = mSymTable = mSymTable.push(st);
        scope(exit) mSymTable = st.SymTable.pop();

        accept(TokenType.Identifier, "Expect identifier after struct");
        st.Name = mToken.Value;

        next;
        if(mToken.Type == TokenType.Colon)
        {
            next;
            st.BaseIdentifier = parseIdentifierExpression();
        }


        if(mToken.Type == TokenType.Semicolon)
        {
            next;
            return st;
        }

        if(mToken.Type != TokenType.COBracket)
            Error(mToken.Loc, "Expected { for struct declaration");

        //inner struct
        next;
        while(mToken.Type != TokenType.CCBracket)
        {
            switch(mToken.Type)
            {
                case TokenType.Identifier:
                    auto var = new VariableDeclaration();
                    var.Name = mToken.Value;
                    accept(TokenType.Colon, "Expect ':' after field identifier");
                    next;
                    var.VarDataType = parseDataType();

                    st.SymTable.assign(cast(Declaration)var, (Declaration existing, Declaration newOne)
                    {
                        Error(newOne.Loc, "Duplicated field in struct");
                    });
                    accept(TokenType.Semicolon, "Expect ';' after field declaration");

                    debug log.Information("Struct Field %s %s", var.Name, var.VarDataType.toString());
                    next;
                    break;
                case TokenType.KwDef:
                    Error(mToken.Loc, "Functions in structs not yet supported");
                    break;

                default:
                    Error(mToken.Loc, "Invalid token " ~ mToken.toString());
            }
        }

        return st;
    }   

    /**
    * Parse a typedef
    */
    private Declaration parseType()
    {
        //must be struct 
        checkType(TokenType.KwType);

        //type name identifier 
        //type name = 
            //type name = identifier
            //type name = {

        //alias
        //enum
        //variant

        Error(mToken.Loc, "Type Parsing not yet supported");
        return null;
    }

    //=========================================================================
    //== Statements ===========================================================
    //=========================================================================

    /**
    * Parse Statement
    */
    private Statement parseStatement()
    {
        //a Statement can be a statement
        //or an Expression as StatementExpression

        switch(mToken.Type)
        {
        //Block Statement
        case TokenType.COBracket:
            return parseBlock();
        //for, foreach 
        case TokenType.KwFor:
            return parseFor();
        //do-while
        case TokenType.KwDo: 
            return parseDoWhile();
        //while
        case TokenType.KwWhile: 
            return parseWhile();
        //return
        case TokenType.KwReturn:
            next;
            return new ReturnStatement(parseExpression());
        //Expression
        default:
            auto exp = parseExpression();
            accept(TokenType.Semicolon, "Missing semicolon after expression statement");
            auto es =  new ExpressionStatement(exp);
            exp.Parent = es;
            return es;
        }
    }

    /**
    * Parse Block {}
    * Parse Complete Block
    */
    private BlockStatement parseBlock()
    {
        //start token is "{"
        checkType(TokenType.COBracket);

        //TODO symbol table? each block has one?
        auto block = new BlockStatement();
        block.Loc = mToken.Loc;
        block.SymTable = mSymTable = mSymTable.push(block);
        scope(exit) mSymTable = block.SymTable.pop();

        //parse until "}"
        while(mToken.Type != TokenType.CCBracket && peek(1) != TokenType.CCBracket)
        {
            next();
            
            //ignore semicolons
            if(mToken.Type == TokenType.Semicolon)
                continue;

            switch(mToken.Type)
            {
                case TokenType.KwVar:
                    auto var = parseVar();
                    block.SymTable[var.Name] = var;
                    var.Parent = block;
                    continue;

                case TokenType.KwLet:
                case TokenType.KwDef: 
                case TokenType.KwClass:
                case TokenType.KwObj:
                    Error(mToken.Loc, "Not yet implemented");
                    continue;

                default:
                    break;
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
        //accept(TokenType.CCBracket, "expected } after block statement");

       
        
        return block;
    }

    /**
    * Parse a For Loop
    * ForStatement or ForeachStatement
    */
    private Statement parseFor()
    {
        checkType(TokenType.KwFor);
        throw new ParserException(mToken.Loc, "Can't parse for statements at the moment");
    }

    /**
    * Parse While Loop
    */
    private WhileStatement parseWhile()
    {
        checkType(TokenType.KwWhile);
        throw new ParserException(mToken.Loc, "Can't parse while statements at the moment");
    }

    /**
    * Parse Do-While Loop
    */
    private WhileStatement parseDoWhile()
    {
        checkType(TokenType.KwDo);
        throw new ParserException(mToken.Loc, "Can't parse do-while statements at the moment");
    }

    //=========================================================================
    //== Expressions ==========================================================
    //=========================================================================

    /**
    * Parse Expressions
    */
    private Expression parseExpression()
    {
        //parse one expression
        Expression expr = null;

        debug writefln("Parse Expr Loc: %s, Tok: %s", mToken.Loc, mToken);

        switch(mToken.Type)
        {
            // Keyword Expressions
            case TokenType.KwIf: 
                expr = parseIfExpression();
                break;
            case TokenType.KwSwitch: 
                expr = parseSwitchExpression();
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

            //TODO unary pre expressions ++expr, --expr, !expr
            // case TokenType.Not: 

            case TokenType.KwThis: 
                /*identifier?*/
                //expr = parseIdentifierExpression();
                break;
            case TokenType.ROBracket: 
                expr = parseExpression;
                accept(TokenType.RCBracket, "require ) after expression");
                break;
            case TokenType.Identifier:
                /*look under switch*/ 
                expr = parseIdentifierExpression();
                break;
            default:
                Error(mToken.Loc, "No valid token for parse an expression");
        }

        //seems to be a function call "(" after expression/identifier
        if(peek(1) == TokenType.ROBracket)
        {
            next();

            //Create Function Call
            auto call = new CallExpression();
            call.Func = expr;

            while(peek(1) != TokenType.RCBracket)
            {
                //parse calling arguments
                next();

                //parse Expressions for arguments
                auto arg = parseExpression();
                call.Arguments ~= arg;
                
                //accept(TokenType.Comma, "expected ',' between call expression arguments");
            }
            accept(TokenType.RCBracket, "expect ) after call expression");

            //set expression to call expression;
            expr = call;
        }

        //array index expression []
        if(peek(1) == TokenType.AOBracket)
        {
            Error(mToken.Loc, "Array index expressions [] not yet supported");
        }

        
        //check next token for binary expressions
        switch(peek(1))
        {
            case TokenType.Semicolon:
                return expr;

            //Binary Math Expressions
            case TokenType.Add:
            case TokenType.Sub:
            case TokenType.Mul:
            case TokenType.Div:
            //Binary Assign Expression
            case TokenType.Assign:
                next;
                auto be = new BinaryExpression();
                be.Op = getBinaryOperator(mToken.Type);
                be.Left = expr;
                expr.Parent = be;
                next;
                auto right = parseExpression();
                be.Right = right;
                right.Parent = be;
                return be;

            //TODO Unary Post Expressions expr++, expr--

            default:
                return expr;
        }
    }

    /**
    * Get binary operator for token type
    */
    private BinaryOperator getBinaryOperator(TokenType type)
    {
        switch(type)
        {
            //Math Expressions
            case TokenType.Add: return BinaryOperator.Add;
            case TokenType.Sub: return BinaryOperator.Sub;
            case TokenType.Mul: return BinaryOperator.Mul;
            case TokenType.Div: return BinaryOperator.Div;

            //Assign Expressions
            case TokenType.Assign: return BinaryOperator.Assign;

            default: 
                throw new Exception("Not valid binary operator");
        }
    }

    /**
    * Parse If Expression
    */
    private Expression parseIfExpression()
    {
        checkType(TokenType.KwIf);
        Error(mToken.Loc, "TODO: Can't parse If Expressions yet");

        return null;
    }

    /**
    * Parse Switch Expression
    */
    private Expression parseSwitchExpression()
    {
        checkType(TokenType.KwSwitch);
        Error(mToken.Loc, "TODO: Can't parse Switch Expressions yet");
        return null;
    }

    /**
    * Parse Identifier
    */
    private IdentifierExpression parseIdentifierExpression()
    {
        checkType(TokenType.Identifier);

        auto di = new IdentifierExpression();
        di.Loc = mToken.Loc;
        di.append(mToken.Value);

        //expect dot
        bool expDot = true;

        while((peek(1) == TokenType.Identifier) || (peek(1) == TokenType.Dot))
        {              
            next();
            //identifier
            if(expDot && mToken.Type == TokenType.Identifier)
            {
                Error(mToken.Loc, "expected dot to seperate identifiers");
            }   
            //dot
            if(!expDot && mToken.Type == TokenType.Dot)
            {
                Error(mToken.Loc, "expected identifier after dot");
            }
            
            expDot = !expDot;
            
            if(mToken.Type == TokenType.Identifier)
                di.append(mToken.Value);
        }

        return di;
    }

    /**
    * Parse Annotation
    */
    private Annotation parseAnnotation()
    {
        // Annotions: @identifier
        checkType(TokenType.Annotation);

        accept(TokenType.Identifier, "Expected Identifier after @ for Annotations");

        switch(mToken.Value)
        {
            case "unittest":
                auto uta = new UnitTestAnnotation();
                uta.Loc = mToken.Loc;
                return uta; 
            default:
                Error(mToken.Loc, "Invalid annotation");
        }
        
        //never get here
        throw new Exception("");
    }

    /**
    * Parse a datatype
    */
    private DataType parseDataType()
    {
        //TODO Complete parseDataType 

        //x -> Identifier
        //int -> Identifier (BuiltIn Type)
        //x[] -> Identifier Array
        //x!x -> Identifier!Identifier Template instantiation -> temp
        //x!(a,b) -> Identifier!(DataType list) Template instantiation
        //def(a,b):c -> Delegate/FunctionType (datatypes) datatypes
        //x.y.z -> DotIdentifier 
        //x.y.z[ -> Array(DotIdentifier)
        //x.y.z! -> Template instantiation
        //x.y.z* -> Pointer Type
        //[ x | xxx] -> constraints?

        // Identifier
        if(mToken.Type == TokenType.Identifier)
        {

            //TODO parseDataTypes
            switch(peek(1))
            {
                //. - composite datatype
                case TokenType.Dot: 
                    Error(mToken.Loc, "composited datatypes not yet supported");
                    break;

                //[ (datatype) ]
                case TokenType.AOBracket: 
                    Error(mToken.Loc, "array datatypes not yet supported");
                    break;

                //! datatype -> parseDataType
                //!(datatypes)
                case TokenType.Not: 
                    Error(mToken.Loc, "template instance datatypes not yet supported");
                    break;

                case TokenType.Mul:
                     Error(mToken.Loc, "pointer datatypes not yet supported");
                    //ptr(Foobar) instead of Foobar*
                    // identifier.length -= 1;
                    // return new PointerType(InternalTypes.get(identifier, OpaqueType.Instance));
                    //pointer type
                    break;

                default: 
                         //InternalTypes[mToken.Value]
                         //internal lookup
                         //parse
                         //return unsolved type
                         //presolving
                         return InternalTypes.get(mToken.Value, new UnsolvedType(mToken.Value));
            }
            
        }
        
        // Delegate Type
        if(mToken.Type == TokenType.KwDef)
        {
            Error(mToken.Loc, "delegate types not yet supported");
        }


        if(mToken.Type == TokenType.AOBracket)
        {
            Error(mToken.Loc, "constraint types not yet supported");
        }

        Error(mToken.Loc, "Not a valid datatype");
        return OpaqueType.Instance;
    }

    /**
    * Parse Flags
    */
    private void parseDeclarationFlags()
    {
        //parse all available flags
        switch(mToken.Type)
        {
            case TokenType.KwPrivate:
                flags &= DeclarationFlags.Private;
                next;
                parseDeclarationFlags();
                break;
            case TokenType.KwPublic:
                flags &= DeclarationFlags.Public;
                next;
                parseDeclarationFlags();
                break;
            case TokenType.KwProtected:
                flags &= DeclarationFlags.Protected;
                next;
                parseDeclarationFlags();
                break;
            default:
                return;
        }
    }

    /**
    * Assign Declaration Flags
    */
    private void assignDeclarationFlags(Declaration d)
    {
        d.Flags = flags;
        flags = DeclarationFlags.Blank;
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
    * Require a special type next
    */
    private void accept(TokenType t, string error, string file = __FILE__, size_t line = __LINE__)
    {
        next();
        if(mToken.Type != t)
            Error(mToken.Loc, error, file, line);
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
    private void checkType(TokenType t)
    {
        if(mToken.Type != t)
            throw new ParserException(mToken.Loc, format("Expected %s not %s", dlf.dis.Token.toString(t), mToken.toString()));
    }

    /**
    * Assert Type (array variant)
    */
    private void checkType(TokenType[] tt)
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

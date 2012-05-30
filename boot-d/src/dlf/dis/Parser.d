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
    private scope Lexer lexer;

    /// Current Token
    private Token mToken;

    /// Symbol Tables
    private Stack!(SymbolTable*) symTables = Stack!(SymbolTable*)(128);

    /// Current flags
    private DeclarationFlags flags;

    /// Current Annotations
    private Annotation[] annotations;

    /// Internal Types (Builtin)
    public static DataType[string] InternalTypes;

    //currentScope { Package, Class, Function, Trait, }

    /**
    * Ctor
    */
    public this()
    {
        lexer = new Lexer();
    }

    /**
    * Static Dtor
    */
    public static this()
    {
        //Primary
        InternalTypes["void"] = VoidType.Instance;
        InternalTypes["bool"] = BoolType.Instance;
        InternalTypes["byte8"] = Byte8Type.Instance;
        InternalTypes["ubyte8"] = UByte8Type.Instance;
        InternalTypes["short16"] = Short16Type.Instance;
        InternalTypes["ushort16"] = UShort16Type.Instance;
        InternalTypes["int32"] = Int32Type.Instance;
        InternalTypes["uint32"] = UInt32Type.Instance;
        InternalTypes["long64"] = Long64Type.Instance;
        InternalTypes["ulong64"] = ULong64Type.Instance;
        InternalTypes["float32"] = Float32Type.Instance;
        InternalTypes["double64"] = Double64Type.Instance;
    }

    /**
    * Load a source object
    */
    public void load(Source src)
    {
        if(src is null || src.isEof)
            throw new Exception("No Source available");

        //clean up state
        flags = DeclarationFlags.Blank;
        annotations.length = 0;

        //open source file and set ignore tokens
        lexer.load(src);
        lexer.Ignore = [TokenType.Comment, TokenType.DocComment, TokenType.EOL];
        //create a event hook for some kind of tokens for example to parse comment tokens
        //the tokens does not go through regular getToken function of lexer?
        
        //go to first token
        next();
    }


    /**
    * Generic Parse try to parse something
    * return null when nothing match
    * can only parse keyword initial starts
    */
    private Node parse()
    {
        switch(mToken.Type)
        { 
            //Import
            case TokenType.KwImport: return parseImport();

            //Instance Decl
            case TokenType.KwVar: return parseVar();
            case TokenType.KwLet: return parseLet();

            //Type Decl
            case TokenType.KwDef: return parseDef();
            case TokenType.KwStruct: return parseStruct();
            case TokenType.KwObj: return parseClass();
            case TokenType.KwTrait: return parseTrait();
            case TokenType.KwType: return parseType();
            
            //Other
            case TokenType.Annotation: return parseAnnotation();

            default: return null;
        }
    }


    //=========================================================================
    //== Declarations =========================================================
    //=========================================================================

    //public Declaration[] parseDeclarations();

    /**
    * Parse package
    */
    public PackageDecl parsePackage()
    {
        //package identifier;
        checkType(TokenType.KwPackage);
        
        //Create new Package Declaration
        auto pkg = new PackageDecl();
        pkg.Loc = mToken.Loc;
        pkg.modificationDate = Src.modificationDate;
        pkg.SymTable = SymbolTable(pkg);
        symTables.push(&pkg.SymTable);
        scope(exit) symTables.pop();

        //parameterized keywords
        if(peek(1) == TokenType.ROBracket)
        {
            next(1);
            auto kwParams = parseKeywordParameter();
            foreach(p; kwParams)
            {
                switch(p)
                {
                case "nr": pkg.RuntimeEnabled = false; break;
                default: Error(mToken.Loc, "Not kown Package Keyword Parameter");
                }
            }
        }

        //parse package identifier
        next; checkType(TokenType.Identifier, __traits(identifier, parsePackage));

        pkg.PackageIdentifier.append(mToken.Value);

        while(peek(1) == TokenType.Dot)
        {
            next;
            switch(peek(1))
            {
                case TokenType.Identifier: 
                    next; pkg.PackageIdentifier.append(mToken.Value); break;
                default:
                    Error(mToken.Loc, "parsePackage: expect identifier dot");
            }
        }

        pkg.Name = pkg.PackageIdentifier.toString();

        //Look for semicolon
        next; checkType(TokenType.Semicolon, __traits(identifier, parsePackage));

        //parse rest of package
        while(mToken.Type != TokenType.EOF)
        {
            next();
            if(mToken.Type == TokenType.EOF) return pkg;

            parseDeclarationFlags();

            Node n = parse();
            if(n is null)
            {
                log.Information("Not valid token in package declaration: %s", mToken.toString());
                Error(mToken.Loc, "Not valid package element");
            }

            n.Parent = pkg;
            
            switch(n.Kind)
            { 
            //import
            case NodeKind.ImportDecl:
                pkg.Imports ~= n.to!ImportDecl;
                break;
            //function
            case NodeKind.FunctionDecl:
                auto dcl = n.to!FunctionDecl;
                assignAnnotations(dcl);
                assignDeclarationFlags(dcl);
                pkg.SymTable.assign(dcl, &symFuncAssign);
                break;
            //struct
            case NodeKind.StructDecl:
                pkg.SymTable.assign(n.to!StructDecl, genNoAssign!StructDecl("Can't override structures"));
                break;
            //class
            case NodeKind.ClassDecl:
                pkg.SymTable.assign(n.to!ClassDecl, genNoAssign!ClassDecl("Can't override class names, please use templated classes instead"));
                break;
            //Trait Type
            case NodeKind.TraitDecl:
                Error(mToken.Loc, "Trait iblock.SymTablen Package not yet implemented");
                break;
            //type
            case NodeKind.AliasDecl:
            case NodeKind.EnumDecl:
            case NodeKind.VariantDecl:
                pkg.SymTable.assign(n.to!TypeDecl, genNoAssign!TypeDecl("Can't override type declarations"));
                break;

            //Variables
            case NodeKind.VarDecl:
                pkg.SymTable.assign(n.to!VarDecl, genNoAssign!VarDecl("Can't override variable declarations"));
                break;
            //Value Type (immutable)
            case NodeKind.ValDecl:
                pkg.SymTable.assign(n.to!ValDecl, genNoAssign!ValDecl("Can't override value declarations"));
                break;
            //@Annotations/Attributes
            case TokenType.Annotation:
                annotations ~= n.to!Annotation;
                break;

            default:
            }
        }

        return pkg;
    }

    /**
    * Parse Import Declaration
    */
    private ImportDecl parseImport()
    {
        //import std.io.stream;
        checkType(TokenType.KwImport);
        auto imp = new ImportDecl;
        imp.Loc = mToken.Loc;

        //import followed by identifier import foo = asdasd
        
        next; checkType(TokenType.Identifier, __traits(identifier, parseImport));
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

        next; checkType(TokenType.Semicolon, __traits(identifier, parseImport));
        
        return imp;
    }

    /**
    * Parse a Class
    */
    private ClassDecl parseClass()
    {
        //SYNTAX: class(kw param) identifier(template args) : inherits {
        
        //must be class class
        checkType(TokenType.KwObj);
        auto classDecl = new ClassDecl();

        //parseKeywordParameter();


        next; checkType(TokenType.Identifier, __traits(identifier, parseClass));
        classDecl.Name = mToken.Value;

        //template ()
        if(peek(1) == TokenType.ROBracket)
        {
            Error(mToken.Loc, "Template Class Parsing not yet supported");
        }

        //inheritance
        if(peek(1) == TokenType.Colon)
        {
            next;
            parseDataType();
            // comma value for multi-inheritance and traits
        }
        
        next; checkType(TokenType.COBracket, __traits(identifier, parseClass));


        //parseDeclarations();
         

        Error(mToken.Loc, "Class parsing not yet implemented");
        return null;
    }

    /**
    * Parse Trait
    */
    private TraitDecl parseTrait()
    {
        checkType(TokenType.KwTrait);
        Error(mToken.Loc, "Trait parsing not yet implemented");
        return null;
    }

    /**
    * Parse Method Definitions
    */
    private FunctionDecl parseDef()
    {
        //top level node must be PackageDecl,(ClassDecl) 
        //def{(Calling Convention)} Identifier(Parameter) ReturnType
        // Block {}
        checkType(TokenType.KwDef);

        auto func = new FunctionDecl();
        func.ReturnType = OpaqueType.Instance;
        func.Loc = mToken.Loc;
        func.SymTable = SymbolTable(func);
        symTables.push(&func.SymTable);
        scope(exit) symTables.pop();

        //optional: Parse Calling Convention
        if(peek(1) == TokenType.ROBracket)
        {
            next(1);
            auto kwParams = parseKeywordParameter();
            foreach(p; kwParams)
            {
                switch(p)
                {
                case "c": func.CallingConv = CallingConvention.C; break;
                case "dis": func.CallingConv = CallingConvention.Dis;break;
                default: Error(mToken.Loc, "Invalid CallingConvention");
                }
            }
        }

        next; 
        checkType(TokenType.Identifier, __traits(identifier, parseDef));
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
                    //add to symbol table?
                    auto p = parseDefParameter();
                    func.Parameter ~= p;
                    
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
            next(2);
            func.ReturnType = parseDataType();
        }

        //optional: if function declarations closes with ";" it is finished
        if(peek(1) == TokenType.Semicolon)
        {
            next;
            return func;
        }

        //after declaration followed  { or = or ; or is end of declaration
        switch(peek(1))
        {
            //block {}
            case TokenType.COBracket:
                next;
                debug log.Information("function block");
                //parse the block
                auto b = parseBlock();
                b.Parent = func;
                func.Body ~= b;
                return func;

            // = <statement or expression>
            case TokenType.Assign:
                //TODO let semantic rewrite it
                next();
                auto bdy = new BlockStmt();
                bdy.Parent = func;
                Statement stmt = parseStatement();
                if(stmt.Kind == NodeKind.ExpressionStmt)
                    stmt = new ReturnStmt(to!ExpressionStmt(stmt).Expr);
                stmt.Parent = bdy;
                bdy.Statements ~= stmt;
                func.Body ~= bdy;
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
    private VarDecl parseVar()
    {
        //"var", SimpleDeclaration;
        //SimpleDeclaration = Identifier, [":" TypeIdentifier], ["=" Expression];
        checkType(TokenType.KwVar);
        auto var = new VarDecl();
        var.Loc = mToken.Loc;

        //expect Identifier after var
        next; 
        checkType(TokenType.Identifier, "Expect Identifier after var keyword");
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
       
        next; 
        checkType(TokenType.Semicolon, "Missing semicolon after variable declaration");

        return var;
    }

    /**
    * Parse value
    */
    private ValDecl parseLet()
    {
        checkType(TokenType.KwLet);
        Error(mToken.Loc, "Value parsing not yet implemented");
        return null;
    }


    /**
    * Parse a structure
    */
    private StructDecl parseStruct()
    {
        //must be struct 
        checkType(TokenType.KwStruct);

        auto st = new StructDecl();
        st.SymTable = SymbolTable(st);
        symTables.push(&st.SymTable);
        scope(exit) symTables.pop();

        //struct name
        next; 
        checkType(TokenType.Identifier, "Expect identifier after struct");
        st.Name = mToken.Value;

        //inheritance
        next;
        if(mToken.Type == TokenType.Colon)
        {
            next;
            st.BaseType = parseDataType();
            next;
        }

        //definition
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
                    auto var = new VarDecl();
                    var.Name = mToken.Value;
                    next;
                    checkType(TokenType.Colon, "Expect ':' after field identifier");
                    next;
                    var.VarDataType = parseDataType();

                    //TODO not twice
                    st.SymTable[var.Name] = var;

                    next;
                    checkType(TokenType.Semicolon, "Expect ';' after field declaration");

                    debug log.Information("Struct: %s Field: %s %s", st.Name, var.Name, var.VarDataType.toString());
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
    private TypeDecl parseType()
    {
        //must be struct 
        checkType(TokenType.KwType);

        next;
        checkType(TokenType.Identifier, "Require name for type");

        switch(peek(1))
        {

        //alias
        case TokenType.Identifier:
            auto al = new AliasDecl();
            al.Name = mToken.Value;
            next;
            al.AliasType = parseDataType();
            next; checkType(TokenType.Semicolon, "Expects semicolon after declaration");            
            return al;


        case TokenType.Colon:
            //its a enum
            break;

        case TokenType.Assign:
            peek(2); //Indentifier vs { 
            
            break;
        //enum
        //variant

        default:
            next;
            Error(mToken.Loc, "parseType: No expected token");
        }

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
            auto expr = parseExpression();
            auto ret =  new ReturnStmt(expr);
            expr.Parent = ret;
            return ret;
        //Expression
        default:
            auto exp = parseExpression();
            auto es =  new ExpressionStmt(exp);
            exp.Parent = es;

            next;
            checkType(TokenType.Semicolon, "Missing semicolon after expression statement");
            return es;
        }
    }

    /**
    * Parse Block {}
    * Parse Complete Block
    */
    private BlockStmt parseBlock()
    {
        //start token is "{"
        checkType(TokenType.COBracket);

        //TODO symbol table? each block has one?
        auto block = new BlockStmt();
        block.Loc = mToken.Loc;
        block.SymTable = SymbolTable(block);
        symTables.push(&block.SymTable);
        scope(exit) symTables.pop();

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
                    var.Parent = block;
                    block.SymTable[var.Name] = var;
                    continue;

                case TokenType.KwLet:
                case TokenType.KwConst:
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
        //checkType(TokenType.CCBracket, "expected } after block statement");

       
        
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
    private WhileStmt parseWhile()
    {
        checkType(TokenType.KwWhile);
        throw new ParserException(mToken.Loc, "Can't parse while statements at the moment");
    }

    /**
    * Parse Do-While Loop
    */
    private WhileStmt parseDoWhile()
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
                expr = parseIfExpr();
                break;
            case TokenType.KwSwitch: 
                expr = parseSwitchExpr();
                break;

            //ref expr
            //ptr expr

            // Literal Expressions
            //TODO Pay Attention for next Token when it is an op
            case TokenType.String:
                auto litType = ArrayType.createArrayLiteral(mToken.Value.length);
                expr = new LiteralExpr(mToken.Value, litType);
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Char:
                // ref fixed size byte array
                auto litType = ArrayType.createArrayLiteral(mToken.Value.length);
                expr =  new LiteralExpr(mToken.Value, litType); 
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Integer:
                expr = new LiteralExpr(mToken.Value, Int32Type.Instance); 
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Float:
                expr = new LiteralExpr(mToken.Value, Float32Type.Instance); 
                expr.Loc = mToken.Loc;
                break;
            case TokenType.Double:
                expr = new LiteralExpr(mToken.Value, Double64Type.Instance);
                expr.Loc = mToken.Loc;
                break;
            case TokenType.KwTrue:
            case TokenType.KwFalse:
                expr = new LiteralExpr(mToken.Value, BoolType.Instance);
                expr.Loc = mToken.Loc;
                break;

            //TODO unary pre expressions ++expr, --expr, !expr
            // case TokenType.Not: 

            case TokenType.KwThis: 
                /*identifier?*/
                //this accessor?
                //var te = new ThisExpr();
                break;
            case TokenType.ROBracket: 
                expr = parseExpression;
                next;
                checkType(TokenType.RCBracket, "require ) after expression");
                break;
            case TokenType.Identifier:
                /*look under switch*/ 
                auto ie = new IdExpr();
                ie.Id = mToken.Value;
                expr = ie;
                break;

            //case [] for array initializer

            case TokenType.Dollar:
                Error(mToken.Loc, "Compile time functions not yet implemented");
                break;

            default:
                Error(mToken.Loc, "No valid token for parse an expression");
        }

        //seems to be a function call "(" after expression/identifier
        if(peek(1) == TokenType.ROBracket)
        {
            next();

            //Create Function Call
            auto call = new CallExpr();
            call.Func = expr;

            //TODO named args

            while(peek(1) != TokenType.RCBracket)
            {
                //parse calling arguments
                next();

                //parse Expressions for arguments
                auto arg = parseExpression();
                arg.Parent = call;
                call.Arguments ~= arg;
                
                //checkType(TokenType.Comma, "expected ',' between call expression arguments");
            }
            next;
            checkType(TokenType.RCBracket, "expect ) after call expression");

            //set expression to call expression;
            expr = call;
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
                auto be = new BinaryExpr();
                be.Op = getBinaryOperator(mToken.Type);
                be.Left = expr;
                expr.Parent = be;
                next;
                auto right = parseExpression();
                be.Right = right;
                right.Parent = be;
                return be;

            case TokenType.Dot:
                auto de = new DotExpr();
                expr.Parent = de;

                de.Left = expr;
                next(2);
                de.Right = parseExpression();
                de.Right.Parent = de;
                return de;

            //TODO Unary Post Expressions expr++, expr--, [] ?


            //array index expression []
            case TokenType.AOBracket:
                //[expr], [:expr], [expr:expr]
                Error(mToken.Loc, "Array index expressions [] not yet supported");
                break;

            default:
                return expr;
        }

        return expr;
    }

    /**
    * Get binary operator for token type
    */
    private final static BinaryOperator getBinaryOperator(TokenType type)
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
    private Expression parseIfExpr()
    {
        checkType(TokenType.KwIf);
        Error(mToken.Loc, "TODO: Can't parse If Expressions yet");

        return null;
    }

    /**
    * Parse Switch Expression
    */
    private Expression parseSwitchExpr()
    {
        checkType(TokenType.KwSwitch);
        Error(mToken.Loc, "TODO: Can't parse Switch Expressions yet");
        return null;
    }

    /**
    * Parse Annotation
    */
    private Annotation parseAnnotation()
    {
        // Annotions: @identifier
        checkType(TokenType.Annotation);

        next;
        checkType(TokenType.Identifier, "Expected Identifier after @ for Annotations");

        switch(mToken.Value)
        {
            case "unittest":
            case "test":
                auto uta = new TestAnnotation();
                uta.Loc = mToken.Loc;
                return uta; 
            default:
                Error(mToken.Loc, "Invalid annotation");
        }
        
        //never get here
        throw new Exception("");
    }

    private string[] parseKeywordParameter()
    {
        checkType(TokenType.ROBracket, __traits(identifier, parseKeywordParameter));
        
        string[] kwParams;
        
        while(true)
        {
            next;
            checkType(TokenType.Identifier);
            kwParams ~= mToken.Value;
            
            next;
            if(mToken.Type == TokenType.Comma)
                continue;
            else if(mToken.Type == TokenType.RCBracket)
                break;
            else
                Error(mToken.Loc, "Invalid Token %s".format(mToken.toString()));   
        }

        checkType(TokenType.RCBracket, __traits(identifier, parseKeywordParameter));

        return kwParams;
    }

    /**
    * Parse a datatype
    */
    private DataType parseDataType()
    {
        //TODO Complete parseDataType 
        //TODO Parse Options inner datatypes are retricted

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
        //ref x -> reference type
        //ptr y -> pointer type

        // Identifier
        if(mToken.Type == TokenType.Identifier)
        {

            //TODO parseDataType
            switch(peek(1))
            {
                //. - composite datatype
                case TokenType.Dot: 
                    auto dt = new DotType();
                    dt.Value = mToken.Value;
                    next(2);
                    dt.Right = parseDataType();
                    dt.Right.Parent = dt;
                    return dt;

                //[ (datatype) ]
                case TokenType.AOBracket: 
                    //Array Size Number Token
                    Error(mToken.Loc, "array datatypes not yet supported");
                    break;

                //! datatype -> parseDataType
                //!(datatypes)
                case TokenType.Not: 
                    //TODO Use DeclarationType here? rename templatetype?
                    Error(mToken.Loc, "template instance datatypes not yet supported");
                    break;

                case TokenType.KwRef:
                    next;
                    auto reftype = new RefType();
                    reftype.TargetType = parseDataType();
                    return reftype;

                case TokenType.KwPtr:
                    next;
                    auto ptrtype = new PtrType(parseDataType());
                    return ptrtype;

                default:
                    //IdType
                    //InternalTypes[mToken.Value]
                    //internal lookup
                    //parse
                    //return unsolved type
                    //presolving
                    auto preType = new DotType();
                    preType.Value = mToken.Value;
                    return InternalTypes.get(mToken.Value, preType);
            }
            
        }
        
        // Delegate Type
        if(mToken.Type == TokenType.KwDef)
        {
            //def(datatype,...) : datatype
            Error(mToken.Loc, "delegate types not yet supported");
            //return function type
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
    * Assign Declaration Flags and clear them
    */
    private void assignDeclarationFlags(Declaration d)
    {
        d.Flags = flags;
        flags = DeclarationFlags.Blank;
    }

    /**
    * Assign Annotations and clear them
    */
    private void assignAnnotations(Declaration d)
    {
        d.Annotations = annotations;
        annotations.length = 0;
    }

    /**
    * Helper for symbol table assigns
    */
    private auto genNoAssign(T)(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        return (T existing, T newOne)
        {
            Error(newOne.Loc, msg, file, line);
        };
    }

    /**
    * sym table function assign
    */
    private void symFuncAssign(FunctionDecl existing, FunctionDecl newOne)
    {
        debug log.Information("Add override to function %s", existing.Name);
        existing.Overrides ~= newOne;
    }

    /**
    * next n token
    */
    private void next(uint n = 1)
    {
        while(n > 0)
        {
            mToken = lexer.nextToken();
            n--;
        }
    }

    /**
    * Peek token type
    */
    private TokenType peek(ushort lookahead = 1)
    {
        return lexer.peekToken(lookahead).Type;
    }

    /**
    * Assert Type
    */
    private void checkType(TokenType t, string reason="",  string file = __FILE__, size_t line = __LINE__)
    {
        if(mToken.Type != t)
            throw new ParserException(mToken.Loc, format("Expected %s not %s: %s", dlf.dis.Token.toString(t), mToken.toString(), reason), file, line);
    }

    /**
    * Assert Type (array variant)
    */
    private void checkTypes(TokenType[] tt, string file = __FILE__, size_t line = __LINE__)
    {
        //TODO better message format
        if(!isIn(mToken.Type, tt))
            throw new ParserException(mToken.Loc, format("Expected [] not %s", mToken.toString()), file, line);
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
    * Get source 
    */
    @property 
    public Source Src()
    {
        return lexer.Src;
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

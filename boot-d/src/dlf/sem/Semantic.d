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
module dlf.sem.Semantic;

import std.string;

import dlf.basic.Log;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Annotation;
import dlf.ast.Type;
import dlf.ast.SymbolTable;

import dlf.sem.DeclAnalysis;
import dlf.sem.TypeAnalysis;

import std.stdio;

//TODO Add Initializer Expressions for builtin data types

/**
* Semantic Pass for AST
*/
class Semantic : Visitor
{
    //Semantic Logger
    private LogSource log = Log("Semantic");

    /// Current Symbol Table
    private SymbolTable mSymTable;

    //rules
    //semantic passes?

    //Type stack name -> Type 
    //Stack!(Type[char[]])

    //save main declaration
    //current package forbids runtime functions?

    //check all datatypes if a runtime type is used

    //context? libraries doesnt have a main function?

    //Functions for types (resolving)
    mixin TypeAnalysis;

    //Functions for declarations
    mixin DeclAnalysis;


    /**
    * Run semantic passes 
    * Parse Tree -> AST
    */
    public Node run(Node astNode)
    {
        //TODO Multiple Runs?
        return dispatch(astNode, this);
    }

    /**
    * Run semantic for a package
    */
    public PackageDeclaration run(PackageDeclaration pd)
    {
        return autoDispatch(pd);
    }

    /**new CPackage()
    * Visit PackageDeclaration
    */
    void visit(PackageDeclaration pack)
    {
        Information("Semantic: Package %s", pack.Loc.Name);

        mSymTable = pack.SymTable;

        // Imports
        //add default runtime imports when not available
        mapDispatch(pack.Imports);

        // Variables
        mapDispatch(pack.Variables);

        // Functions
        mapDispatch(pack.Functions);

        //Classes
        mapDispatch(pack.Classes);
    }

    /**
    * Import Declaration
    */
    void visit(ImportDeclaration impDecl)
    {
        // Info
        Information("Semantic: ImportDecl %s", impDecl.Name);

        //semantic check for available PackageDeclarations
        if(impDecl.Package !is null)
        {
            impDecl.Package = autoDispatch(impDecl.Package);
        }
        else
        {
            Error("\tImport %s has not been solved", impDecl.Name);
            fatal("Can't proceed with unsolved import");
        }

        //semantic on package should have been run


        //when a type resolved from import package
        //generate missing declarations? compiler task?
        //Import external types into actual PackageDeclaration 
        //Mark as external 
        //error when a import isn't resolved

        //Remove not required imports
    }

    /**
    * Class Semantic Check
    */
    void visit(ClassDeclaration cls)
    {
        //Cases:
        //  Explicit Class -> One Instance
        //  Template Class -> Multiple Instances -> Multiple BlockStatements

        //when no inheritance parsed
        //add rt.object as default (when no runtime is specific, when runtime disabled error it is required to inherit from)
        //check inheritance templated traits, parent classes
        //visit variabales
        //visit methods
    }

    /**
    * Trait Semantic
    */
    void visit(TraitDeclaration td)
    {
    }

    /**
    * Visit FunctionDeclaration
    */
    void visit(FunctionDeclaration func)
    { 
        Information("Semantic FuncDecl %s", func.Name);

        //Cases:
        // 1. Main Function
        // 2. Declaration
        // 3. Explicit Declaration
        // 4. Template Functions (requires special body for each function, requires copy)

        //first solve parameter array (resolve datatypes, detect complete
        analyzeFuncParam(func);

        //analyze statement and rewrite to block
        analyzeFuncStmt(func);

        //create instance when single

        //special case main function
        if(func.Name == "main")
        {
            Information("Main Function detected");
            analyzeMainFunc(func);
        }

        //if function has no body it is a declaration
        if(func.Body is null)
        {
            //its a declaration
            //it must have unambiguous parameter datatypes
            assert(!func.IsTemplate);
        }

        //if it is not a template there must be one instance
        if(!func.IsTemplate)
        {
            //func.Instances.length == 1
        }

        //go into Body
        if(func.Body !is null)
            func.Body = autoDispatch(func.Body);
    }

     /**
    * Semantic Checks for Variables
    */
    void visit(VariableDeclaration var)
    {
        Information("Semantic: VarDecl %s", var.Name);

        //Do Semantic Analysis for Initializer Expression if available
        if(var.Initializer !is null)
            var.Initializer = autoDispatch(var.Initializer);

        //Set Datatype for Variable
        if(var.VarDataType == OpaqueType.Instance)
        {
            if(var.Initializer !is null)
            {
                var.VarDataType = var.Initializer.ReturnType;
                Information("\tResolved var type: %s", var.VarDataType);
            }
        }

        //DataType of Variable and Initializer must match
        if(var.Initializer !is null)
        {   
            //for class types generate constructor call?
            //check for allowed conversions?
            // implize_t]icit casts check
            Information("\tVarType: %s, InitType: %s", var.VarDataType,var.Initializer.ReturnType); 
            //assert(var.VarDataType == var.Initializer.ReturnType);
        }

    }

    /**
    * Visit Block Statement
    */
    void visit(BlockStatement block)
    {
        Information("Semantic: BlockStmt");

        mSymTable = block.SymTable;

        //analyze the declarations inside of blockstatement
        //what is when parent is function, parameter variables
        
        foreach(Declaration sym; block.SymTable)
            dispatch(sym, this);

        //check each statement
        mapDispatch(block.Statements);

    }

    /**
    * Visit Expression Statement
    */
    void visit(ExpressionStatement expr)
    {
        //visit Expression
        expr.Expr = autoDispatch(expr.Expr);

    }

    /**
    * Visit ReturnStatement
    */
    void visit(ReturnStatement rs)
    {
        //check rs.Expr returntype must match parent return type
    }

    /**
    * Visit Function Call
    */
    void visit(CallExpression call)
    {
        //TODO class Function Calls
        Information("Semantic: FuncCall %s", call.Function.toString());

        //Create Function instances here
        
        //check for function
        //call.mFunction.NType() == NodeType.DotIdentifier
        //Look for parameter type matching
        auto fexpr = call.Function;
        
        //Expression to Function

        if(fexpr.Kind == NodeKind.DotIdentifier)
        {
            Information("\t Is DotIdentifier -> Try to resolve type");
            auto resolve = resolve(cast(DotIdentifier)fexpr);

            if(resolve !is null)
            {
                Information("\t Resolve type: %s", resolve);
                //TODO fix this
                //extend(call.Function, resolve);
                call.Function.Semantic = resolve;
            }
            //look foreach
            //get function declaration
        }

        //check if Function exist
    }

    /**
    * Semantic Pass for DotIdentifier
    */
    void visit(DotIdentifier di)
    {
        // resolve returntype 
        // add node DotIdentifier pointo to Extend
        // auto decl = resolve(DotIdentifier di)
        // -> assign(di, decl);
        // di.ReturnType = decl.Type
    }

    /**
    * Semantic Pass for Assign Expression
    */
    void visit(AssignExpression ae)
    {
        //look for Target must be a declared value?
        //look for type match
    }
    
    /**
    * Semantic Pass for BinaryExpression
    */
    void visit(BinaryExpression be)
    {
        //analyze left and right expression first
        be.Left = autoDispatch(be.Left);
        be.Right = autoDispatch(be.Right);
        
        //look for type match

        //rewrite Binary Expression for none math types
        //detect build in math types
        // a + b ->
        // a.opAdd(b);

        //auto
        //be.replace(new CallExpression(be.Left.ReturnType.Methods["opAssign"].Instance)) //(class)
    
        //calculate literal expressions directly

        //return resulting Expression
    }

    /**
    * Semantic Pass for Literal Expression
    */
    void visit(LiteralExpression le)
    {
        //look for string value?
        //verify string value?
        
    }

    /**
    * Auto Dispatch
    */
    private T autoDispatch(T)(T e)
    {
        return cast(T)dispatch(e, this, true);
    }

    /**
    * Map Dispatch to Arrays
    */
    private void mapDispatch(T)(T[] elements)
    {
        for(int i=0; i < elements.length; i++)
        {
            elements[i] = autoDispatch(elements[i]);
        }
    }

    /**
    * Semantic Information Log
    */
    private void Information(T...)(string s, T args)
    {
        //TODO Change to Events
        //writefln(s, args);
        log.log!(LogType.Information)(s, args);
    }

    /**
    * Semantic Error Log
    */
    private void Error(T...)(string s, T args)
    {
        //TODO Change to Events
        //writefln(s, args);
        log.log!(LogType.Error)(s, args);
    }

    /**
    * Fatal semantic error
    */
    private void fatal(string msg = "")
    {
         throw new SemanticException(msg);
    }

    /**
    * Semantic Assert
    */
    private void assertSem(bool cond, string message)
    {
        if(!cond)
            Error(message);

        fatal(message);
    }

    /**
    * Log Event
    */
    @property
    ref LogEvent OnLog()
    {
        return log.OnLog;
    }
    
    /**
    * Semantic Exception
    */
    public static class SemanticException : Exception
    {
        /// New Semantic Exception
        this(string msg)
        {
            super(msg);
        }
    }
}
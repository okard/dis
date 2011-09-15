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
import dlf.ast.Transform;

import dlf.sem.Valid;

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
        Information("Semantic: PackageDcl");

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
            impDecl.Package = autoDispatch(impDecl.Package);
        else
            Error("\tImport %s has not been solved", impDecl.Name);



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

        //special case main function
        if(func.Name == "main")
        {
            Information("Main Function detected");
            analyzeMainFunc(func);
        }

        //resolve datatypes
        //create instance when single

        if(func.Body is null)
        {
            //its a declaration
            //it must have unambiguous parameter datatypes
            assert(!func.IsTemplate);
        }

        //if(!func.isTemplate one Instance have to Exist


        //if c calling convention only one instance is allowed

        //Check Parameters
        //only one vararg parameter allowed

        /*
        //resolve return value
        if(func.FuncType.ReturnType is null 
        || func.FuncType.ReturnType == OpaqueType.Instance)
        {
            func.FuncType.ReturnType = VoidType.Instance;
            
            //TODO if has body look through all return statements

            Information("\t Resolved ReturnType is '%s'", func.FuncType.ReturnType.toString());
        }
        else
            Information("\t ReturnType is %s", func.FuncType.ReturnType.toString());
        */

        //foreach instance check body
        //create body instances?

        //check if no Body then do through parameters 
        //Single Pairs are types
        //Generate FunctionType here?
        //from saved FunctionParameter Structure generated by Parser?
        //extend class functions with class param

        
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
            // implicit casts check
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
    * Get the Declaration of a DotIdentifier
    * e.g. "this.foo.bar.x" is a VariableDeclaration(int)
    */
    private Declaration resolve(DotIdentifier di)
    {
        //Symbol Table should not be null
        if(mSymTable is null)
        {
            Error("\t Resolve DotIdentifier: SymbolTable is null");
            return null;
        }

        //Instances and arguments

        //TODO Detect this at front

        auto elements = di.length;
        if(elements == 1)
        {
            //search up
            auto sym = mSymTable;

            do
            {
                if(sym.contains(cast(string)di[0]))
                    return sym[cast(string)di[0]];
            
                sym = sym.pop();
            }
            while(sym !is null)
        }
        else
        {
            //go up 
            //search down
        }
        

        return null;
    }

    //TODO Mixin Templates?
    //mixin(Types); Functions, and so on


    /**
    * Analyze the function parameter definition
    */
    private void analyzeFuncParam(ref FunctionDeclaration fd)
    {
        //detect if template function or not

        foreach(FunctionParameter p; fd.Parameter)
        {
        }
    }

    /**
    * Analyze Main Function
    */
    private void analyzeMainFunc(ref FunctionDeclaration func)
    {
        assert(func.Name == "main");

        assert(func.Body !is null, "main function required body");

        assert(func.Parameter.length != 1, "a main function can only have one parameter");

        if(func.ReturnType.Kind == NodeKind.OpaqueType)
            func.ReturnType = VoidType.Instance;

        //return type: unsolved then solved
        //finally only int or void are allowed

        assert(func.ReturnType == VoidType.Instance || func.ReturnType == IntType.Instance, "main function can be only have return type void or int");

        //FunctionParameter for main should be 
        
        if(func.Instances.length == 0)
        {
            auto type = new FunctionType();
            type.FuncDecl = func;
            type.ReturnType = func.ReturnType;
            type.Body = func.Body;
            
            if(func.Parameter.length ==1)
            {
                //at string[] argument
                //type.Arguments  ~=
            }

            func.Instances ~= type;
            //generate instance
            //mangled?
        }

        //requires body
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
        throw new SemanticException(format(s, args));
    }

    //Logging Signal? add Events for logging level

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
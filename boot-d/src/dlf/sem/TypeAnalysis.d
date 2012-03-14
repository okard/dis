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
module dlf.sem.TypeAnalysis;

import dlf.ast.Type;
import dlf.ast.SymbolTable;
import dlf.ast.Visitor;
import dlf.sem.Semantic;

/**
* Type Analysis
*/
class TypeAnalysis : Visitor
{

    /// Core Semantic Object
    private Semantic sem;

    /// Symbol Table
    private SymbolTable symTable;

    /**
    * Constructor
    */
    this(Semantic sem)
    {
        this.sem = sem;
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //Declarations

    /// Package Declaration
    void visit(PackageDecl pd)
    {
        symTable = pd.SymTable;
        mapDispatch(pd.Imports);
        symDispatch(pd.SymTable);
    }

    /// Import Declaration
    void visit(ImportDecl id)
    {
        //semantic check for available PackageDecls
        if(id.Package !is null)
        {
            id.Package = autoDispatch(id.Package);
        }
        else
        {
            sem.Error("\tImport %s has not been solved", id.Name);
            sem.Fatal("Can't proceed with unsolved import");
        }
    }

    /// Function Declaration
    void visit(FunctionDecl fd)
    {
        //Function Types

        //Overrides
        mapDispatch(fd.Overrides);


        //bodies
        autoDispatch(fd.Body);

        //look for ExpressionStatement bodies
    }

    /// Variable Declaration
    void visit(VarDecl vd)
    {
        sem.Information("Semantic: VarDecl %s", vd.Name);

        //Do Semantic Analysis for Initializer Expression if available
        if(vd.Initializer !is null)
            vd.Initializer = autoDispatch(vd.Initializer);

        //Solve Type
        vd.VarDataType = autoDispatch(vd.VarDataType);

        //Set Datatype for Variable
        if(IsOpaque(vd.VarDataType))
        {
            if(vd.Initializer !is null)
            {
                vd.VarDataType = vd.Initializer.ReturnType;
                sem.Information("\tResolved var type: %s", vd.VarDataType);
            }
        }

        //DataType of Variable and Initializer must match
        if(vd.Initializer !is null)
        {   
            //for class types generate constructor call?
            //check for allowed conversions?
            // implize_t]icit casts check
            sem.Information("\tVarType: %s, InitType: %s", vd.VarDataType, vd.Initializer.ReturnType); 
            //assert(var.VarDataType == var.Initializer.ReturnType);
        }
    }

    //Value
    //Constant
    void visit(ClassDecl cd){}
    void visit(TraitDecl td){}
    void visit(StructDecl sd){}
    //Alias
    //Enum
    //Variant

    ///////////////////////////////////////////////////////////////////////////
    //Statements

    /// Block Statement
    void visit(BlockStmt bs)
    {
        sem.Information("Semantic: BlockStmt");

        //symtable
        symTable = bs.SymTable;
        scope(exit)symTable = symTable.Prev;

        //analyze the declarations inside of blockstatement
        //what is when parent is function, parameter variables
        symDispatch(bs.SymTable);

        //check each statement
        mapDispatch(bs.Statements);

    }

    /// Expression Statement
    void visit(ExpressionStmt es)
    {
        es.Expr = autoDispatch(es.Expr);
    }

    /// Return Statement
    void visit(ReturnStmt rs)
    {
        //return type matches function type?
    }

    //For
    //ForEach
    //While

    ///////////////////////////////////////////////////////////////////////////
    //Expressions

    /// Literal Expression
    void visit(LiteralExpr le)
    {

    }
    
    /// Call Expression
    void visit(CallExpr ce)
    {
        //resolve identifier
        ce.Func = autoDispatch(ce.Func);


        if(ce.Func.Kind == NodeKind.DotIdExpr)
        {
            auto ie = cast(DotIdExpr)ce.Func;
            
            //if ie.Decl == FunctionDecl
            //
            //decl == functions its required to detect right instance for call
            //here a function instance from template can be created
        }

        //lambda
        //delegate


        //ce.Func == DotIdExpr for example
        //assert(ce.Func.ReturnType.Kind == NodeKind.FunctionType, "Can't call a non function");

        //target expression should be a function type
        //call expressions can generate function instances
    }

    /// Identifier Expression 
    void visit(DotIdExpr ie)
    {
        sem.Information("IdentifierExpr: %s", ie.toString());

        //go up, find first start entry
        Declaration decl = null;

        if(symTable.contains(ie.first))
        {
            decl = symTable[ie.first];
        }
        else
        {
            auto sym = symTable;
            do
            {
                if(sym.contains(ie.first))
                {
                    decl = sym[ie.first];
                    break;
                }
                sym = sym.Prev;
            }
            while(sym !is null);
        }
            
        //no start point
        if(decl is null)
        {
            sem.Error("Can't find first entry identifier %s", ie.first);
            sem.Fatal("Failed type resolve");
        }

        //go down, search the right last part of identifier
        if(ie.length > 1)
        {
            debug sem.Information("Search down");
            auto sym = getSymbolTable(decl);

            /*
            for(int i=1; i< ie.length; i++)
            {
                if(!sym.contains(ie[i]));
            }
            */
        }
        else
        {
            ie.Decl = decl;
        }

        //dont find the right declaration
        if(ie.Decl is null)
        {
            sem.Error("Can't resolve identifier %s", ie.toString());
            sem.Fatal("Failed type resolve");
        }

        sem.Information("Found %s", ie.Decl.Name);
        //resolve ie.Decl 
        //ie.ReturnType = targettype
    }
      

    /// Binary Expression
    void visit(BinaryExpr be)
    {
        // analyze left, right
        be.Left = autoDispatch(be.Left);
        be.Right = autoDispatch(be.Right);

        
        //final
        switch(be.Op)
        {

        //Add, Sub, Mul, Div, Mod, Power, And, Or, Xor,
        //LOr, LAnd, 
        //GT, GTE, LT, LTE

        case BinaryOperator.Assign:
            assert(be.Left.Kind == NodeKind.DotIdExpr);
            break;

        default:
        }

        //some operator have boolean type
        //some operator works with numbers

        //rewrite operator calls for classes?
        //be.Left is class operator call
        //resolveDecl(be.Left) 
        //return new CallExpr(); Expr = new DotIdExpr(decl.name)

        //assign expressions -> verify variable type
        //IsVariable(be.Left) (IdentifierExpr)
        
        //type matching
    }

    ///////////////////////////////////////////////////////////////////////////
    //Annotations

    ///////////////////////////////////////////////////////////////////////////
    //Types

    DataType visit(DataType dt)
    { 
        //Check for Ref Ref Types
        //Check for Ptr Ptr Types
        //TODO resolve DotType here
        //same as DotIdExpr? 

        //make a solve CompositeIdentifier?
        //difference in structure array types template instances, create instances here for templates?

        return dt; 
    }
    

    
    ///////////////////////////////////////////////////////////////////////////
    //Internal


    /// Mixin Dispatch Utils
    mixin DispatchUtils!true;

    /**
    * Is opaque type
    */
    private static bool IsOpaque(DataType t)
    {
        return t == OpaqueType.Instance;
    }

    /**
    * Reveive symbol table from a node that has one
    */
    private static SymbolTable getSymbolTable(Node n)
    {
        //Decl: Package, Struct, Class, Trait,
        //Stmt: BlockStatement

        switch(n.Kind)
        {
            case NodeKind.PackageDecl:
                return (cast(PackageDecl)n).SymTable;
            case NodeKind.StructDecl:
                return (cast(StructDecl)n).SymTable;
            case NodeKind.ClassDecl:
                return (cast(ClassDecl)n).SymTable;
            //case NodeKind.TraitDecl:
            //    return (cast(TraitDecl)n).SymTable;
            case NodeKind.FunctionDecl:
                return (cast(FunctionDecl)n).Body.SymTable;
            case NodeKind.BlockStmt:
                return (cast(BlockStmt)n).SymTable;

            default:
                throw new Semantic.SemanticException("These node has no symboltable");
        }
    }
}

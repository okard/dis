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

import dlf.basic.Stack;

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

    /// Symbol Tables
    private Stack!(SymbolTable*) symTables = Stack!(SymbolTable*)(128);

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
    Declaration visit(PackageDecl pd)
    {
        sem.Information("Semantic: PackageDecl");

        symTables.push(&pd.SymTable);
        scope(exit) symTables.pop();    

        mapDispatch(pd.Imports);
        symDispatch(pd.SymTable);

        return pd;
    }

    /// Import Declaration
    Declaration visit(ImportDecl id)
    {
        sem.Information("Semantic: ImportDecl");

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

        return id;
    }

    /// Function Declaration
    Declaration visit(FunctionDecl fd)
    {
        sem.Information("Semantic: FunctionDecl %s", fd.Name);
        //Function Types

        //Overrides
        mapDispatch(fd.Overrides);

        //bodies
        mapDispatch(fd.Body);

        //look for ExpressionStatement bodies

        return fd;
    }

    /// Variable Declaration
    Declaration visit(VarDecl vd)
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

        return vd;
    }

    //Value
    //Constant
    
    /// Class Declaration
    Declaration visit(ClassDecl cd)
    { 
        return cd;
    }

    /// Trait Declaration
    Declaration visit(TraitDecl td)
    { 
        return td; 
    }
    
    /// Struct Declaration
    Declaration visit(StructDecl sd)
    {
        sem.Information("Semantic: StructDecl %s", sd.Name);

        symTables.push(&sd.SymTable);
        scope(exit) symTables.pop();

        symDispatch(sd.SymTable);
        return sd; 
    }
    
    /// Alias Declaration
    Declaration visit(AliasDecl ad)
    {
        return ad;
    }

    //Enum
    //Variant    


    ///////////////////////////////////////////////////////////////////////////
    //Statements

    /// Block Statement
    Statement visit(BlockStmt bs)
    {
        sem.Information("Semantic: BlockStmt");

        //symtable
        symTables.push(&bs.SymTable);
        scope(exit) symTables.pop();

        //analyze the declarations inside of blockstatement
        //what is when parent is function, parameter variables
        symDispatch(bs.SymTable);

        //check each statement
        mapDispatch(bs.Statements);

        return bs;
    }

    /// Expression Statement
    Statement visit(ExpressionStmt es)
    {
        sem.Information("Semantic: ExpressionStmt");

        es.Expr = autoDispatch(es.Expr);
        return es;
    }

    /// Return Statement
    Statement visit(ReturnStmt rs)
    {
        sem.Information("Semantic: ReturnSmt");
        //return type matches function type?
        return rs;
    }

    //For
    //ForEach
    //While

    ///////////////////////////////////////////////////////////////////////////
    //Expressions

    /// Literal Expression
    Expression  visit(LiteralExpr le)
    {
        sem.Information("Semantic: LiteralExpr");

        return le;
    }
    
    /// Call Expression
    Expression visit(CallExpr ce)
    {
        sem.Information("Semantic: CallExpr");

        //resolve identifier
        ce.Func = autoDispatch(ce.Func);

        if(ce.Func.Kind == NodeKind.IdExpr)
        {    
            auto ie = ce.Func.to!IdExpr;
            
            //if ie.Decl == FunctionDecl
            //
            //decl == functions its required to detect right instance for call
            //here a function instance from template can be created
        }

        //lambda
        //delegate


        //ce.Func == IdExpr for example
        //assert(ce.Func.ReturnType.Kind == NodeKind.FunctionType, "Can't call a non function");

        //target expression should be a function type
        //call expressions can generate function instances

        return ce;
    }


      

    /// Binary Expression
    Expression visit(BinaryExpr be)
    {
        sem.Information("Semantic: BinaryExpr");

        assert(be.Op != BinaryOperator.Dot);
        
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
            //assert(be.Left.Kind == NodeKind.IdExpr);
            break;

        default:
        }

        //some operator have boolean type
        //some operator works with numbers

        //rewrite operator calls for classes?
        //be.Left is class operator call
        //resolveDecl(be.Left) 
        //return new CallExpr(); Expr = new IdExpr(decl.name)

        //assign expressions -> verify variable type
        //IsVariable(be.Left) (IdentifierExpr)
        
        //type matching
        return be;
    }

    /**
    * DotExpr 
    */
    public Expression visit(DotExpr de)
    {
        sem.Information("Semantic: DotExpr");

        //Visit Left one
        de.Left = autoDispatch(de.Left);

        //No Declaration Type Replace with call expr
        //(5+a).foo -> foo(5+a);

        sem.Information("Left: %s %b", de.Left.ReturnType.toString(), de.Left.ReturnType.Kind != NodeKind.DeclarationType);
        if(de.Left.ReturnType.Kind != NodeKind.DeclarationType)
        {
            sem.Information("Rewrite DotExpr");
            auto ce = new CallExpr();
            ce.Func = de.Right;
            ce.Arguments ~= de.Left;
            return autoDispatch(ce);
        }

        //Right is restricted
        if(de.Right.Kind != NodeKind.IdExpr 
        || de.Right.Kind != NodeKind.DotExpr)
            sem.Error("%s invalid right of DotExpr", de.Right.Loc.toString());

        //visit right has parameter of de.Left.ReturnType


        //search right 
        //return type = de.right.returntype;
   
        return de;
    }

    /// Identifier Expression 
    Expression visit(IdExpr ie)
    {
        sem.Information("IdExpr: %s", ie.toString());
        
        //already solved?
        if(ie.Decl !is null)
            return ie;

        //sem.Information(ie.Parent.toString());

        ie.Decl = search(ie.Id);

        //dont find the right declaration
        if(ie.Decl is null)
        {
            sem.Error("Can't resolve identifier %s", ie.Id);
            sem.Fatal("Failed type resolve");
        }

        sem.Information("Found %s", ie.Decl.Name);

        switch(ie.Decl.Kind)
        {
            //Instance Types:
            case NodeKind.VarDecl:
                ie.ReturnType = ie.Decl.to!VarDecl.VarDataType;
                break;
            //const, val

            case NodeKind.AliasDecl:
                ie.ReturnType = ie.Decl.to!AliasDecl.AliasType;
                break;

            //Possible Tpl Types wrapped with DeclarationType:
            case NodeKind.FunctionDecl:
            case NodeKind.StructDecl:
            case NodeKind.ClassDecl:
            case NodeKind.TraitDecl:
                auto dt = new DeclarationType();
                dt.Decl = ie.Decl;
                ie.ReturnType = dt;
                break;

            default:
                sem.Information("Something goes wrong in IdExpr solving");
        }

        assert(ie.ReturnType !is null);

        return ie;
    }

    ///////////////////////////////////////////////////////////////////////////
    //Annotations

    ///////////////////////////////////////////////////////////////////////////
    //Types

    DataType visit(DataType dt)
    {
        sem.Information("Semantic: DataType %s", dt.toString());
        //Check for Ref Ref Types
        //Check for Ptr Ptr Types
        //TODO resolve DotType here
        //same as IdExpr? 

        //make a solve CompositeIdentifier?
        //difference in structure array types template instances, create instances here for templates?

        return dt; 
    }

    /**
    * A dot type returns a DeclarationType
    */
    public DataType visit(DotType dt)
    out(result)
    {
        assert(result.Kind() == NodeKind.DeclarationType);
    }
    body
    {
        sem.Information("Semantic: DotType");

        if(dt.Parent !is null && dt.Parent.Kind() != NodeKind.DotType)
            sem.Error("DotType can not have other parents as DotType");
            
        dt.ResolvedDecl = search(dt.Value);

        if(dt.ResolvedDecl is null)
        {
            sem.Error("Identifier not found %s", dt.Value);
            sem.Fatal("Type Resolving failed");
        }

        if(dt.ResolvedDecl.IsInstanceDecl)
            sem.Error("DataType references to a instance symbol %s", dt.Value);
        
        //when nothing found in bottom up search in imports?
        //top down search
        //search imports 
        //use symTables.bottom.Owner
        // symTables.bottom.Kind == NodeKind.PackageDecl.
        
        //search for ct.Right

        if(dt.ResolvedDecl is null)
            sem.Fatal("Can't proceed with unsolved datatype");

        auto declType = new DeclarationType();
        declType.Decl = dt.ResolvedDecl;
        
        if(dt.Right is null)
            return declType;
        //return here right when it has right
        //no place holder value

        //TODO assert dt.ResolvedDecl dt.ResolvedType != null

        //Rewrite to DeclarationType


        return declType;
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //Helper


    //DataType search(DotType dt, Declaration start)
    //Expression search(IdExpr id, Declaration start)

    private Declaration search(string id, Declaration start = null)
    {
        debug dumpSymbolTables();

        //bottom up search for simple id
        if(start is null)
        {
            //Bottom up search
            for(int i=symTables.length-1; i >= 0; i--)
            {
                if(symTables[i].contains(id))
                {
                    auto d = (*symTables[i])[id];
                    return d;
                }
            }

            //top down without start (Package Imports)
            assert(symTables.bottom.Owner.Kind == NodeKind.PackageDecl, "First SymbolTable in ST Stack should be a package for this kind of searching");
            //look in imports for id

            return null;
        }

        if(getSymbolTable(start).contains(id))
        {
            return getSymbolTable(start)[id];
        }
        
        return null;
    }


    /**
    * dumps the current symbol table stack
    * for debugging
    */
    private void dumpSymbolTables()
    {
        //Bottom up search
        for(int i=symTables.length-1; i >= 0; i--)
        {
            SymbolTable symTbl = *symTables[i];

            sem.Information("\tSymbolTable %d Entries: %d : %s", i, symTbl.count, symTbl.Owner.toString());

            foreach(Declaration d; symTbl)
            {
                sem.Information("\t\tEntry: %s", d.Name);
            }
        }
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
    * Receive symbol table from a node that has one
    */
    private static SymbolTable getSymbolTable(Node n)
    {
        //Decl: Package, Struct, Class, Trait,
        //Stmt: if, for, while

        switch(n.Kind)
        {
            case NodeKind.PackageDecl:
                return n.to!PackageDecl.SymTable;
            case NodeKind.StructDecl:
                return n.to!StructDecl.SymTable;
            case NodeKind.ClassDecl:
                return n.to!ClassDecl.SymTable;
            case NodeKind.TraitDecl:
                return n.to!TraitDecl.SymTable;
            case NodeKind.FunctionDecl:
                return n.to!FunctionDecl.SymTable;

            //TODO Remove Block Stmt
            case NodeKind.BlockStmt:
                return n.to!BlockStmt.SymTable;

            default:
                throw new Semantic.SemanticException("These node has no symboltable");
        }
    }
}

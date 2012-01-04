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
    void visit(PackageDeclaration pd)
    {
        mapDispatch(pd.Imports);
        symDispatch(pd.SymTable);
    }

    /// Import Declaration
    void visit(ImportDeclaration id)
    {
        //semantic check for available PackageDeclarations
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
    void visit(FunctionDeclaration fd)
    {
        //Function Types

        //Overrides
        mapDispatch(fd.Overrides);


        //bodies
        autoDispatch(fd.Body);

        //look for ExpressionStatement bodies
    }

    /// Variable Declaration
    void visit(VariableDeclaration vd)
    {
        sem.Information("Semantic: VarDecl %s", vd.Name);

        //Do Semantic Analysis for Initializer Expression if available
        if(vd.Initializer !is null)
            vd.Initializer = autoDispatch(vd.Initializer);

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
    void visit(ClassDeclaration){}
    void visit(TraitDeclaration){}
    //Struct
    //Alias
    //Enum
    //Variant

    ///////////////////////////////////////////////////////////////////////////
    //Statements

    /// Block Statement
    void visit(BlockStatement bs)
    {
        sem.Information("Semantic: BlockStmt");

        symTable = bs.SymTable;

        //analyze the declarations inside of blockstatement
        //what is when parent is function, parameter variables
        symDispatch(bs.SymTable);

        //check each statement
        mapDispatch(bs.Statements);
    }

    /// Expression Statement
    void visit(ExpressionStatement es)
    {
        es.Expr = autoDispatch(es.Expr);
    }

    /// Return Statement
    void visit(ReturnStatement)
    {
        //return type matches function type?
    }

    //For
    //ForEach
    //While

    ///////////////////////////////////////////////////////////////////////////
    //Expressions
    void visit(LiteralExpression){}
    
    void visit(CallExpression)
    {
        //call expressions can generate function instances
    }

    void visit(IdentifierExpression){}
      

    /// Binary
    void visit(BinaryExpression)
    {
        // analyze left, right

        //some operator have boolean type
        
        //type matching
    }

    ///////////////////////////////////////////////////////////////////////////
    //Annotations

    ///////////////////////////////////////////////////////////////////////////
    //Types
    

    /// Mixin Dispatch Utils
    mixin DispatchUtils!true;

    /**
    * Is opaque type
    */
    private static bool IsOpaque(DataType t)
    {
        return t == OpaqueType.Instance;
    }
}


/**
* Semantic Functions for Types
*/
/*
mixin template TypeAnalysis()
{

    //resolve types

    /**
    * Get the Declaration of a IdentifierExpression
    * e.g. "this.foo.bar.x" is a VariableDeclaration(int)
    */
    /*private Declaration resolve(IdentifierExpression di)
    {
        assert(mSymTable is null, "Resolve IdentifierExpression: SymbolTable is null");

        //Instances and arguments

        //TODO Detect this at front

        auto elements = di.length;
        if(elements == 1)
        {
            //search up
            auto sym = mSymTable;

            do
            {
                if(sym.contains(di.first))
                    return sym[di.first];
            
                sym = sym.pop();
            }
            while(sym !is null);
        }
        else
        {
            //go up 
            //search down
        }
        

        return null;
    }*/

 
//}

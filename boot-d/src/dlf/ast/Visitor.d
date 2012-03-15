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
module dlf.ast.Visitor;

public import dlf.ast.Node;
public import dlf.ast.Declaration;
public import dlf.ast.Statement;
public import dlf.ast.Expression;
public import dlf.ast.Annotation;
public import dlf.ast.Type;
public import dlf.ast.SymbolTable;

/**
* AST Visitor
*/
public interface Visitor
{
    public 
    {
    //Declarations
    Declaration visit(PackageDecl);
    Declaration visit(ImportDecl);
    Declaration visit(FunctionDecl);
    Declaration visit(VarDecl);
    //Value
    //Constant
    Declaration visit(ClassDecl);
    Declaration visit(TraitDecl);
    Declaration visit(StructDecl);
    //Struct
    //Alias
    //Enum
    //Variant

    //Statements
    void visit(BlockStmt);
    void visit(ExpressionStmt);
    void visit(ReturnStmt);
    //For
    //ForEach
    //While
    //Break
    //Continue

    //Expressions
    void visit(LiteralExpr);
    void visit(CallExpr);
    void visit(DotIdExpr);
    void visit(BinaryExpr);
    //Unary
    //IfExpr
    //SwitchExpr
    //Lambda
    

    //Annotations
    //UnitTest

    //Types
    DataType visit(DataType);

    
    }

    //voids with ref for modification or not?
    //handle in dispatch so pd = dispatch(pd) works?
    //but remove the requirement of return variables?
    //in-out visitor void visit(LiteralExpr in, Node out);
    //disable special ranges (declarations, statements, expression, types, and so on)
}


/**
* Dispatch Function General
*/
Node dispatch(Node n, Visitor v, bool mod = false)
{
    assert(n !is null, "Node shouldn't be null");
    assert(v !is null, "Visitor shouldn't be null");
    assert(n.Self is null, "A not null self, a dispatch goes wrong");

    /*final*/ 
    switch(n.Kind)
    {   
        //Declarations
        case NodeKind.PackageDecl: 
            auto r = v.visit(cast(PackageDecl)n);
            return mod ? r : n;

        case NodeKind.ImportDecl: 
            auto r =v.visit(cast(ImportDecl)n); 
            return mod ? r : n;

        case NodeKind.VarDecl: 
            auto r = v.visit(cast(VarDecl)n);
            return mod ? r : n;

        //Value
        //Constant
        case NodeKind.FunctionDecl: v.visit(cast(FunctionDecl)n); break;
        case NodeKind.ClassDecl: v.visit(cast(ClassDecl)n); break;
        case NodeKind.TraitDecl: v.visit(cast(TraitDecl)n); break;
        case NodeKind.StructDecl: v.visit(cast(StructDecl)n); break;
        //Struct
        //Alias
        //Enum
        //Variant

        //Statements
        case NodeKind.BlockStmt: v.visit(cast(BlockStmt)n); break;
        case NodeKind.ExpressionStmt: v.visit(cast(ExpressionStmt)n); break;
        case NodeKind.ReturnStmt: v.visit(cast(ReturnStmt)n); break;
        //For
        //ForEach
        //While
        
        //Expressions
        case NodeKind.LiteralExpr: v.visit(cast(LiteralExpr)n); break;
        case NodeKind.CallExpr: v.visit(cast(CallExpr)n); break;
        case NodeKind.DotIdExpr: v.visit(cast(DotIdExpr)n); break;
        case NodeKind.BinaryExpr: v.visit(cast(BinaryExpr)n); break;
        //UnaryExpr
        //If
        //Switch

        //Types
        case NodeKind.DataType: v.visit(cast(DataType)n); break;
        case NodeKind.DotType: v.visit(cast(DataType)n); break;


        //Special
        case NodeKind.Semantic: assert(false, "Can't dispatch special semantic node");
        case NodeKind.Backend: assert(false, "Can't dispatch special backend node"); 
    
        default: assert(false, "Missing dispatch case");
    }

    assert(!(!mod && (n.Self !is null)), "Only with mod enabled a self should be set");
         
    return mod && (n.Self !is null) ? n.Self : n;
}
    


/**
* Dispatch utils template 
*/
mixin template DispatchUtils(bool modify)
{
    /**
    * Auto Dispatch
    */
    private final T autoDispatch(T)(T e)
    {
        if(e is null) return e;

        return cast(T)dispatch(e, this, modify);
    }

    /**
    * Map Dispatch to Arrays
    */
    private final void mapDispatch(T)(T[] elements)
    {
        for(int i=0; i < elements.length; i++)
        {
            elements[i] = autoDispatch(elements[i]);
        }
    }

    /**
    * SymbolTable Dispatch
    */
    private final void symDispatch(SymbolTable symTable)
    {
         //go through declarations
        foreach(Declaration d; symTable)
        {
            assert(symTable[d.Name] == d);
            symTable[d.Name] = autoDispatch(d);
        }
    }
}

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

debug import std.stdio;

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
    Statement visit(BlockStmt);
    Statement visit(ExpressionStmt);
    Statement visit(ReturnStmt);
    //For
    //ForEach
    //While
    //Break
    //Continue

    //Expressions
    Expression visit(LiteralExpr);
    Expression visit(CallExpr);
    Expression visit(IdExpr);
    Expression visit(DotExpr);
    Expression visit(BinaryExpr);
    //Unary
    //IfExpr
    //SwitchExpr
    //Lambda
    

    //Annotations
    //UnitTest

    //Types
    DataType visit(DataType);
    DataType visit(DotType);

    //RefType
    //

    
    }

    //voids with ref for modification or not?
    //handle in dispatch so pd = dispatch(pd) works?
    //but remove the requirement of return variables?
    //in-out visitor void visit(LiteralExpr in, Node out);
    //disable special ranges (declarations, statements, expression, types, and so on)
}

private auto doVisit(T)(const bool mod, Node n, Visitor v)
{
    auto r = v.visit(n.to!T);
    return mod ? r : n;
} 

/**
* Dispatch Function General
*/
Node dispatch(Node n, Visitor v, const bool mod = false)
{
    assert(n !is null, "Node shouldn't be null");
    assert(v !is null, "Visitor shouldn't be null");

    switch(n.Kind)
    {   
        //Declarations
        case NodeKind.PackageDecl: return doVisit!PackageDecl(mod, n, v);
        case NodeKind.ImportDecl: return doVisit!ImportDecl(mod, n, v);
        case NodeKind.VarDecl: return doVisit!VarDecl(mod, n, v);

        //Value
        //Constant
        case NodeKind.FunctionDecl: return doVisit!FunctionDecl(mod, n, v);
        case NodeKind.ClassDecl: return doVisit!ClassDecl(mod, n, v);
        case NodeKind.TraitDecl: return doVisit!TraitDecl(mod, n, v);
        case NodeKind.StructDecl: return doVisit!StructDecl(mod, n, v);
        //Alias
        //Enum
        //Variant

        //Statements
        case NodeKind.BlockStmt: return doVisit!BlockStmt(mod, n, v);
        case NodeKind.ExpressionStmt: return doVisit!ExpressionStmt(mod, n, v);
        case NodeKind.ReturnStmt: return doVisit!ReturnStmt(mod, n, v);
        //For
        //ForEach
        //While
        
        //Expressions
        case NodeKind.LiteralExpr: return doVisit!LiteralExpr(mod, n, v);
        case NodeKind.CallExpr: return doVisit!CallExpr(mod, n, v);
        case NodeKind.IdExpr: return doVisit!IdExpr(mod, n, v);
        case NodeKind.DotExpr: return doVisit!DotExpr(mod, n, v);
        case NodeKind.BinaryExpr: return doVisit!BinaryExpr(mod, n, v);
        //UnaryExpr
        //If
        //Switch

        //Types
        case NodeKind.DataType: return doVisit!DataType(mod, n, v);
        case NodeKind.OpaqueType: return doVisit!OpaqueType(mod, n, v);
        case NodeKind.DotType: return doVisit!DotType(mod, n, v);
        //ref type
        case NodeKind.FunctionType: return doVisit!FunctionType(mod, n, v);


        //Special
        case NodeKind.Semantic: assert(false, "Can't dispatch special semantic node");
        case NodeKind.Backend: assert(false, "Can't dispatch special backend node"); 
    
        default:
            debug writeln(n.toString());
            assert(false, "Missing dispatch case");
            
    }

    assert(false, "should not get here");
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

        return dispatch(e, this, modify).to!T;
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
            symTable.assign(autoDispatch(d));
        }
    }
}

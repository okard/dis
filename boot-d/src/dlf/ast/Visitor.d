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

/**
* AST Visitor
*/
public interface Visitor
{
    public 
    {
    //Declarations
    void visit(PackageDeclaration);
    void visit(ImportDeclaration);
    void visit(FunctionSymbol);
    void visit(VariableDeclaration);
    void visit(ClassDeclaration);
    void visit(TraitDeclaration);

    //Statements
    void visit(BlockStatement);
    void visit(ExpressionStatement);
    void visit(ReturnStatement);

    //Expressions
    void visit(LiteralExpression);
    void visit(CallExpression);
    void visit(DotIdentifier);
    void visit(AssignExpression);
    void visit(BinaryExpression);

    //Annotations

    //Types
    
    }

    //voids with ref for modification or not?
    //handle in dispatch so pd = dispatch(pd) works?
    //but remove the requirement of return variables?
    //in-out visitor void visit(LiteralExpression in, Node out);
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
        case NodeKind.PackageDeclaration: v.visit(cast(PackageDeclaration)n); break;
        case NodeKind.ImportDeclaration: v.visit(cast(ImportDeclaration)n); break;
        case NodeKind.VariableDeclaration: v.visit(cast(VariableDeclaration)n); break;
        case NodeKind.FunctionSymbol: v.visit(cast(FunctionSymbol)n); break;
        case NodeKind.ClassDeclaration: v.visit(cast(ClassDeclaration)n); break;
        case NodeKind.TraitDeclaration: v.visit(cast(TraitDeclaration)n); break;

        //Statements
        case NodeKind.BlockStatement: v.visit(cast(BlockStatement)n); break;
        case NodeKind.ExpressionStatement: v.visit(cast(ExpressionStatement)n); break;
        case NodeKind.ReturnStatement: v.visit(cast(ReturnStatement)n); break;
        
        //Expressions
        case NodeKind.LiteralExpression: v.visit(cast(LiteralExpression)n); break;
        case NodeKind.CallExpression: v.visit(cast(CallExpression)n); break;
        case NodeKind.DotIdentifier: v.visit(cast(DotIdentifier)n); break;
        case NodeKind.AssignExpression: v.visit(cast(AssignExpression)n); break;
        case NodeKind.BinaryExpression: v.visit(cast(BinaryExpression)n); break;

        //Types

        //Special
        case NodeKind.Semantic: assert(false, "Can't dispatch special node");
        case NodeKind.Backend: assert(false, "Can't dispatch special node"); 
    
        default: assert(false, "Missing dispatch case");
    }

    assert(!(!mod && (n.Self !is null)), "Only with mod enabled a self should be set");
         
    return mod && (n.Self !is null) ? n.Self : n;
}
    

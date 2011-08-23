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
    void visit(FunctionDeclaration);
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

    //Annotations:
    }

    //voids with ref for modification or not?
    //handle in dispatch so pd = dispatch(pd) works?
    //but remove the requirement of return variables?
}


/**
* Dispatch Function General
*/
Node dispatch(Node n, Visitor v, bool mod = false)
{
    assert(n !is null);
    assert(v !is null);

    //inner node
    Node inner = n;
    //set replacer function
    n.ret = (Node nn){ assert(!mod); inner = nn; };

    // node.replace(Node);
    

    /*final*/ 
    switch(n.Kind)
    {   
        //Declarations
        case NodeKind.PackageDeclaration: v.visit(cast(PackageDeclaration)n); break;
        case NodeKind.ImportDeclaration: v.visit(cast(ImportDeclaration)n); break;
        case NodeKind.VariableDeclaration: v.visit(cast(VariableDeclaration)n); break;
        case NodeKind.FunctionDeclaration: v.visit(cast(FunctionDeclaration)n); break;
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
    
        default: assert(false);
    }

    n.ret = null;
    

    return mod ? inner : n;
}
    

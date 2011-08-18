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

import dlf.ast.Node;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Annotation;

/**
* AST Visitor
*/
public interface Visitor
{
    public 
    {
    //Declarations
    Node visit(PackageDeclaration);
    Node visit(FunctionDeclaration);
    Node visit(ImportDeclaration);
    Node visit(VariableDeclaration);
    Node visit(ClassDeclaration);
    Node visit(TraitDeclaration);
    //Statements
    Node visit(BlockStatement);
    Node visit(ExpressionStatement);
    Node visit(ReturnStatement);
    //Expressions
    Node visit(LiteralExpression);
    Node visit(FunctionCall);
    Node visit(DotIdentifier);
    Node visit(AssignExpression);
    Node visit(BinaryExpression);
    //Annotations:
    }
}


/**
* Dispatch Function General
*/
Node dispatch(Node n, Visitor v)
{
    assert(n !is null);
    assert(v !is null);

    switch(n.Kind)
    {   
        //Declarations
        case NodeKind.PackageDeclaration: return v.visit(cast(PackageDeclaration)n);
        case NodeKind.ImportDeclaration: return v.visit(cast(ImportDeclaration)n);
        case NodeKind.VariableDeclaration: return v.visit(cast(VariableDeclaration)n);
        case NodeKind.FunctionDeclaration: return v.visit(cast(FunctionDeclaration)n);
        case NodeKind.ClassDeclaration: return v.visit(cast(ClassDeclaration)n);
        
        //Statements

        //Expressions
    
        default: assert(false);
    }
}
    

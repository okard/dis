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

import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Annotation;

/**
* AST Visitor
*/
public interface Visitor
{
    public {
    //Declarations
    void visit(PackageDeclaration);
    void visit(FunctionDeclaration);
    void visit(ImportDeclaration);
    void visit(VariableDeclaration);
    void visit(ClassDeclaration);
    void visit(TraitDeclaration);
    //Statements
    void visit(BlockStatement);
    void visit(ExpressionStatement);
    void visit(ReturnStatement);
    //Expressions
    void visit(LiteralExpression);
    void visit(FunctionCall);
    void visit(DotIdentifier);
    void visit(AssignExpression);
    void visit(BinaryExpression);
    //Annotations:
    void visit(CallConvAnnotation);
    }
}

/**
* Visitor Mixin
*/
mixin template VisitorMixin()
{
    /// Accept Visitor
    public override void accept(Visitor v) { v.visit(this); }
}
    
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
* Dispatch Function Declaration
*/
auto dispatch(Declaration d, Visitor v)
{
    assert(d !is null);
    assert(v !is null);

    switch(d.DeclType)
    {
        case Declaration.Type.Package: return v.visit(cast(PackageDeclaration)d);
        case Declaration.Type.Import: return v.visit(cast(ImportDeclaration)d);
        case Declaration.Type.Variable: return v.visit(cast(VariableDeclaration)d);
        case Declaration.Type.Function: return v.visit(cast(FunctionDeclaration)d);
        case Declaration.Type.Class: return v.visit(cast(ClassDeclaration)d);
        //case Declaration.Type.Struct: return v.visit(cast(StructDeclaration)d);
        //case Declaration.Type.Enum: return v.visit(cast(EnumDeclaration)d);
        //case Declaration.Type.Alias: return v.visit(cast(AliasDeclaration)d);
        //case Declaration.Type.Delegate: return v.visit(cast(DelegateDeclaration)d);
        default: assert(false);
    }

}

/**
* Dispatch Function Statement
*/
Node dispatch(Statement s, Visitor v)
{
    switch(s.StmtType)
    {

        default: assert(false);
    }
}

/**
* Dispatch Function Expression
*/
Node dispatch(Expression e, Visitor v)
{
    switch(e.ExprType)
    {

        default: assert(false);
    }
}

/**
* Dispatch Function General
*/
Node dispatch(Node n, Visitor v)
{
    assert(n !is null);
    assert(v !is null);

    switch(n.NodeType)
    {
        case Node.Type.Declaration: return dispatch(cast(Declaration)n, v);
        case Node.Type.Statement: return dispatch(cast(Statement)n, v);
        case Node.Type.Expression: return dispatch(cast(Expression)n, v);
        //case Node.Type.DataType: return dispatch(cast(DataType)n, v);
        //case Node.Type.Annotation: return dispatch(cast(Annotation)n, v);
        //case Node.Type.Special: return dispatch(cast(Special)n, v);
        default: assert(false);
    }
}




//Expression dispatch(Expression n, Visitor v)
    

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
module dlf.gen.Semantic;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;

import std.stdio;

/**
* Semantic Pass for AST
*/
class Semantic : AbstractVisitor
{
    //rules
    //semantic passes?

    //Type stack name -> Type 
    //Stack!(Type[char[]])
    
    /**
    * Visit Declaration
    */
    override void visit(Declaration decl)
    {
    }

    /**
    * Visit Statement
    */
    override void visit(Statement stat)
    {
    }

    /**
    * Visit Expression
    */
    override void visit(Expression expr)
    {
    }

    /**
    * Visit PackageDeclaration
    */
    override void visit(PackageDeclaration pack)
    {
        foreach(FunctionDeclaration f; pack.mFunctions)
            f.accept(this);  
    }

    /**
    * Visit FunctionDeclaration
    */
    override void visit(FunctionDeclaration func)
    { 
        if(func.mBody !is null)
            func.mBody.accept(this);
    }

    /**
    * Visit Block Statement
    */
    override void visit(BlockStatement block)
    {
        foreach(stat; block.mStatements)
            stat.accept(this);
    }

    /**
    * Visit Expression Statement
    */
    override void visit(ExpressionStatement expr)
    {
        expr.mExpression.accept(this);
    }

    /**
    * Visit Function Call
    */
    override void visit(FunctionCall call)
    {
        //check for function
        //call.mFunction.NType() == NodeType.DotIdentifier
        // Look for parameter type matching
    }

    /**
    * Run semantic passes 
    * Parse Tree -> AST
    */
    public Node run(Node astNode)
    {
        astNode.accept(this);
        return astNode;
    }
}
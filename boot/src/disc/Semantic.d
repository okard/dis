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
module disc.Semantic;

import disc.ast.Node;
import disc.ast.Visitor;
import disc.ast.Declaration;
import disc.ast.Statement;
import disc.ast.Expression;

import std.stdio;

/**
* Semantic Pass for AST
*/
class Semantic : Visitor
{
    //rules

    //Type stack name -> Type 
    //Stack!(Type[char[]])
    
    /**
    * Visit Declaration
    */
    void visit(Declaration decl)
    {
    }

    /**
    * Visit Statement
    */
    void visit(Statement stat)
    {
    }

    /**
    * Visit Expression
    */
    void visit(Expression expr)
    {
    }

    /**
    * Visit PackageDeclaration
    */
    void visit(PackageDeclaration pack)
    {
        foreach(FunctionDeclaration f; pack.mFunctions)
            f.accept(this);  
    }

    /**
    * Visit FunctionDeclaration
    */
    void visit(FunctionDeclaration func)
    { 
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
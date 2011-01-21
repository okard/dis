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
module dlf.ast.Statement;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Expression;

import dlf.ast.SymbolTable;
 

/**
* Statement Base Class
*/
abstract class Statement : Node
{
} 

/**
* Defines a Block {}
* Is more Declaration?
* Has a SymbolTable?
* Can have classes, functions, ...
*/
final class BlockStatement : Statement
{
    //Visitor Mixin
    mixin VisitorMixin;

    ///Statements
    public Statement[] Statements;

    ///Symbol Table
    public SymbolTable SymTable;

    ///Create new BlockStatement
    this()
    {
        mixin(set_nodetype);
    }
}

/**
* A Expression Statement
* e.g. Function Call, Assign Expression
*/
final class ExpressionStatement : Statement
{
    //Visitor Mixin
    mixin VisitorMixin;

    /// Expression
    public Expression Expr;

    ///Create new ExpressionStatement
    public this(Expression expr)
    {
        mixin(set_nodetype);
        Expr = expr;
    }
}

/**
* Return Statement
*/
final class ReturnStatement : Statement
{
    //Visitor Mixin
    mixin VisitorMixin;
    
    /// The Return Expression
    public Expression Expr;

    /// Create new Return Statement
    public this(Expression expr)
    {
        mixin(set_nodetype);
        Expr = expr;
    }
}

//For
//ForEach
//While
